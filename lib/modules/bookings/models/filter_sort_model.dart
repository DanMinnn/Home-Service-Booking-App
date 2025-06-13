import 'package:flutter/material.dart';

enum SortOrder { ascending, descending, none }

class BookingFilterModel {
  final String? customerSearch;
  final String? taskerSearch;
  final DateTimeRange? dateRange;
  final DateTime? selectedDate;
  final String? status;

  const BookingFilterModel({
    this.customerSearch,
    this.taskerSearch,
    this.dateRange,
    this.selectedDate,
    this.status,
  });

  BookingFilterModel copyWith({
    String? customerSearch,
    String? taskerSearch,
    DateTimeRange? dateRange,
    DateTime? selectedDate,
    String? status,
    bool clearCustomerSearch = false,
    bool clearTaskerSearch = false,
    bool clearDateRange = false,
    bool clearSelectedDate = false,
    bool clearStatus = false,
  }) {
    return BookingFilterModel(
      customerSearch:
          clearCustomerSearch ? null : (customerSearch ?? this.customerSearch),
      taskerSearch:
          clearTaskerSearch ? null : (taskerSearch ?? this.taskerSearch),
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      selectedDate:
          clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

class BookingSortModel {
  final String? field;
  final SortOrder order;

  const BookingSortModel({this.field, this.order = SortOrder.none});

  BookingSortModel copyWith({String? field, SortOrder? order}) {
    return BookingSortModel(
      field: field ?? this.field,
      order: order ?? this.order,
    );
  }
}
