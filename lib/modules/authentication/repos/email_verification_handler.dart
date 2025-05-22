import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:uni_links3/uni_links.dart';

import '../../../common/widgets/stateless/show_snack_bar.dart';
import '../../../routes/route_name.dart';
import '../models/deep_link_data.dart';

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

    // handle initial deep link when app is opened from a terminated state
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        logger.log('Received initial deep link: $initialUri');
        _extractAndStoreDeepLinkData(initialUri);
      }
    } catch (e) {
      logger.log('Error getting initial deep link: $e');
    }
    // listen deeplink when app is running
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

        if (success == 'true') {
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

  void _navigateToSuccessPage({int retryCount = 0}) {
    const maxRetries = 10; // Increased max retries
    const retryDelay = Duration(milliseconds: 300); // Increased delay

    logger.log(
        'Attempting to navigate to VerifySuccessPage, attempt ${retryCount + 1}');

    // Try using context navigation if NavigationService is not ready
    if (mounted && context.mounted) {
      try {
        logger.log('Trying to navigate using context');
        Navigator.of(context).pushNamed(RouteName.verifiedScreen);
        return;
      } catch (e) {
        logger.log('Error navigating with context: $e');
      }
    }

    // Use the NavigationService instead of direct navigatorKey
    if (_navigationService.navigator != null) {
      logger.log('Navigator is ready, navigating to VerifySuccessPage');
      try {
        _navigationService.navigateTo(RouteName.verifiedScreen);
      } catch (e) {
        logger.log('Error navigating with NavigationService: $e');
        if (retryCount < maxRetries) {
          Future.delayed(retryDelay,
              () => _navigateToSuccessPage(retryCount: retryCount + 1));
        }
      }
    } else if (retryCount < maxRetries) {
      logger.log(
          'NavigatorState is still null, retrying (${retryCount + 1}/$maxRetries)...');
      Future.delayed(
          retryDelay, () => _navigateToSuccessPage(retryCount: retryCount + 1));
    } else {
      logger.log(
          'Failed to navigate: NavigatorState is not available after $maxRetries retries');
    }
  }

  void _showErrorMessage() {
    // Ensure context is available before showing SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
