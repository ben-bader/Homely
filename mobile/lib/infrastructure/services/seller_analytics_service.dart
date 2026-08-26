import 'package:flutter/foundation.dart';
import 'package:homely/core/network/api_client.dart';
import 'package:homely/core/network/endpoints.dart';
import 'package:homely/data/models/analytics/analytics_point_model.dart';
import 'package:homely/data/models/analytics/seller_dashboard_model.dart';

class SellerAnalyticsService {
  Future<SellerDashboardModel> fetchDashboard() async {
    try {
      final response = await ApiClient.get(Endpoints.sellerAnalytics);
      if (response is Map<String, dynamic>) {
        return SellerDashboardModel.fromJson(response);
      }
      return SellerDashboardModel.empty();
    } catch (_) {
      return SellerDashboardModel.empty();
    }
  }

  Future<List<AnalyticsPointModel>> fetchViewsOverTime() async {
    return _fetchAnalyticsPoints(Endpoints.sellerAnalyticsViewsOverTime);
  }

  Future<List<AnalyticsPointModel>> fetchMessagesOverTime() async {
    return _fetchAnalyticsPoints(Endpoints.sellerAnalyticsMessagesOverTime);
  }

  Future<List<AnalyticsPointModel>> fetchVisitsOverTime() async {
    return _fetchAnalyticsPoints(Endpoints.sellerAnalyticsVisitsOverTime);
  }

  Future<List<AnalyticsPointModel>> _fetchAnalyticsPoints(String endpoint) async {
    try {
      final response = await ApiClient.get(endpoint);
      final items = response as List<dynamic>? ?? [];
      return items.whereType<Map<String, dynamic>>().map(AnalyticsPointModel.fromJson).toList();
    } catch (e) {
      debugPrint('[SellerAnalytics] failed $endpoint: $e');
      return <AnalyticsPointModel>[];
    }
  }
}
