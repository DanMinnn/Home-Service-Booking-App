class Post {
  int? bookingId;
  String? serviceName;
  DateTime? scheduledStart;
  DateTime? scheduledEnd;
  String? status;
  double? price;
  String? address;
  int? duration;
  String? paymentStatus;
  int? taskerId;
  String? taskerName;
  String? taskerImage;
  DateTime? completedAt;

  Post({
    this.bookingId,
    this.serviceName,
    this.scheduledStart,
    this.scheduledEnd,
    this.status,
    this.price,
    this.address,
    this.duration,
    this.paymentStatus,
    this.taskerId,
    this.taskerName,
    this.taskerImage,
    this.completedAt,
  });

  Post.fromJson(Map<String, dynamic> json) {
    bookingId = json['bookingId'];
    serviceName = json['serviceName'];
    scheduledStart = json['scheduledStart'] != null
        ? DateTime.parse(json['scheduledStart'])
        : null;
    scheduledEnd = json['scheduledEnd'] != null
        ? DateTime.parse(json['scheduledEnd'])
        : null;
    status = json['status'];
    price = (json['totalPrice'] as num?)?.toDouble();
    address = json['address'];
    duration = json['duration'];
    paymentStatus = json['paymentStatus'];
    taskerId = json['taskerId'];
    taskerName = json['taskerName'];
    taskerImage = json['taskerImage'];
    completedAt = json['completedAt'] != null
        ? DateTime.parse(json['completedAt'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bookingId'] = bookingId;
    data['serviceName'] = serviceName;
    data['scheduledStart'] = scheduledStart?.toIso8601String();
    data['scheduledEnd'] = scheduledEnd?.toIso8601String();
    data['status'] = status;
    data['price'] = price;
    data['address'] = address;
    data['duration'] = duration;
    data['paymentStatus'] = paymentStatus;
    return data;
  }
}
