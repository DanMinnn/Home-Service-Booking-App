class Services {
  int id;
  String name;
  String description;
  String icon;
  bool isActive;

  Services({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isActive,
  });

  Services.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        icon = json['icon'],
        isActive = json['isActive'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['icon'] = icon;
    data['isActive'] = isActive;
    return data;
  }
}
