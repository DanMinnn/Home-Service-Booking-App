class TaskerServiceResponse {
  final int serviceId;
  final String serviceName;
  final String icon;

  TaskerServiceResponse({
    required this.serviceId,
    required this.serviceName,
    required this.icon,
  });

  factory TaskerServiceResponse.fromJson(Map<String, dynamic> json) {
    return TaskerServiceResponse(
      serviceId: json['serviceId'] as int,
      serviceName: json['serviceName'] as String,
      icon: json['icon'] as String,
    );
  }
}
