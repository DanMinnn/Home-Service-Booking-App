import 'package:flutter/material.dart';
import 'package:home_service/modules/authentication/pages/auth_screen.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/ui/onboarding_page.dart';
import 'package:home_service/ui/splash_screen.dart';

import '../ui/home_page.dart';

class Routes {
  LogProvider get logger => const LogProvider('ROUTES:::');
  static final _logger = LogProvider('ROUTES:::');

  static Route authorizedRoute(RouteSettings settings) {
    _logger.log('Authorized route request: ${settings.name}');
    switch (settings.name) {
      case RouteName.splashScreen:
        return _buildRoute(settings, const Splashscreen());
      case RouteName.homeScreen:
        return _buildRoute(settings, const HomePage());
      default:
        _logger.log('Default redirect to HomePage: ${settings.name}');
        return _buildRoute(settings, const HomePage());
    }
  }

  static Route unAuthorizedRoute(RouteSettings settings) {
    _logger.log('unAuthorized route request: ${settings.name}');
    switch (settings.name) {
      case RouteName.splashScreen:
        return _buildRoute(settings, const Splashscreen());
      case RouteName.authScreen:
        return _buildRoute(settings, const AuthScreen());
      case RouteName.onboardingScreen:
        return _buildRoute(settings, const OnboardingPage());
      default:
        _logger.log('Default redirect to AuthScreen: ${settings.name}');
        return _buildRoute(settings, const AuthScreen());
    }
  }

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget page) {
    _logger.log('Build route: ${settings.name}');
    return MaterialPageRoute(
      builder: (context) => page,
      settings: settings,
    );
  }
}
