import 'package:flutter/material.dart';
import 'package:home_service/modules/booking/pages/choose_working_time_page.dart';
import 'package:home_service/modules/booking/pages/confirm_and_pay_page.dart';
import 'package:home_service/modules/booking/pages/options_service_page.dart';
import 'package:home_service/modules/categories/pages/categories_page.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/ui/onboarding_page.dart';
import 'package:home_service/ui/splash_screen.dart';

import '../ui/main_screen.dart';

class Routes {
  LogProvider get logger => const LogProvider('ROUTES:::');
  static final _logger = LogProvider('ROUTES:::');

  static Route authorizedRoute(RouteSettings settings) {
    _logger.log('Authorized route request: ${settings.name}');
    switch (settings.name) {
      case RouteName.splashScreen:
        return _buildRoute(settings, const Splashscreen());
      case RouteName.homeScreen:
        return _buildRoute(settings, const MainScreen());
      case RouteName.categories:
        _logger.log('Navigating to CategoriesPage: ${settings.name}');
        return _buildRoute(settings, const CategoriesPage());
      default:
        _logger.log('Default redirect to HomePage: ${settings.name}');
        return _buildRoute(settings, const MainScreen());
    }
  }

  static Route unAuthorizedRoute(RouteSettings settings) {
    _logger.log('unAuthorized route request: ${settings.name}');
    switch (settings.name) {
      case RouteName.homeScreen:
        return _buildRoute(settings, const MainScreen());
      case RouteName.onboardingScreen:
        return _buildRoute(settings, const OnboardingPage());
      case RouteName.categories:
        return _buildRoute(settings, const CategoriesPage());
      case RouteName.serviceItem:
        return _buildRoute(settings, const OptionsServicePage());
      case RouteName.chooseTime:
        _logger.log('Navigating to ChooseWorkingTimePage: ${settings.name}');
        return _buildRoute(settings, const ChooseWorkingTimePage());
      case RouteName.confirmAndPay:
        _logger.log('Navigating to ChooseWorkingTimePage: ${settings.name}');
        return _buildRoute(settings, const ConfirmAndPayPage());
      default:
        _logger.log('Default redirect to AuthScreen: ${settings.name}');
        return _buildRoute(settings, const MainScreen());
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
