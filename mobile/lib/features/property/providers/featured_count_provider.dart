import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_client.dart';

final featuredCountProvider = FutureProvider<int>((ref) async {
  final data = await ApiClient.get('/featured-properties-setting');
  if (data is int) return data;
  if (data is Map && data['featuredCount'] != null) return data['featuredCount'] as int;
  return 5;
});
