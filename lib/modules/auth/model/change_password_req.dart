class ChangePasswordReq {
  String secretCode;
  String newPassword;
  String confirmPassword;

  ChangePasswordReq({
    required this.secretCode,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'secretKey': secretCode,
      'password': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}
