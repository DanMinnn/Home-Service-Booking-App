import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../blocs/app_state_bloc.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final NavigationService _navigationService = NavigationService();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: Stack(
        children: [
          Center(
            child: _buildLogoImage(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: _buildLoadingIndicator(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLogoImage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 200,
        maxWidth: 200,
      ),
      child: Image.asset(
        AppAssetsBackgrounds.logo,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      alignment: Alignment.bottomCenter,
      width: 60,
      height: 60,
      child: LoadingIndicator(
        indicatorType: Indicator.ballSpinFadeLoader,
        colors: const [Colors.white],
      ),
    );
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 2));

    final appState = context.read<AppStateBloc>().state;
    if (appState == AppState.authorized) {
      _navigationService.navigateToAndClearStack(RouteName.homeScreen);
    } else if (appState == AppState.unAuthorized) {
      _navigationService.navigateToAndClearStack(RouteName.authScreen);
    } else {
      _navigationService.navigateToAndClearStack(RouteName.onboardingScreen);
    }
  }
}
