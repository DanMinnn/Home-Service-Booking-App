import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/bookings/bloc/booking_event.dart';
import 'package:home_service_admin/modules/bookings/bloc/booking_state.dart';
import 'package:home_service_admin/modules/bookings/models/filter_sort_model.dart';
import 'package:home_service_admin/modules/bookings/repo/booking_repo.dart';

import '../../../models/paging_data.dart';
import '../models/booking.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepo bookingRepo;

  BookingBloc({required this.bookingRepo}) : super(BookingInitial()) {
    on<FetchBookings>(_onBookingFetch);
    on<ApplyFilter>(_onApplyFilter);
    on<ApplySort>(_onApplySort);
    on<ResetFilters>(_onResetFilters);
    on<ChangePage>(_onChangePage);
    on<ChangeItemsPerPage>(_onChangeItemsPerPage);
  }

  Future<void> _onBookingFetch(
      FetchBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading(
      filterModel: event.filterModel,
      sortModel: event.sortModel,
    ));

    try {
      final result = await bookingRepo.getAllBookings(
        pageNo: event.pageNo,
        pageSize: event.pageSize,
        selectedDate: event.filterModel.selectedDate?.toString().split(' ')[0],
        status: event.filterModel.status,
        customerSearch: event.filterModel.customerSearch,
        taskerSearch: event.filterModel.taskerSearch,
        sortField: event.sortModel.field,
        sortOrder: event.sortModel.order == SortOrder.ascending
            ? 'asc'
            : event.sortModel.order == SortOrder.descending
                ? 'desc'
                : null,
      );

      final bookings = result['bookings'] as List<Booking>;
      final metadata = result['metadata'] as PaginationMetadata;

      emit(BookingLoaded(
        bookings,
        metadata: metadata,
        filterModel: event.filterModel,
        sortModel: event.sortModel,
      ));
    } catch (e) {
      emit(BookingError(
        message: e.toString(),
        filterModel: event.filterModel,
        sortModel: event.sortModel,
      ));
    }
  }

  void _onApplyFilter(ApplyFilter event, Emitter<BookingState> emit) {
    final currentState = state;

    add(FetchBookings(
      pageNo: 0, // Reset to first page when filtering
      filterModel: event.filterModel,
      sortModel: currentState.sortModel,
    ));
  }

  void _onApplySort(ApplySort event, Emitter<BookingState> emit) {
    final currentState = state;
    final currentSortModel = currentState.sortModel;

    // Toggle sort order if the same field is clicked
    SortOrder newOrder = SortOrder.ascending;
    if (event.field == currentSortModel.field) {
      if (currentSortModel.order == SortOrder.ascending) {
        newOrder = SortOrder.descending;
      } else if (currentSortModel.order == SortOrder.descending) {
        newOrder = SortOrder.none;
      }
    }

    final sortModel = BookingSortModel(
      field: newOrder == SortOrder.none ? null : event.field,
      order: newOrder,
    );

    add(FetchBookings(
      filterModel: currentState.filterModel,
      sortModel: sortModel,
    ));
  }

  void _onResetFilters(ResetFilters event, Emitter<BookingState> emit) {
    add(const FetchBookings());
  }

  void _onChangePage(ChangePage event, Emitter<BookingState> emit) {
    final currentState = state;
    int pageSize = 10;

    if (currentState is BookingLoaded) {
      pageSize = currentState.metadata.pageSize;
    }

    add(FetchBookings(
      pageNo: event.page,
      pageSize: pageSize,
      filterModel: currentState.filterModel,
      sortModel: currentState.sortModel,
    ));
  }

  void _onChangeItemsPerPage(
      ChangeItemsPerPage event, Emitter<BookingState> emit) {
    final currentState = state;

    add(FetchBookings(
      pageNo: 0, // Reset to first page when changing items per page
      pageSize: event.limit,
      filterModel: currentState.filterModel,
      sortModel: currentState.sortModel,
    ));
  }
}
