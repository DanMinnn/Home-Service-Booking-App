import 'package:flutter/material.dart';
import 'package:home_service/modules/authentication/pages/auth_screen.dart';
import 'package:home_service/modules/booking/pages/booking_successfully_page.dart';
import 'package:home_service/modules/booking/pages/choose_working_time_page.dart';
import 'package:home_service/modules/booking/pages/confirm_and_pay_page.dart';
import 'package:home_service/modules/booking/pages/options_service_cleaning_page.dart';
import 'package:home_service/modules/categories/pages/categories_page.dart';
import 'package:home_service/modules/maps/pages/maps.dart';
import 'package:home_service/modules/posts/pages/booking_post.dart';
import 'package:home_service/modules/proflie/pages/edit_profile.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/ui/onboarding_page.dart';
import 'package:home_service/ui/splash_screen.dart';

import '../modules/booking/pages/options_service_cooking_page.dart';
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
        return _buildRoute(settings, const CategoriesPage());
      case RouteName.serviceItem:
        return _buildRoute(settings, const OptionsServiceCleaningPage());
      case RouteName.serviceCooking:
        return _buildRoute(settings, const OptionsServiceCookingPage());
      case RouteName.chooseTime:
        _logger.log('Navigating to ChooseWorkingTimePage: ${settings.name}');
        return _buildRoute(settings, const ChooseWorkingTimePage());
      case RouteName.confirmAndPay:
        _logger.log('Navigating to ConfirmAndPayPage: ${settings.name}');
        return _buildRoute(settings, const ConfirmAndPayPage());
      case RouteName.bookingSuccessfully:
        _logger.log('Navigating to BookingSuccessfullyPage: ${settings.name}');
        return _buildRoute(settings, const BookingSuccessfullyPage());
      case RouteName.bookingPost:
        _logger.log('Navigating to Booking posts: ${settings.name}');
        return _buildRoute(settings, const BookingPost());
      case RouteName.mapsScreen:
        _logger.log('Navigating to Maps: ${settings.name}');
        return _buildRoute(settings, const MapsPage());
      case RouteName.editProfile:
        _logger.log('Navigating to Edit profile: ${settings.name}');
        return _buildRoute(settings, const EditProfile());
      default:
        _logger.log('Default redirect to HomePage: ${settings.name}');
        return _buildRoute(settings, const MainScreen());
    }
  }

  static Route unAuthorizedRoute(RouteSettings settings) {
    _logger.log('unAuthorized route request: ${settings.name}');
    switch (settings.name) {
      case RouteName.splashScreen:
        return _buildRoute(settings, const Splashscreen());
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
