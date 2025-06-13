import 'package:intl/intl.dart';

class DashboardResponse {
  final int status;
  final String message;
  final DashboardData data;

  DashboardResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      status: json['status'],
      message: json['message'],
      data: DashboardData.fromJson(json['data']),
    );
  }
}

class DashboardData {
  final CompletedTasks completedTasks;
  final int pendingBookingsCount;
  final UserRegistrations userRegistrations;
  final List<BookingTrend> bookingTrends;
  final List<TopService> topServices;
  final List<BookingStatusDistribution> bookingStatusDistribution;
  final List<RecentBooking> recentBookings;
  final List<TopTasker> topTaskers;
  final RevenueServices? revenueServices;

  DashboardData({
    required this.completedTasks,
    required this.pendingBookingsCount,
    required this.userRegistrations,
    required this.bookingTrends,
    required this.topServices,
    required this.bookingStatusDistribution,
    required this.recentBookings,
    required this.topTaskers,
    this.revenueServices,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      completedTasks: CompletedTasks.fromJson(json['completedTasks'] ?? {}),
      pendingBookingsCount: json['pendingBookingsCount'] ?? 0,
      userRegistrations:
          UserRegistrations.fromJson(json['userRegistrations'] ?? {}),
      bookingTrends: ((json['bookingTrends'] as List?) ?? [])
          .map((e) => BookingTrend.fromJson(e))
          .toList(),
      topServices: ((json['topServices'] as List?) ?? [])
          .map((e) => TopService.fromJson(e))
          .toList(),
      bookingStatusDistribution:
          ((json['bookingStatusDistribution'] as List?) ?? [])
              .map((e) => BookingStatusDistribution.fromJson(e))
              .toList(),
      recentBookings: ((json['recentBookings'] as List?) ?? [])
          .map((e) => RecentBooking.fromJson(e))
          .toList(),
      topTaskers: ((json['topTaskers'] as List?) ?? [])
          .map((e) => TopTasker.fromJson(e))
          .toList(),
      revenueServices: json['revenueServices'] != null
          ? RevenueServices.fromJson(json['revenueServices'])
          : null,
    );
  }
}

class CompletedTasks {
  final int totalCompletedTasks;
  final int completedTasksToday;
  final int completedTasksThisWeek;
  final int completedTasksThisMonth;

  CompletedTasks({
    required this.totalCompletedTasks,
    required this.completedTasksToday,
    required this.completedTasksThisWeek,
    required this.completedTasksThisMonth,
  });

  factory CompletedTasks.fromJson(Map<String, dynamic> json) {
    return CompletedTasks(
      totalCompletedTasks: json['totalCompletedTasks'] ?? 0,
      completedTasksToday: json['completedTasksToday'] ?? 0,
      completedTasksThisWeek: json['completedTasksThisWeek'] ?? 0,
      completedTasksThisMonth: json['completedTasksThisMonth'] ?? 0,
    );
  }
}

class UserRegistrations {
  final int totalUsers;
  final int totalClients;
  final int totalTaskers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int newUsersThisMonth;

  UserRegistrations({
    required this.totalUsers,
    required this.totalClients,
    required this.totalTaskers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
    required this.newUsersThisMonth,
  });

  factory UserRegistrations.fromJson(Map<String, dynamic> json) {
    return UserRegistrations(
      totalUsers: json['totalUsers'] ?? 0,
      totalClients: json['totalClients'] ?? 0,
      totalTaskers: json['totalTaskers'] ?? 0,
      newUsersToday: json['newUsersToday'] ?? 0,
      newUsersThisWeek: json['newUsersThisWeek'] ?? 0,
      newUsersThisMonth: json['newUsersThisMonth'] ?? 0,
    );
  }
}

class BookingTrend {
  final String timePoint;
  final int count;
  final String timestamp;

  BookingTrend({
    required this.timePoint,
    required this.count,
    required this.timestamp,
  });

  factory BookingTrend.fromJson(Map<String, dynamic> json) {
    return BookingTrend(
      timePoint: json['timePoint'] ?? '',
      count: json['count'] ?? 0,
      timestamp: json['timestamp'] ?? '',
    );
  }

  DateTime get date =>
      timestamp.isEmpty ? DateTime.now() : DateTime.parse(timestamp);
  String get formattedDate => DateFormat('MMM dd').format(date);
}

class TopService {
  final int serviceId;
  final String serviceName;
  final String categoryName;
  final int bookingCount;

  TopService({
    required this.serviceId,
    required this.serviceName,
    required this.categoryName,
    required this.bookingCount,
  });

  factory TopService.fromJson(Map<String, dynamic> json) {
    return TopService(
      serviceId: json['serviceId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      bookingCount: json['bookingCount'] ?? 0,
    );
  }
}

class BookingStatusDistribution {
  final String status;
  final int count;

  BookingStatusDistribution({
    required this.status,
    required this.count,
  });

  factory BookingStatusDistribution.fromJson(Map<String, dynamic> json) {
    return BookingStatusDistribution(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class RecentBooking {
  final int bookingId;
  final int serviceId;
  final int userId;
  final int taskerId;
  final String scheduledStart;
  final String scheduledEnd;
  final int duration;
  final String status;
  final Map<String, dynamic> taskDetails;
  final double totalPrice;
  final String? notes;
  final String username;
  final String cancelBy;
  final String? cancelReason;
  final String phoneNumber;
  final String serviceName;
  final String taskerName;
  final String taskerPhone;
  final String? taskerImage;
  final String paymentStatus;
  final String address;
  final double latitude;
  final double longitude;
  final String? completedAt;

  RecentBooking({
    required this.bookingId,
    required this.serviceId,
    required this.userId,
    required this.taskerId,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.duration,
    required this.status,
    required this.taskDetails,
    required this.totalPrice,
    this.notes,
    required this.username,
    required this.cancelBy,
    this.cancelReason,
    required this.phoneNumber,
    required this.serviceName,
    required this.taskerName,
    required this.taskerPhone,
    this.taskerImage,
    required this.paymentStatus,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.completedAt,
  });

  factory RecentBooking.fromJson(Map<String, dynamic> json) {
    return RecentBooking(
      bookingId: json['bookingId'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      userId: json['userId'] ?? 0,
      taskerId: json['taskerId'] ?? 0,
      scheduledStart: json['scheduledStart'] ?? '',
      scheduledEnd: json['scheduledEnd'] ?? '',
      duration: json['duration'] ?? 0,
      status: json['status'] ?? '',
      taskDetails: json['taskDetails'] is Map<String, dynamic>
          ? json['taskDetails']
          : {},
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      notes: json['notes'],
      username: json['username'] ?? '',
      cancelBy: json['cancelBy'] ?? '',
      cancelReason: json['cancelReason'],
      phoneNumber: json['phoneNumber'] ?? '',
      serviceName: json['serviceName'] ?? '',
      taskerName: json['taskerName'] ?? '',
      taskerPhone: json['taskerPhone'] ?? '',
      taskerImage: json['taskerImage'],
      paymentStatus: json['paymentStatus'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      completedAt: json['completedAt'],
    );
  }

  DateTime get scheduledDateTime =>
      scheduledStart.isEmpty ? DateTime.now() : DateTime.parse(scheduledStart);

  String get formattedScheduledTime =>
      DateFormat('MMM dd, yyyy HH:mm').format(scheduledDateTime);
}

class TopTasker {
  final int taskerId;
  final String taskerName;
  final String? profileImage;
  final double reputationScore;
  final int completedTasksCount;

  TopTasker({
    required this.taskerId,
    required this.taskerName,
    this.profileImage,
    required this.reputationScore,
    required this.completedTasksCount,
  });

  factory TopTasker.fromJson(Map<String, dynamic> json) {
    return TopTasker(
      taskerId: json['taskerId'] ?? 0,
      taskerName: json['taskerName'] ?? '',
      profileImage: json['profileImage'],
      reputationScore: (json['reputationScore'] ?? 0).toDouble(),
      completedTasksCount: json['completedTasksCount'] ?? 0,
    );
  }
}

class RevenueServices {
  final List<ServiceRevenue> totalRevenues;
  final List<ServiceRevenue> totalRevenuesToday;
  final List<ServiceRevenue> totalRevenuesThisWeek;
  final List<ServiceRevenue> totalRevenuesThisMonth;

  RevenueServices({
    required this.totalRevenues,
    required this.totalRevenuesToday,
    required this.totalRevenuesThisWeek,
    required this.totalRevenuesThisMonth,
  });

  factory RevenueServices.fromJson(Map<String, dynamic> json) {
    return RevenueServices(
      totalRevenues: ((json['totalRevenues'] as List?) ?? [])
          .map((e) => ServiceRevenue.fromJson(e))
          .toList(),
      totalRevenuesToday: ((json['totalRevenuesToday'] as List?) ?? [])
          .map((e) => ServiceRevenue.fromJson(e))
          .toList(),
      totalRevenuesThisWeek: ((json['totalRevenuesThisWeek'] as List?) ?? [])
          .map((e) => ServiceRevenue.fromJson(e))
          .toList(),
      totalRevenuesThisMonth: ((json['totalRevenuesThisMonth'] as List?) ?? [])
          .map((e) => ServiceRevenue.fromJson(e))
          .toList(),
    );
  }

  double get totalRevenueSum =>
      totalRevenues.fold(0, (sum, item) => sum + item.totalRevenue);

  double get totalRevenueTodaySum =>
      totalRevenuesToday.fold(0, (sum, item) => sum + item.totalRevenue);

  double get totalRevenueThisWeekSum =>
      totalRevenuesThisWeek.fold(0, (sum, item) => sum + item.totalRevenue);

  double get totalRevenueThisMonthSum =>
      totalRevenuesThisMonth.fold(0, (sum, item) => sum + item.totalRevenue);
}

class ServiceRevenue {
  final int serviceId;
  final String serviceName;
  final String categoryName;
  final double totalRevenue;
  final int bookingCount;

  ServiceRevenue({
    required this.serviceId,
    required this.serviceName,
    required this.categoryName,
    required this.totalRevenue,
    required this.bookingCount,
  });

  factory ServiceRevenue.fromJson(Map<String, dynamic> json) {
    return ServiceRevenue(
      serviceId: json['serviceId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      bookingCount: json['bookingCount'] ?? 0,
    );
  }
}