import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:home_service/providers/api_provider.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:uni_links3/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  final LogProvider logger = const LogProvider("PAYMENT-SERVICE:::::");
  final NavigationService _navigationService = NavigationService();
  final ApiProvider _apiProvider = ApiProvider();

  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  bool _initialUriHandled = false;

  Future<void> initDeepLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null && !_initialUriHandled) {
        _initialUriHandled = true;
        _handlePaymentReturn(initialUri);
      }
    } on PlatformException {
      logger.log("Failed to get initial URI");
    }
    uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handlePaymentReturn(uri);
      }
    }, onError: (error) {
      logger.log("URI link error: $error");
    });
  }

  Future<void> handleVnpayPaymentUrl(String paymentUrl) async {
    try {
      logger.log("Opening VNPAY payment URL: $paymentUrl");
      await _launchPaymentUrl(paymentUrl);
    } catch (e, stackTrace) {
      logger.log("Error launching payment URL: $e");
      logger.log("Stack trace: $stackTrace");
      rethrow;
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }

  void _handlePaymentReturn(Uri uri) {
    logger.log("Received URI: ${uri.toString()}");

    if (uri.host == 'payment' && uri.path == '/vnpay_return') {
      final params = uri.queryParameters;
      final bookingId = params['bookingId'];
      final vnp_ResponseCode = params['vnp_ResponseCode'];
      logger.log(
          "VNPAY Return - BookingID: $bookingId, Response: $vnp_ResponseCode");
      if (vnp_ResponseCode == '00') {
        _verifyPayment(bookingId!, params).then((_) {
          _navigationService
              .navigateToWithReplacement(RouteName.bookingSuccessfully);
        }).catchError((error) {
          logger.log("Payment verification failed: $error");
          _showPaymentError("Payment verification failed");
        });
      } else {
        _showPaymentError("Payment failed with code: $vnp_ResponseCode");
      }
    }
  }

  Future<void> _verifyPayment(
      String bookingId, Map<String, String> params) async {
    try {
      final response = await _apiProvider.get(
        '/payment/vnpay_return',
        queryParameters: params,
        options: Options(
          method: 'GET',
          contentType: 'application/json',
        ),
      );

      logger.log("Payment verification response: ${response.data}");

      if (response.data['status'] != 200 && response.data['status'] != 202) {
        throw Exception(
            'Payment verification failed: ${response.data['message']}');
      }
    } catch (e, stackTrace) {
      logger.log("Error verifying payment: $e");
      logger.log("Stack trace: $stackTrace");
      rethrow;
    }
  }

  void _showPaymentError(String message) {
    logger.log("Payment Error: $message");
    _navigationService.navigateTo(RouteName.paymentError, arguments: message);
  }
}
