class LoginData {
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final bool? hasUsernamePassword;
  final bool? isNew;

  LoginData({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.hasUsernamePassword,
    this.isNew,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      tokenType: json['tokenType'] as String?,
      expiresIn: json['expiresIn'] as int?,
      hasUsernamePassword: json['hasUsernamePassword'] as bool?,
      isNew: json['new'] as bool?,
    );
  }
}
