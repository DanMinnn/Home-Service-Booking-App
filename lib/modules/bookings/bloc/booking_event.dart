import 'package:equatable/equatable.dart';
import 'package:home_service_admin/modules/bookings/models/filter_sort_model.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class FetchBookings extends BookingEvent {
  final int pageNo;
  final int pageSize;
  final DateTime? selectedDate;
  final String? status;
  final BookingFilterModel filterModel;
  final BookingSortModel sortModel;

  const FetchBookings({
    this.pageNo = 0,
    this.pageSize = 10,
    this.selectedDate,
    this.status,
    this.filterModel = const BookingFilterModel(),
    this.sortModel = const BookingSortModel(),
  });

  @override
  List<Object?> get props =>
      [pageNo, pageSize, selectedDate, status, filterModel, sortModel];
}

class ApplyFilter extends BookingEvent {
  final BookingFilterModel filterModel;

  const ApplyFilter(this.filterModel);

  @override
  List<Object?> get props => [filterModel];
}

class ApplySort extends BookingEvent {
  final String field;

  const ApplySort(this.field);

  @override
  List<Object?> get props => [field];
}

class ResetFilters extends BookingEvent {}

class ChangePage extends BookingEvent {
  final int page;

  const ChangePage(this.page);

  @override
  List<Object> get props => [page];
}

class ChangeItemsPerPage extends BookingEvent {
  final int limit;

  const ChangeItemsPerPage(this.limit);

  @override
  List<Object> get props => [limit];
}
