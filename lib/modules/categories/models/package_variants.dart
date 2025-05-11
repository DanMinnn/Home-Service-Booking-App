class PackageVariant {
  int? id;
  String? name;
  String? description;
  double? additionalPrice;

  PackageVariant({
    this.id,
    this.name,
    this.description,
    this.additionalPrice,
  });

  factory PackageVariant.fromJson(Map<String, dynamic> json) {
    return PackageVariant(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble(),
    );
  }
}
