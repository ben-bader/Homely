import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';

final reportReasonsProvider = FutureProvider<List<String>>((ref) async {
  final data = await ApiClient.get('/report-reasons');
  if (data is List) {
    return data.map((e) => e['reason'] as String).toList();
  }
  return [];
});
