import 'dart:async';
import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory NavigationService() {
    return _instance;
  }

  NavigationService._internal();

  NavigatorState? get navigator => navigatorKey.currentState;

  // Add a stream controller for tab navigation
  final StreamController<int> _tabController =
      StreamController<int>.broadcast();
  Stream<int> get tabStream => _tabController.stream;

  // Track current and previous tab indices
  int _currentTab = 0;
  int _previousTab = 0;

  int get currentTab => _currentTab;
  int get previousTab => _previousTab;

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

  // Add a method to change tabs
  void changeTab(int index) {
    if (_currentTab != index) {
      _previousTab = _currentTab;
      _currentTab = index;
      _tabController.add(index);
    }
  }

  // Go back to previous tab
  void goBackToPreviousTab() {
    changeTab(_previousTab);
  }

  void dispose() {
    _tabController.close();
  }
}
