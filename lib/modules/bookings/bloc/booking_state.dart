import 'package:equatable/equatable.dart';
import 'package:home_service_admin/modules/bookings/models/booking.dart';
import 'package:home_service_admin/modules/bookings/models/filter_sort_model.dart';

import '../../../models/paging_data.dart';

abstract class BookingState extends Equatable {
  final BookingFilterModel filterModel;
  final BookingSortModel sortModel;

  const BookingState({
    this.filterModel = const BookingFilterModel(),
    this.sortModel = const BookingSortModel(),
  });

  @override
  List<Object?> get props => [filterModel, sortModel];
}

class BookingInitial extends BookingState {
  const BookingInitial() : super();
}

class BookingLoading extends BookingState {
  const BookingLoading({
    super.filterModel,
    super.sortModel,
  });
}

class BookingLoaded extends BookingState {
  final List<Booking> bookings;
  final PaginationMetadata metadata;

  const BookingLoaded(
    this.bookings, {
    required this.metadata,
    super.filterModel,
    super.sortModel,
  });

  @override
  List<Object?> get props => [bookings, metadata, filterModel, sortModel];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({
    required this.message,
    super.filterModel,
    super.sortModel,
  });

  @override
  List<Object?> get props => [message, filterModel, sortModel];
}
