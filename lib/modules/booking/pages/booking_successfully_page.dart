import 'package:flutter/material.dart';
import 'package:home_service/common/widgets/stateless/basic_button.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

class BookingSuccessfullyPage extends StatelessWidget {
  const BookingSuccessfullyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = NavigationService();
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.green,
                        ),
                        child: Image.asset(AppAssetIcons.tickSuccess)),
                    const SizedBox(height: 20),
                    Text(
                      textAlign: TextAlign.center,
                      'Booking placed \n successfully',
                      style: AppTextStyles.h5Bold.copyWith(
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      softWrap: true,
                      'Thanks for your booking. Your booking has been placed successfully. Please continue your book.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMediumRegular.copyWith(
                        color: AppColors.darkBlue.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: BasicButton(
                  title: 'Go Home',
                  onPressed: () {
                    // Use direct navigation with replacement to avoid stack issues
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteName.homeScreen,
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
