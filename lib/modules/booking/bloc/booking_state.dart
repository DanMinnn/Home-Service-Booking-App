abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final String message;

  BookingSuccess(this.message);
}

class BookingFailure extends BookingState {
  final String error;

  BookingFailure(this.error);
}
