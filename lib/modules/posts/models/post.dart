class Post {
  int? bookingId;
  String? serviceName;
  String? scheduleDate;
  String? status;
  double? price;
  String? address;
  String? duration;
  String? paymentStatus;

  Post({
    this.bookingId,
    this.serviceName,
    this.scheduleDate,
    this.status,
    this.price,
    this.address,
    this.duration,
    this.paymentStatus,
  });

  Post.fromJson(Map<String, dynamic> json) {
    bookingId = json['bookingId'];
    serviceName = json['serviceName'];
    scheduleDate = json['scheduleDate'];
    status = json['status'];
    price = (json['totalPrice'] as num?)?.toDouble();
    address = json['address'];
    duration = json['duration'];
    paymentStatus = json['paymentStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bookingId'] = bookingId;
    data['serviceName'] = serviceName;
    data['scheduleDate'] = scheduleDate;
    data['status'] = status;
    data['price'] = price;
    data['address'] = address;
    data['duration'] = duration;
    data['paymentStatus'] = paymentStatus;
    return data;
  }
}
