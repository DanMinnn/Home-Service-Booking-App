class UpdateUser {
  String? name;
  String? urlAvtar;
  String? address;

  UpdateUser({this.name, this.urlAvtar, this.address});

  Map<String, dynamic> toJson() {
    return {
      'firstLastName': name,
      'profileImage': urlAvtar,
      'address': address,
    };
  }
}
