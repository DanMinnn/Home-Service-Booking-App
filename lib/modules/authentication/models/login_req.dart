class LoginReq {
  String email;
  String password;
  String? platform;
  String? deviceToken;

  LoginReq(
      {required this.email,
      required this.password,
      this.platform = 'MOBILE',
      this.deviceToken});

  LoginReq.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        password = json['password'],
        platform = json['platform'] ?? 'MOBILE',
        deviceToken = json['device_token'];

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'platform': platform,
      'device_token': deviceToken,
    };
  }
}
