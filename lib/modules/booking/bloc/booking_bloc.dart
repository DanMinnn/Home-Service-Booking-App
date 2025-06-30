import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/booking/bloc/booking_event.dart';
import 'package:home_service/modules/booking/bloc/booking_state.dart';
import 'package:home_service/modules/booking/models/payment_method.dart';
import 'package:home_service/modules/booking/repo/booking_repo.dart';
import 'package:home_service/services/payment_service.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepo _bookingRepo;
  final PaymentService _paymentService = PaymentService();

  BookingBloc(this._bookingRepo) : super(BookingInitial()) {
    on<BookingSubmitted>(_onBookingSubmitted);
  }

  Future<void> _onBookingSubmitted(
      BookingSubmitted event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      var response = await _bookingRepo.createBookingRequest(event.bookingReq);

      if (event.bookingReq.methodType == PaymentMethod.vnpay.name) {
        final paymentUrl = _bookingRepo.getPaymentUrl();
        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          emit(BookingVnpayPaymentInitiated(paymentUrl, response));
          await _paymentService.handleVnpayPaymentUrl(paymentUrl);
          return;
        }
      }

      // For other payment methods or if no payment URL is provided
      emit(BookingSuccess(response));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
