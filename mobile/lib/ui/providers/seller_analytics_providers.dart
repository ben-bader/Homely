import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homely/data/models/analytics/analytics_point_model.dart';
import 'package:homely/data/models/analytics/seller_dashboard_model.dart';
import 'package:homely/infrastructure/services/seller_analytics_service.dart';

final sellerAnalyticsServiceProvider = Provider<SellerAnalyticsService>(
  (ref) => SellerAnalyticsService(),
);

final sellerAnalyticsProvider = FutureProvider<SellerDashboardModel>((ref) {
  return ref.read(sellerAnalyticsServiceProvider).fetchDashboard();
});

final sellerAnalyticsViewsOverTimeProvider = FutureProvider<List<AnalyticsPointModel>>(
  (ref) => ref.read(sellerAnalyticsServiceProvider).fetchViewsOverTime(),
);

final sellerAnalyticsMessagesOverTimeProvider = FutureProvider<List<AnalyticsPointModel>>(
  (ref) => ref.read(sellerAnalyticsServiceProvider).fetchMessagesOverTime(),
);

final sellerAnalyticsVisitsOverTimeProvider = FutureProvider<List<AnalyticsPointModel>>(
  (ref) => ref.read(sellerAnalyticsServiceProvider).fetchVisitsOverTime(),
);
