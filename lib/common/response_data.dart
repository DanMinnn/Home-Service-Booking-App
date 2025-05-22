class ResponseData {
  int status;
  String message;
  dynamic data;

  ResponseData({required this.status, required this.message, this.data});
}
