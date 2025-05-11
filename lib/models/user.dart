class User {
  int? id;
  String? name;
  String? email;
  String? phone;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['firstLastName'];
    email = json['email'];
    phone = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstLastName'] = name;
    data['email'] = email;
    data['phoneNumber'] = phone;
    return data;
  }
}
