import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../core/network/endpoints.dart';
import '../../data/datasources/local/secure_storage.dart';

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;

  RealtimeService._internal();

  StompClient? _stompClient;
  final SecureStorage _storage = SecureStorage();
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  final Map<String, List<void Function(Map<String, dynamic>)>>
      _destinationCallbacks = {};
  final Set<String> _activeDestinations = <String>{};
  final List<Map<String, String>> _pendingMessages = [];

  bool _isConnecting = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  Completer<void>? _connectCompleter;

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  bool get isConnected => _stompClient?.isActive ?? false;

  Future<void> init() async {
    try {
      final token = await _storage.getToken();
      if (token != null) {
        await connect();
      }
    } catch (e) {
      debugPrint('[RealtimeService] init failed: $e');
    }
  }

  Future<void> connect({void Function()? onConnected}) async {
    final token = await _storage.getToken();
    if (token == null) {
      debugPrint('[RealtimeService] No auth token available for connect.');
      return;
    }

    if (_stompClient?.isActive == true) {
      onConnected?.call();
      return;
    }

    if (_isConnecting) {
      await _connectCompleter?.future;
      onConnected?.call();
      return;
    }

    _connectCompleter = Completer<void>();
    _connect(token, onConnected: onConnected);
    return _connectCompleter!.future;
  }

  void _connect(String token, {void Function()? onConnected}) {
    if (_isConnecting || _stompClient?.isActive == true) return;
    _isConnecting = true;
    _reconnectTimer?.cancel();
    _activeDestinations.clear();

    _stompClient = StompClient(
      config: StompConfig(
        url: Endpoints.getWebSocketUrl(),
        onConnect: (frame) {
          _reconnectAttempts = 0;
          _isConnecting = false;
          debugPrint('[RealtimeService] STOMP connected. Restoring subscriptions.');
          _restoreSubscriptions();
          _flushPendingMessages();
          onConnected?.call();
          if (!(_connectCompleter?.isCompleted ?? false)) {
            _connectCompleter?.complete();
          }
          _connectCompleter = null;
        },
        onWebSocketError: (error) {
          debugPrint('[RealtimeService] WebSocket error: $error');
          _handleDisconnect(token, error);
        },
        onStompError: (error) {
          debugPrint('[RealtimeService] STOMP error: $error');
          _handleDisconnect(token, error);
        },
        onDisconnect: (frame) {
          debugPrint('[RealtimeService] STOMP disconnected: $frame');
          _handleDisconnect(token, null);
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
      ),
    );

    _stompClient?.activate();
  }

  void _handleDisconnect(String token, Object? error) {
    _isConnecting = false;
    _scheduleReconnect(token);
    if (!(_connectCompleter?.isCompleted ?? true)) {
      _connectCompleter?.completeError(error ?? 'Disconnected');
      _connectCompleter = null;
    }
  }

  void subscribe(
    String destination,
    void Function(Map<String, dynamic>) callback,
  ) {
    final callbacks = _destinationCallbacks.putIfAbsent(destination, () => []);
    callbacks.add(callback);

    if (_stompClient?.isActive == true &&
        !_activeDestinations.contains(destination)) {
      _subscribeDestination(destination);
    }
  }

  void unsubscribe(
    String destination,
    void Function(Map<String, dynamic>) callback,
  ) {
    final callbacks = _destinationCallbacks[destination];
    if (callbacks == null) return;

    callbacks.remove(callback);
    if (callbacks.isEmpty) {
      _destinationCallbacks.remove(destination);
      _activeDestinations.remove(destination);
      _tryUnsubscribeDestination(destination);
    }
  }

  void _subscribeDestination(String destination) {
    if (_stompClient?.isActive != true ||
        _activeDestinations.contains(destination)) {
      return;
    }

    _stompClient?.subscribe(
      destination: destination,
      callback: (frame) => _handleFrame(frame, destination),
    );
    _activeDestinations.add(destination);
    debugPrint('[RealtimeService] Subscribed to $destination');
  }

  void _tryUnsubscribeDestination(String destination) {
    if (_stompClient == null) return;
    try {
      (_stompClient as dynamic).unsubscribe(destination);
      debugPrint('[RealtimeService] Unsubscribed from $destination');
    } catch (_) {
      // Some STOMP client implementations may not expose unsubscribe by destination.
    }
  }

  void _restoreSubscriptions() {
    if (_stompClient?.isActive != true) return;
    final destinations = _destinationCallbacks.keys.toList();
    for (final destination in destinations) {
      if (!_activeDestinations.contains(destination)) {
        _subscribeDestination(destination);
      }
    }
  }

  void _handleFrame(StompFrame frame, String destination) {
    if (frame.body == null || frame.body!.isEmpty) return;

    try {
      final payload = jsonDecode(frame.body!) as Map<String, dynamic>;
      if (destination.startsWith('/topic/notifications')) {
        _notificationController.add(payload);
      }

      final callbacks = _destinationCallbacks[destination];
      if (callbacks != null) {
        for (final callback in List.of(callbacks)) {
          try {
            callback(payload);
          } catch (error, stack) {
            debugPrint(
              '[RealtimeService] callback error for $destination: $error\n$stack',
            );
          }
        }
      }
    } catch (error, stack) {
      debugPrint('[RealtimeService] Failed to parse STOMP frame: $error\n$stack');
    }
  }

  void send(String destination, Map<String, dynamic> payload) async {
    final body = jsonEncode(payload);
    if (_stompClient?.isActive == true) {
      _stompClient?.send(destination: destination, body: body);
      return;
    }

    _pendingMessages.add({'destination': destination, 'body': body});
    await connect();
  }

  void _flushPendingMessages() {
    if (_stompClient?.isActive != true || _pendingMessages.isEmpty) return;
    final queue = List<Map<String, String>>.from(_pendingMessages);
    _pendingMessages.clear();
    for (final entry in queue) {
      _stompClient?.send(
        destination: entry['destination']!,
        body: entry['body']!,
      );
    }
  }

  void _scheduleReconnect(String token) {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    final delaySeconds = min(30, 1 << (_reconnectAttempts - 1));
    debugPrint(
      '[RealtimeService] Reconnecting in $delaySeconds seconds (attempt $_reconnectAttempts)',
    );
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      final authToken = await _storage.getToken();
      if (authToken != null) {
        _connect(authToken);
      }
    });
  }

  void disconnect() {
    debugPrint('[RealtimeService] Disconnecting...');
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _stompClient?.deactivate();
    _stompClient = null;
    _isConnecting = false;
    _activeDestinations.clear();
    _destinationCallbacks.clear();
    _pendingMessages.clear();
    if (!_notificationController.isClosed) {
      _notificationController.close();
    }
    // Reset completer
    if (!(_connectCompleter?.isCompleted ?? true)) {
      _connectCompleter?.completeError('Service disconnected');
    }
    _connectCompleter = null;
    debugPrint('[RealtimeService] Disconnected and cleaned up');
  }
  
  /// Reset the service for new session (useful after logout/login)
  void reset() {
    disconnect();
    // Service streams are closed on disconnect and will be recreated on next init
  }
}
