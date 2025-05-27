import 'package:flutter/material.dart';
import 'package:home_service_tasker/modules/auth/pages/forgot_password_page.dart';
import 'package:home_service_tasker/modules/auth/pages/login_page.dart';
import 'package:home_service_tasker/modules/auth/pages/register_page.dart';
import 'package:home_service_tasker/modules/auth/pages/set_new_password.dart';
import 'package:home_service_tasker/modules/auth/pages/verified_success_page.dart';
import 'package:home_service_tasker/modules/home/page/task_detail_page.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:home_service_tasker/ui/main_screen.dart';
import 'package:home_service_tasker/ui/maps_page.dart';
import 'package:home_service_tasker/ui/splash_screen.dart';

import '../providers/log_provider.dart';

class Routes {
  LogProvider get logger => const LogProvider('ROUTES:::');
  static final _logger = LogProvider('ROUTES:::');

  static Route authorizedRoute(RouteSettings settings) {
    _logger.log('Authorized route request: ${settings.name}');
    _logger.log('Route arguments: ${settings.arguments}');

    // Special case: SetNewPassword should be accessible from both states
    if (settings.name == RouteName.setNewPasswordScreen) {
      _logger.log('Handling SetNewPassword screen in authorized state');
      return _buildRoute(settings, const SetNewPassword());
    }

    switch (settings.name) {
      case RouteName.splashScreen:
        return _buildRoute(settings, const SplashScreen());
      case RouteName.mainScreen:
        return _buildRoute(settings, const MainScreen());
      case RouteName.taskDetailScreen:
        return _buildRoute(settings, const TaskDetailPage());
      case RouteName.mapsScreen:
        return _buildRoute(settings, const MapsPage());
      default:
        _logger.log('Default redirect to: ${settings.name}');
        return _buildRoute(settings, const SplashScreen());
    }
  }

  static Route unAuthorizedRoute(RouteSettings settings) {
    _logger.log('Unauthorized route request: ${settings.name}');
    _logger.log('Route arguments: ${settings.arguments}');

    // Special case: SetNewPassword should be accessible from both states
    if (settings.name == RouteName.setNewPasswordScreen) {
      _logger.log('Handling SetNewPassword screen in unAuthorized state');
      return _buildRoute(settings, const SetNewPassword());
    }

    switch (settings.name) {
      case RouteName.splashScreen:
        return _buildRoute(settings, const SplashScreen());
      case RouteName.registerScreen:
        return _buildRoute(settings, const RegisterPage());
      case RouteName.verifiedScreen:
        return _buildRoute(settings, const VerifySuccessPage());
      case RouteName.loginScreen:
        return _buildRoute(settings, const LoginPage());
      case RouteName.forgotPasswordScreen:
        return _buildRoute(settings, const ForgotPasswordPage());
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
