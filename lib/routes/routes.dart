import 'package:flutter/material.dart';

import '../providers/log_provider.dart';
import '../ui/splash_screen.dart';

class Routes {
  LogProvider get logger => const LogProvider('ROUTES:::');
  static final _logger = LogProvider('ROUTES:::');

  static Route authorizedRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        _logger.log('Default redirect to: ${settings.name}');
        return _buildRoute(settings, const SplashScreen());
    }
  }

  static Route unAuthorizedRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        _logger.log('Default redirect to: ${settings.name}');
        return _buildRoute(settings, const SplashScreen());
    }
  }

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget page) {
    _logger
        .log('Build route: ${settings.name}, arguments: ${settings.arguments}');
    return MaterialPageRoute(
      builder: (context) => page,
      settings: settings,
    );
  }
}
