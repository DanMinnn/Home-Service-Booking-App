import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../blocs/app_state_bloc.dart';
import '../modules/authentication/models/deep_link_data.dart';
import '../providers/log_provider.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final NavigationService _navigationService = NavigationService();
  final LogProvider logger = const LogProvider('SPLASH-SCREEN:::');
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

    // Check if we have stored deeplink data first
    if (DeepLinkData.hasData()) {
      logger.log('Found pending deeplink: ${DeepLinkData.path}');

      if (DeepLinkData.path == '/reset-password') {
        final token = DeepLinkData.queryParams?['token'] ?? '';
        logger.log('Handling reset password deeplink with token: $token');

        if (token.isNotEmpty) {
          _navigationService.navigateToAndClearStack(
              RouteName.setNewPasswordScreen,
              arguments: {'token': token});
          // Clear after handling
          DeepLinkData.clear();
          return;
        }
      } else if (DeepLinkData.path == '/email-verified') {
        final success = DeepLinkData.queryParams?['success'] ?? 'false';
        if (success == 'true') {
          _navigationService.navigateToAndClearStack(RouteName.verifiedScreen);
          // Clear after handling
          DeepLinkData.clear();
          return;
        }
      }
    }
    final appState = context.read<AppStateBloc>().state;
    if (appState == AppState.authorized) {
      _navigationService.navigateToAndClearStack(RouteName.homeScreen);
    } else if (appState == AppState.unAuthorized) {
      _navigationService.navigateToAndClearStack(RouteName.homeScreen);
    } else {
      _navigationService.navigateToAndClearStack(RouteName.onboardingScreen);
    }
  }
}
