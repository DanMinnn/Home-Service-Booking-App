import 'package:home_service_admin/modules/bookings/models/booking.dart';
import 'package:home_service_admin/providers/log_provider.dart';

import '../../../models/paging_data.dart';
import '../../../providers/api_provider.dart';

class BookingRepo {
  final LogProvider logger = LogProvider("::::BOOKING-REPO::::");
  final _apiProvider = ApiProvider();

  // Get all bookings
  Future<Map<String, Object>> getAllBookings({
    int? pageNo,
    int? pageSize,
    String? selectedDate,
    String? status,
    String? customerSearch,
    String? taskerSearch,
    String? sortField,
    String? sortOrder,
  }) async {
    try {
      Map<String, dynamic> queryParameters = {
        'pageNo': pageNo ?? 0,
        'pageSize': pageSize ?? 10,
      };

      if (selectedDate != null) queryParameters['selectedDate'] = selectedDate;
      if (status != null) queryParameters['status'] = status;
      if (customerSearch != null) {
        queryParameters['customerSearch'] = customerSearch;
      }
      if (taskerSearch != null) queryParameters['taskerSearch'] = taskerSearch;
      if (sortField != null) queryParameters['sortField'] = sortField;
      if (sortOrder != null) queryParameters['sortOrder'] = sortOrder;

      final response = await _apiProvider.get('/booking/get-all-bookings',
          queryParameters: queryParameters);

      if (response.data['status'] == 200) {
        final responseData = response.data['data'];
        final PaginationMetadata metadata =
            PaginationMetadata.fromJson(responseData);
        final bookings = responseData['items'] as List;
        final bookingList =
            bookings.map((booking) => Booking.fromJson(booking)).toList();

        return {
          'bookings': bookingList,
          'metadata': metadata,
        };
      }
      throw Exception("Failed to fetch bookings: ${response.data['message']}");
    } catch (e) {
      logger.log("Error fetching bookings: $e");
      rethrow;
    }
  }
}
