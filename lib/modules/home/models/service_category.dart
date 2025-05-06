import 'package:home_service/modules/home/models/service_item.dart';

class ServiceCategory {
  int? id;
  String? name;
  bool? isActive;
  List<ServiceItem>? serviceItems;

  ServiceCategory({
    this.id,
    this.name,
    this.isActive,
    this.serviceItems,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    List<ServiceItem> serviceItems = [];
    serviceItems = (json['services'] as List)
        .map((e) => ServiceItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return ServiceCategory(
      id: json['id'],
      name: json['name'],
      serviceItems: serviceItems,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['active'] = isActive;
    data['services'] = serviceItems;
    return data;
  }
}
