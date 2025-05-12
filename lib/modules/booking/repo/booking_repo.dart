import 'package:dio/dio.dart';
import 'package:home_service/modules/booking/models/booking_req.dart';
import 'package:home_service/providers/api_provider.dart';
import 'package:home_service/providers/log_provider.dart';

class BookingRepo {
  LogProvider get logger => const LogProvider("BOOKING-REPO:::::");
  final apiProvider = ApiProvider();

  Future<String> createBookingRequest(BookingReq req) async {
    try {
      final response = await apiProvider.post(
        '/booking/create-booking',
        data: req.toJson(),
        options: Options(
          method: 'POST',
          contentType: 'application/json',
        ),
      );
      if (response.data['status'] == 200) {
        logger.log("Booking created successfully: ${response.data}");
        return response.data['message'] ?? 'Booking created successfully';
      } else {
        return response.data['message'] ?? 'Can not create booking';
      }
    } catch (e) {
      logger.log("Error creating booking: ${e.toString()}");
      rethrow;
    }
  }
}
