class RegisterReq {
  String? email;
  String? password;
  String? firstLastName;
  String? phone;
  bool verify;
  bool isActive;
  String status;

  RegisterReq({
    this.email,
    this.password,
    this.firstLastName,
    this.phone,
    this.verify = false,
    this.isActive = false,
    this.status = 'tasker',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstLastName': firstLastName,
      'phoneNumber': phone,
      'verify': verify,
      'status': status,
      'isActive': isActive,
    };
  }
}
