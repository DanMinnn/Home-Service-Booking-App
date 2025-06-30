import 'package:dio/dio.dart';
import 'package:home_service/modules/booking/models/booking_req.dart';
import 'package:home_service/providers/api_provider.dart';
import 'package:home_service/providers/log_provider.dart';

class BookingRepo {
  LogProvider get logger => const LogProvider("BOOKING-REPO:::::");
  final apiProvider = ApiProvider();
  String? _paymentUrl;

  Future<int> createBookingRequest(BookingReq req) async {
    try {
      final response = await apiProvider.post(
        '/booking/create-booking',
        data: req.toJson(),
        options: Options(
          method: 'POST',
          contentType: 'application/json',
        ),
      );
      if (response.data['status'] == 200 || response.data['status'] == 202) {
        logger.log("Booking created successfully: ${response.data}");

        if (response.data['data'] != null &&
            response.data['data']['paymentUrl'] != null) {
          _paymentUrl = response.data['data']['paymentUrl'];
          logger.log("Payment URL received: $_paymentUrl");
        }

        return response.data['data']['bookingId'] ?? 0;
      } else {
        return response.data['status'] ?? 400;
      }
    } catch (e, stackTrace) {
      logger.log("Error creating booking: ${e.toString()}");
      logger.log("Stack trace: $stackTrace");
      rethrow;
    }
  }

  // Method to get the payment URL after creating a booking
  String? getPaymentUrl() {
    return _paymentUrl;
  }
}
