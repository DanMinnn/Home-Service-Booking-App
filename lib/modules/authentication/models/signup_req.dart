class SignupReq {
  String? email;
  String? password;
  String? firstLastName;
  String? phone;
  bool verify;
  bool isActive;
  String type;

  SignupReq({
    this.email,
    this.password,
    this.firstLastName,
    this.phone,
    this.verify = false,
    this.isActive = false,
    this.type = 'customer',
  });

  //create an instance from JSON
  SignupReq.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        password = json['password'],
        firstLastName = json['firstLastName'],
        phone = json['phoneNumber'],
        verify = json['verify'] ?? false,
        type = json['type'] ?? 'customer',
        isActive = json['isActive'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstLastName': firstLastName,
      'phoneNumber': phone,
      'verify': verify,
      'type': type,
      'isActive': isActive,
    };
  }
}
