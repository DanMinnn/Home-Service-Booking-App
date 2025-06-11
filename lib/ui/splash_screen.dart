import 'package:flutter/material.dart';
import 'package:home_service_admin/themes/app_assets.dart';
import 'package:home_service_admin/themes/app_colors.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssetsBackgrounds.logo, width: 150, height: 150),
            const SizedBox(height: 60),
            Container(
              alignment: Alignment.bottomCenter,
              width: 60,
              height: 60,
              child: LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: const [Colors.white],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
