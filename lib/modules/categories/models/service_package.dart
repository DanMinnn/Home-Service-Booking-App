class ServicePackages {
  int id;
  String name;
  String description;
  double basePrice;

  ServicePackages(this.id, this.name, this.description, this.basePrice);

  factory ServicePackages.fromJson(Map<String, dynamic> json) {
    return ServicePackages(
      json['id'] as int,
      json['name'] as String,
      json['description'] as String,
      (json['basePrice'] as num).toDouble(),
    );
  }
}
