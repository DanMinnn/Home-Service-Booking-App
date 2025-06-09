class ReviewReq {
  int? bookingId;
  int? reviewerId;
  int? rating;
  String? comment;

  ReviewReq({
    this.bookingId,
    this.reviewerId,
    this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bookingId'] = bookingId;
    data['reviewerId'] = reviewerId;
    data['rating'] = rating;
    data['comment'] = comment;
    return data;
  }
}
