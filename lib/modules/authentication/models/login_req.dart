class LoginReq {
  String email;
  String password;
  String? platform;
  String? deviceToken;

  LoginReq(
      {required this.email,
      required this.password,
      this.platform = 'CLIENT',
      this.deviceToken});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'platform': platform,
      'device_token': deviceToken,
    };
  }
}
