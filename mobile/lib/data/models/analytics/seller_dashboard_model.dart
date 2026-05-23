import 'top_property_model.dart';

class SellerDashboardModel {
  final int totalListings;
  final int activeListings;
  final int inactiveListings;
  final int totalViews;
  final int totalMessages;
  final int totalVisits;
  final double conversionRate;
  final List<TopPropertyModel> topProperties;

  SellerDashboardModel({
    required this.totalListings,
    required this.activeListings,
    required this.inactiveListings,
    required this.totalViews,
    required this.totalMessages,
    required this.totalVisits,
    required this.conversionRate,
    required this.topProperties,
  });

  factory SellerDashboardModel.fromJson(Map<String, dynamic> json) {
    final totalListings = _parseInt(json['totalListings'] ?? json['totalListing']);
    final activeListings = _parseInt(json['activeListings']);
    final totalViews = _parseInt(json['totalViews']);
    final totalMessages = _parseInt(json['totalMessages']);
    final totalVisits = _parseInt(json['totalVisitRequests'] ?? json['totalVisits']);
    final conversionRate = _parseDouble(json['conversionRate']);
    final calculatedInactive = (totalListings - activeListings).clamp(0, totalListings);

    final propertiesJson = json['topPerformingProperties'] ?? json['topProperties'] ?? [];
    final topProperties = (propertiesJson as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(TopPropertyModel.fromJson)
            .toList() ??
        [];

    return SellerDashboardModel(
      totalListings: totalListings,
      activeListings: activeListings,
      inactiveListings: _parseInt(json['inactiveListings']) == 0
          ? calculatedInactive
          : _parseInt(json['inactiveListings']),
      totalViews: totalViews,
      totalMessages: totalMessages,
      totalVisits: totalVisits,
      conversionRate: conversionRate,
      topProperties: topProperties,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalListings': totalListings,
        'activeListings': activeListings,
        'inactiveListings': inactiveListings,
        'totalViews': totalViews,
        'totalMessages': totalMessages,
        'totalVisits': totalVisits,
        'conversionRate': conversionRate,
        'topPerformingProperties': topProperties.map((e) => e.toJson()).toList(),
      };

    factory SellerDashboardModel.empty() => SellerDashboardModel(
          totalListings: 0,
          activeListings: 0,
          inactiveListings: 0,
          totalViews: 0,
          totalMessages: 0,
          totalVisits: 0,
          conversionRate: 0.0,
          topProperties: [],
        );

  static int _parseInt(dynamic source) {
    if (source == null) return 0;
    if (source is int) return source;
    if (source is double) return source.round();
    if (source is String) {
      return int.tryParse(source) ?? double.tryParse(source)?.round() ?? 0;
    }
    return 0;
  }

  static double _parseDouble(dynamic source) {
    if (source == null) return 0.0;
    if (source is double) return source;
    if (source is int) return source.toDouble();
    if (source is String) {
      return double.tryParse(source) ?? 0.0;
    }
    return 0.0;
  }
}
