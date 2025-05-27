class BookingReq {
  int? userId;
  int? serviceId;
  int? packageId;
  String? address;
  DateTime? scheduledStart;
  DateTime? scheduledEnd;
  int? duration;
  Map<String, Object>? taskDetails;
  double? totalPrice;
  String? bookingStatus;
  String? notes;
  String? cancellationReason;
  String? cancelledByType;
  bool? isRecurring;
  String? recurringPattern;
  double? longitude;
  double? latitude;
  String? methodType;

  BookingReq({
    this.userId,
    this.serviceId,
    this.packageId,
    this.address,
    this.scheduledStart,
    this.scheduledEnd,
    this.duration,
    this.taskDetails,
    this.totalPrice,
    this.bookingStatus,
    this.notes,
    this.cancellationReason,
    this.cancelledByType,
    this.isRecurring,
    this.recurringPattern,
    this.longitude,
    this.latitude,
    this.methodType,
  });

  BookingReq.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    serviceId = json['serviceId'];
    packageId = json['packageId'];
    address = json['address'];
    scheduledStart = json['scheduledStart'];
    scheduledEnd = json['scheduledEnd'];
    duration = json['durationMinutes'];
    taskDetails = json['taskDetails'] != null
        ? Map<String, Object>.from(json['taskDetails'])
        : null;
    totalPrice = json['totalPrice']?.toDouble();
    bookingStatus = json['bookingStatus'];
    notes = json['notes'];
    cancellationReason = json['cancellationReason'];
    cancelledByType = json['cancelledByType'];
    isRecurring = json['isRecurring'];
    recurringPattern = json['recurringPattern'];
    longitude = json['longitude']?.toDouble();
    latitude = json['latitude']?.toDouble();
    methodType = json['methodType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['serviceId'] = serviceId;
    data['packageId'] = packageId;
    data['address'] = address;
    data['scheduledStart'] = scheduledStart?.toIso8601String();
    data['scheduledEnd'] = scheduledEnd?.toIso8601String();
    data['durationMinutes'] = duration;
    if (taskDetails != null) {
      data['taskDetails'] = taskDetails!;
    }
    data['totalPrice'] = totalPrice;
    data['bookingStatus'] = bookingStatus;
    data['notes'] = notes;
    data['cancellationReason'] = cancellationReason;
    data['cancelledByType'] = cancelledByType;
    data['isRecurring'] = isRecurring;
    data['recurringPattern'] = recurringPattern;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['methodType'] = methodType;
    return data;
  }
}
