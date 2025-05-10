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
  final String? dateTime;

  // Location
  final String? address;

  // Additional info
  final String? notes;

  // Payment method
  final String? paymentMethod;

  // User profile information
  //final User? user;

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
    this.address,
    this.notes,
    this.paymentMethod,
    this.variantName,
    this.variantDescription,
    //this.user,
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
    String? address,
    String? notes,
    String? paymentMethod,
    String? variantName,
    String? variantDescription,
    //User? user,
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
      address: address ?? this.address,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      variantName: variantName ?? this.variantName,
      variantDescription: variantDescription ?? this.variantDescription,
      //user: user ?? this.user,
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
