class BoostPackage {
  final String id;
  final String name;
  final String description;
  final int durationDays;
  final double price;
  final String currency;

  BoostPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.price,
    required this.currency,
  });

  factory BoostPackage.fromJson(Map<String, dynamic> json) {
    return BoostPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
    );
  }
}
