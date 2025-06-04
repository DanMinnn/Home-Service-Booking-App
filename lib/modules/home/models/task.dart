class Task {
  int bookingId;
  int serviceId;
  int userId;
  int taskerId;
  String serviceName;
  DateTime scheduledStart;
  DateTime scheduledEnd;
  int durations;
  String status;
  Map<String, dynamic> taskDetails;
  double totalPrice;
  String address;
  String paymentStatus;
  String? notes;
  double latitude;
  double longitude;

  Task({
    required this.bookingId,
    required this.serviceId,
    required this.userId,
    required this.taskerId,
    required this.serviceName,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.durations,
    required this.status,
    required this.taskDetails,
    required this.totalPrice,
    required this.address,
    required this.paymentStatus,
    this.notes,
    required this.latitude,
    required this.longitude,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      bookingId: json['bookingId'],
      serviceId: json['serviceId'],
      userId: json['userId'],
      taskerId: json['taskerId'] ?? 0,
      serviceName: json['serviceName'],
      scheduledStart: DateTime.parse(json['scheduledStart']),
      scheduledEnd: DateTime.parse(json['scheduledEnd']),
      durations: json['duration'],
      status: json['status'],
      taskDetails: json['taskDetails'] ?? {},
      totalPrice: (json['totalPrice'] as num).toDouble(),
      address: json['address'],
      paymentStatus: json['paymentStatus'],
      notes: json['notes'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'scheduledStart': scheduledStart,
      'scheduledEnd': scheduledEnd,
      'duration': durations,
      'status': status,
      'taskDetails': taskDetails,
      'totalPrice': totalPrice,
      'address': address,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
