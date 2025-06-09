import 'package:home_service/modules/review/model/review_req.dart';
import 'package:home_service/providers/api_provider.dart';
import 'package:home_service/providers/log_provider.dart';

class ReviewRepo {
  final LogProvider logger = LogProvider('::::REVIEW-REPO::::');
  final _apiProvider = ApiProvider();

  Future<bool> createReview(ReviewReq review) async {
    try {
      final response = await _apiProvider.post(
        '/booking/review',
        data: review.toJson(),
      );
      logger.log('Review created successfully: ${response.data}');
      return true;
    } catch (e) {
      logger.log('Error creating review: $e');
      return false;
    }
  }
}
