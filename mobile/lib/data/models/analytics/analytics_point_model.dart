class AnalyticsPointModel {
  final DateTime date;
  final double value;

  const AnalyticsPointModel({
    required this.date,
    required this.value,
  });

  factory AnalyticsPointModel.fromJson(Map<String, dynamic> json) {
    final dateString = json['date']?.toString() ?? '';
    final parsedDate = DateTime.tryParse(dateString) ?? DateTime.now();
    final rawValue = json['value'] ??
        json['viewCount'] ??
        json['messageCount'] ??
        json['visitCount'] ??
        json['visitRequestCount'] ??
        json['count'];
    return AnalyticsPointModel(
      date: parsedDate,
      value: _parseDouble(rawValue),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'value': value,
      };

  static double _parseDouble(dynamic source) {
    if (source == null) return 0.0;
    if (source is num) return source.toDouble();
    if (source is String) {
      return double.tryParse(source) ?? 0.0;
    }
    return 0.0;
  }
}
