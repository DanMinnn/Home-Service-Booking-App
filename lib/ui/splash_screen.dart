import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../blocs/app_state_bloc.dart';
import '../modules/auth/repo/email_verified_handler.dart';
import '../providers/log_provider.dart';
import '../routes/navigation_service.dart';
import '../routes/route_name.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
      backgroundColor: AppColors.primary,
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
        final token = DeepLinkData.queryParams?['secretCode'] ?? '';
        if (token.isNotEmpty) {
          _navigationService.navigateToAndClearStack(RouteName.verifiedScreen);
          // Clear after handling
          DeepLinkData.clear();
          return;
        }
      }
    }

    // Default flow if no deeplink or failed to handle deeplink
    final appState = context.read<AppStateBloc>().state;
    logger.log(
        'No deeplink found or processed, proceeding with normal flow. App state: $appState');

    if (appState == AppState.authorized) {
      _navigationService.navigateToAndClearStack(RouteName.homeScreen);
    } else {
      _navigationService.navigateToAndClearStack(RouteName.loginScreen);
    }
  }
}
