import 'package:home_service/modules/booking/models/booking_w_tasker.dart';

import '../../../models/user.dart';

class BookingData {
  // Service details
  final int? serviceId;
  final String? serviceName;
  final int? packageId;
  final String? packageName;
  final String? packageDescription;
  final String? variantName;
  final String? variantDescription;
  final double? basePrice;
  final String formattedPrice;

  // Add-on details
  final List<String> addOns;

  // Date and time
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String? dateTime;

  // Location
  final String? address;
  final double? latitude;
  final double? longitude;

  // Additional info
  final String? notes;

  // Payment method
  final String? paymentMethod;

  // User profile information
  final User? user;

  // Optional fields for cooking service
  final int? numberOfPeople;
  final int? numberOfCourses;
  final List<String>? coursesNames;
  final String? preferStyle;

  //booking with favorite tasker
  final BookingWTasker? tasker;

  BookingData({
    this.serviceId,
    this.serviceName,
    this.packageId,
    this.packageName,
    this.packageDescription,
    this.basePrice,
    this.formattedPrice = '',
    this.addOns = const [],
    this.dateTime,
    this.scheduledStart,
    this.scheduledEnd,
    this.address,
    this.notes,
    this.paymentMethod,
    this.variantName,
    this.variantDescription,
    this.user,
    this.numberOfPeople,
    this.numberOfCourses,
    this.coursesNames,
    this.preferStyle,
    this.latitude,
    this.longitude,
    this.tasker,
  });

  BookingData copyWith({
    int? serviceId,
    String? serviceName,
    int? packageId,
    String? packageName,
    String? packageDescription,
    double? basePrice,
    String? formattedPrice,
    List<String>? addOns,
    String? dateTime,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
    String? address,
    String? notes,
    String? paymentMethod,
    String? variantName,
    String? variantDescription,
    User? user,
    int? numberOfPeople,
    int? numberOfCourses,
    List<String>? coursesNames,
    String? preferStyle,
    double? latitude,
    double? longitude,
    BookingWTasker? tasker,
  }) {
    return BookingData(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      packageDescription: packageDescription ?? this.packageDescription,
      basePrice: basePrice ?? this.basePrice,
      formattedPrice: formattedPrice ?? this.formattedPrice,
      addOns: addOns ?? this.addOns,
      dateTime: dateTime ?? this.dateTime,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      variantName: variantName ?? this.variantName,
      variantDescription: variantDescription ?? this.variantDescription,
      user: user ?? this.user,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      numberOfCourses: numberOfCourses ?? this.numberOfCourses,
      coursesNames: coursesNames ?? this.coursesNames,
      preferStyle: preferStyle ?? this.preferStyle,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tasker: tasker ?? this.tasker,
    );
  }

  // Calculate the total price including add-ons if needed
  double get totalPrice {
    double total = basePrice ?? 0;
    // Add calculation logic for add-ons if they have prices
    return total;
  }

  // Helper method to format the total price
  String get formattedTotalPrice {
    // Implement your price formatting logic
    return '${totalPrice.toString()} VND';
  }

  // Check if booking data is complete enough to proceed
  bool get isValid {
    return serviceId != null &&
        packageName != null &&
        dateTime != null &&
        address != null;
  }
}
