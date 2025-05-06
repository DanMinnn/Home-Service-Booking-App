class ServiceItem {
  int? id;
  String? name;
  String? description;
  String? icon;
  double? price;
  bool? isActive;

  ServiceItem({
    this.id,
    this.name,
    this.description,
    this.icon,
    this.price,
    this.isActive,
  });

  ServiceItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    icon = json['icon'];
    price = (json['basePrice'] as num).toDouble();
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['icon'] = icon;
    data['basePrice'] = price;
    data['isActive'] = isActive;
    return data;
  }
}
