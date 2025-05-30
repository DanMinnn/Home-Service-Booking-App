class FCMTokenReq {
  String token;
  int? userId;
  int? taskerId;
  String? deviceId;

  FCMTokenReq({
    required this.token,
    this.userId,
    this.taskerId,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
      'taskerId': taskerId,
      'deviceId': deviceId,
    };
  }
}
