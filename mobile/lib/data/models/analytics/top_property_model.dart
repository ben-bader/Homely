class TopPropertyModel {
  final String propertyId;
  final String title;
  final int views;
  final int messages;
  final int favorites;

  const TopPropertyModel({
    required this.propertyId,
    required this.title,
    required this.views,
    required this.messages,
    required this.favorites,
  });

  factory TopPropertyModel.fromJson(Map<String, dynamic> json) {
    return TopPropertyModel(
      propertyId: json['propertyId']?.toString() ??
          json['id']?.toString() ??
          '',
      title: json['propertyTitle']?.toString() ??
          json['title']?.toString() ??
          'Untitled property',
      views: _parseInt(json['viewCount'] ?? json['views'] ?? 0),
      messages: _parseInt(json['messageCount'] ?? json['messages'] ?? 0),
      favorites: _parseInt(json['favoriteCount'] ?? json['favorites'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'propertyId': propertyId,
        'propertyTitle': title,
        'viewCount': views,
        'messageCount': messages,
        'favoriteCount': favorites,
      };

  static int _parseInt(dynamic source) {
    if (source == null) return 0;
    if (source is int) return source;
    if (source is double) return source.round();
    if (source is String) {
      return int.tryParse(source) ?? double.tryParse(source)?.round() ?? 0;
    }
    return 0;
  }
}
