class ChangePasswordReq {
  String token;
  String password;
  String confirmPassword;

  ChangePasswordReq({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'secretKey': token,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}
