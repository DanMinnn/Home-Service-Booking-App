import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:uni_links3/uni_links.dart';

// Keep this global key as the single source of truth for navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class EmailVerificationHandler extends StatefulWidget {
  const EmailVerificationHandler({super.key, required this.child});
  final Widget child;

  @override
  State<EmailVerificationHandler> createState() =>
      _EmailVerificationHandlerState();
}

class _EmailVerificationHandlerState extends State<EmailVerificationHandler> {
  StreamSubscription? _sub;
  LogProvider get logger => const LogProvider('Email Verification Handler');

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
    // listen deeplink when app is running
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        logger.log('Received deep link while app is running: $uri');
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      logger.log('Error receiving deep link: $err');
    });

    // handle initial deep link when app is opened from a terminated state
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        logger.log('Received initial deep link: $initialUri');
        // Delay a bit to ensure app is fully initialized
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleDeepLink(initialUri);
        });
      }
    } catch (e) {
      logger.log('Error getting initial deep link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    logger.log('Handling deep link: $uri');
    logger.log('Scheme: ${uri.scheme}, Host: ${uri.host}');
    logger.log('Query parameters: ${uri.queryParameters}');

    // Check if the deep link is for email verification
    if (uri.host == 'email-verified') {
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
    } else {
      logger.log('Not a valid email verification deep link');
    }
  }

  void _navigateToSuccessPage({int retryCount = 0}) {
    const maxRetries = 10; // Increased max retries
    const retryDelay = Duration(milliseconds: 300); // Increased delay

    logger.log(
        'Attempting to navigate to VerifySuccessPage, attempt ${retryCount + 1}');

    // Try using context navigation if navigatorKey is not ready
    if (mounted && context.mounted) {
      try {
        logger.log('Trying to navigate using context');
        Navigator.of(context).pushNamed('/verified-screen');
        return;
      } catch (e) {
        logger.log('Error navigating with context: $e');
      }
    }

    // Fallback to navigator key
    if (navigatorKey.currentState != null) {
      logger.log('Navigator is ready, navigating to VerifySuccessPage');
      try {
        navigatorKey.currentState!.pushNamed('/verified-screen');
      } catch (e) {
        logger.log('Error navigating with navigatorKey: $e');
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
            content: Text('Xác nhận email thất bại!'),
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
