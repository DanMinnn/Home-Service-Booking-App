import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_service_tasker/common/widget/show_snack_bar.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:uni_links3/uni_links.dart';

import '../../../providers/log_provider.dart';
import '../../../routes/navigation_service.dart';

// Store deeplink data globally to access from SplashScreen
class DeepLinkData {
  static String? path;
  static Map<String, String>? queryParams;
  static bool hasData() => path != null;

  static void store(String pathValue, Map<String, String> params) {
    path = pathValue;
    queryParams = params;
    _logger.log('Stored deeplink data: path=$path, params=$queryParams');
  }

  static void clear() {
    path = null;
    queryParams = null;
    _logger.log('Cleared deeplink data');
  }

  static final _logger = LogProvider('DEEP-LINK-DATA:::');
}

class EmailVerificationHandler extends StatefulWidget {
  const EmailVerificationHandler({super.key, required this.child});

  final Widget child;

  @override
  State<EmailVerificationHandler> createState() =>
      _EmailVerificationHandlerState();
}

class _EmailVerificationHandlerState extends State<EmailVerificationHandler> {
  StreamSubscription? _sub;

  LogProvider get logger =>
      const LogProvider('::::EMAIL VERIFICATION HANDLER:::::');

  // Get the navigation service instance
  final NavigationService _navigationService = NavigationService();

  @override
  void initState() {
    super.initState();
    logger.log('Initializing EmailVerificationHandler');
    _initDeepLinkListener();
  }

  @override
  dispose() {
    _sub?.cancel();
    super.dispose();
    logger.log('Disposing EmailVerificationHandler');
  }

  Future<void> _initDeepLinkListener() async {
    logger.log('Setting up deep link listener');

    // Handle initial deep link when app is opened from a terminated state
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        logger.log('Received initial deep link: $initialUri');
        // Extract and store the data, but don't navigate - let SplashScreen handle it
        _extractAndStoreDeepLinkData(initialUri);
      }
    } catch (e) {
      logger.log('Error getting initial deep link: $e');
    }

    // Listen for deeplinks when app is running
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        logger.log('Received deep link while app is running: $uri');
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      logger.log('Error receiving deep link: $err');
    });
  }

  void _extractAndStoreDeepLinkData(Uri uri) {
    if (uri.host == 'authorized') {
      final normalizedPath =
          uri.path.startsWith('/') ? uri.path : '/${uri.path}';
      logger.log('Storing deeplink data: $normalizedPath');

      // Store the path and query parameters for later use
      Map<String, String> queryParams = {};
      uri.queryParameters.forEach((key, value) {
        queryParams[key] = value;
      });

      DeepLinkData.store(normalizedPath, queryParams);
    }
  }

  void _handleDeepLink(Uri uri) {
    logger.log('Handling deep link: $uri');
    logger.log('Scheme: ${uri.scheme}, Host: ${uri.host}');
    logger.log('Query parameters: ${uri.queryParameters}');
    logger.log('Path: ${uri.path}');

    // Extract data first
    _extractAndStoreDeepLinkData(uri);

    // Check if the deep link is for our app
    if (uri.host == 'authorized') {
      final normalizedPath =
          uri.path.startsWith('/') ? uri.path : '/${uri.path}';

      if (normalizedPath == '/email-verified') {
        final success = uri.queryParameters['success'] ?? 'false';
        final userType = uri.queryParameters['userType'] ?? '';
        final secretCode = uri.queryParameters['secretCode'] ?? '';

        logger.log(
            'Email verification deep link: success=$success, userType=$userType, secretCode=$secretCode');

        if (secretCode.isNotEmpty) {
          _navigateToSuccessPage();
        } else {
          _showErrorMessage();
        }
      } else if (normalizedPath == '/reset-password') {
        logger.log('Reset password deep link ${uri.toString()}');

        final token = uri.queryParameters['token'] ?? '';
        logger.log('Reset password token: $token');

        if (token.isNotEmpty) {
          // Try to navigate immediately if app is running
          _navigateToSetNewPasswordPage(token: token);
        } else {
          ShowSnackBar.showError(context, 'Invalid reset password link');
        }
      } else {
        logger.log('Unknown path: $normalizedPath');
      }
    } else {
      logger.log('Unknown host: ${uri.host}');
    }
  }

  void _navigateToSetNewPasswordPage({required String token}) {
    logger.log('Attempting to navigate to SetNewPassword with token: $token');

    // Ensure widget tree is built before navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Always try using the navigation service for consistent behavior
        _navigationService.navigateToAndClearStack(
          RouteName.setNewPasswordScreen,
          arguments: {'token': token},
        );

        // Clear deeplink data once we've handled it
        DeepLinkData.clear();
      } catch (e) {
        logger.log('Error navigating to SetNewPassword: $e');
      }
    });
  }

  void _navigateToSuccessPage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Always try using the navigation service for consistent behavior
        _navigationService.navigateToAndClearStack(
          RouteName.verifiedScreen,
        );

        // Clear deeplink data once we've handled it
        DeepLinkData.clear();
      } catch (e) {
        logger.log('Error navigating to SetNewPassword: $e');
      }
    });
  }

  void _showErrorMessage() {
    // Ensure context is available before showing SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        ShowSnackBar.showError(context, 'Email verification failed');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
