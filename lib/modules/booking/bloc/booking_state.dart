abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final int bookingId;

  BookingSuccess(this.bookingId);
}

class BookingVnpayPaymentInitiated extends BookingState {
  final String paymentUrl;
  final int bookingId;

  BookingVnpayPaymentInitiated(this.paymentUrl, this.bookingId);
}

class BookingError extends BookingState {
  final String message;

  BookingError(this.message);
}
