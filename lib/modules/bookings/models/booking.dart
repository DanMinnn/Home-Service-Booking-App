class Booking {
  final String? id;
  final String? service;
  final String? customer;
  final String? tasker;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? status;
  final String? address;

  Booking({
    this.id,
    this.service,
    this.customer,
    this.tasker,
    this.date,
    this.startTime,
    this.endTime,
    this.status,
    this.address,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      service: json['serviceName'],
      customer: json['username'],
      tasker: json['taskerName'],
      date: json['scheduledStart'].split('T')[0],
      startTime: json['scheduledStart'].split('T')[1],
      endTime: json['scheduledEnd'].split('T')[1],
      status: json['status'],
      address: json['address'],
    );
  }
}
