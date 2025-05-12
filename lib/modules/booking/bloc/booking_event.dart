import 'package:home_service/modules/booking/models/booking_req.dart';

abstract class BookingEvent {}

class BookingSubmitted extends BookingEvent {
  final BookingReq bookingReq;

  BookingSubmitted(this.bookingReq);
}
