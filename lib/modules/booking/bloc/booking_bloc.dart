import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/booking/bloc/booking_event.dart';
import 'package:home_service/modules/booking/bloc/booking_state.dart';
import 'package:home_service/modules/booking/repo/booking_repo.dart';
import 'package:home_service/providers/log_provider.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepo bookingRepository;
  LogProvider get logger => const LogProvider("BOOKING-BLOC:::::");

  BookingBloc(this.bookingRepository) : super(BookingInitial()) {
    on<BookingSubmitted>(_onBookingSubmitted);
  }

  Future<void> _onBookingSubmitted(
      BookingSubmitted event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final req = event.bookingReq;
      final bookingResponse = await bookingRepository.createBookingRequest(req);
      if (bookingResponse == 200) {
        emit(BookingSuccess("Booking created successfully"));
        return;
      } else {
        emit(BookingFailure("Failed to create booking. Check your details."));
        return;
      }
      // logger.log('Booking response: ${bookingResponse.toString()}');
      // emit(BookingSuccess(bookingResponse.toString()));
    } catch (e) {
      emit(BookingFailure("Error: ${e.toString()}"));
    }
  }
}
