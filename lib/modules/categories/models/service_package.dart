import 'package:home_service/modules/categories/models/package_variants.dart';

class ServicePackages {
  int id;
  String name;
  String description;
  double basePrice;
  List<PackageVariant>? packageVariants;

  ServicePackages(this.id, this.name, this.description, this.basePrice);

  factory ServicePackages.fromJson(Map<String, dynamic> json) {
    return ServicePackages(
      json['id'] as int,
      json['name'] as String,
      json['description'] as String,
      (json['basePrice'] as num).toDouble(),
    )..packageVariants = (json['variants'] as List<dynamic>?)
        ?.map((e) => PackageVariant.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
