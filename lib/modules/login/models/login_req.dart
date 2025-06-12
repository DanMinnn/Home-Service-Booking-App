class LoginReq {
  String email;
  String password;
  String platform;
  LoginReq({
    required this.email,
    required this.password,
    this.platform = 'CLIENT',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'platform': platform,
    };
  }
}
