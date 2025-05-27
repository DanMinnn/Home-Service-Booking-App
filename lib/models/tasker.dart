import 'package:home_service_tasker/modules/services/model/service_item.dart';

class Tasker {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? profileImage;
  bool? active;
  List<ServiceItem>? services;

  Tasker({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
    this.active,
    this.services,
  });

  Tasker.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['firstLastName'];
    email = json['email'];
    phone = json['phoneNumber'];
    profileImage = json['profileImage'];
    active = json['active'];
    if (json['services'] != null) {
      services = <ServiceItem>[];
      json['services'].forEach((v) {
        services!.add(ServiceItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstLastName'] = name;
    data['email'] = email;
    data['phoneNumber'] = phone;
    data['profileImage'] = profileImage;
    data['active'] = active;

    if (services != null) {
      data['services'] = services!
          .map((service) => {
                'id': service.id,
                'name': service.name,
                'description': service.description,
                'icon': service.icon,
                'isActive': service.isActive
              })
          .toList();
    }

    return data;
  }
}
