class ChatbotDTO {
  int? userId;
  String? question;
  String? response;
  String? sentAt;

  ChatbotDTO({this.userId, this.question, this.response, this.sentAt});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['query'] = question;
    data['response'] = response;
    return data;
  }

  ChatbotDTO.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    question = json['query'];
    response = json['response'];
    sentAt = json['sentAt'];
  }
}
