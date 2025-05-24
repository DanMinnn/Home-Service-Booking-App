class ServiceItem {
  int id;
  String name;
  String description;
  String icon;
  bool isActive;

  ServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isActive,
  });

  ServiceItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'] ?? '',
        icon = json['icon'],
        isActive = json['isActive'];
}
