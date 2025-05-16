class User {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? profileImage;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['firstLastName'];
    email = json['email'];
    phone = json['phoneNumber'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstLastName'] = name;
    data['email'] = email;
    data['phoneNumber'] = phone;
    data['profileImage'] = profileImage;
    return data;
  }
}
