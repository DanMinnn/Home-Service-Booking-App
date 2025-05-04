import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory NavigationService() {
    return _instance;
  }

  NavigationService._internal();

  NavigatorState? get navigator => navigatorKey.currentState;

  // Navigate to a named route
  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigator?.pushNamed(routeName, arguments: arguments);
  }

  // Navigate and remove previous routes
  Future<dynamic>? navigateToReplacement(String routeName,
      {Object? arguments}) {
    return navigator?.pushReplacementNamed(routeName, arguments: arguments);
  }

  // Navigate and remove all previous routes
  Future<dynamic>? navigateToAndClearStack(String routeName,
      {Object? arguments}) {
    return navigator?.pushNamedAndRemoveUntil(
        routeName, (Route<dynamic> route) => false,
        arguments: arguments);
  }

  // Go back to previous screen
  void goBack([dynamic result]) {
    return navigator?.pop(result);
  }
}
