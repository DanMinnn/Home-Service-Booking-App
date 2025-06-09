class UpdateTasker {
  String? name;
  String? urlAvtar;
  String? address;

  UpdateTasker({this.name, this.urlAvtar, this.address});

  Map<String, dynamic> toJson() {
    return {
      'firstLastName': name,
      'profileImage': urlAvtar,
      'address': address,
    };
  }
}
