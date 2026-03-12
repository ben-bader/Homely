class BoostPackage {
  final int id;
  final String name;
  final String description;
  final int durationDays;
  final double price;

  const BoostPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.durationDays,
    required this.price,
  });

  factory BoostPackage.fromJson(Map<String, dynamic> json) => BoostPackage(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'durationDays': durationDays,
    'price': price,
  };
}
