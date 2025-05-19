import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../blocs/app_state_bloc.dart';
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

    final appState = context.read<AppStateBloc>().state;
    if (appState == AppState.authorized) {
      _navigationService.navigateToAndClearStack(RouteName.homeScreen);
    } else if (appState == AppState.unAuthorized) {
      _navigationService.navigateToAndClearStack(RouteName.loginScreen);
    } else {
      _navigationService.navigateToAndClearStack(RouteName.loginScreen);
    }
  }
}
