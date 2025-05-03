import 'package:flutter/material.dart';
import 'package:home_service/common/widgets/stateless/basic_button.dart';
import 'package:home_service/modules/authentication/pages/auth_screen.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            _buildImageCarousel(),
            const SizedBox(height: 90),
            _buildTextWelcome(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: _buildButtonLoginSignUp(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 270,
        maxHeight: 270,
      ),
      child: Image.asset(
        AppAssetsBackgrounds.carousel,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTextWelcome() {
    return Column(
      children: [
        Text(
          'Welcome !',
          style: AppTextStyles.h4,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6),
        Text(
          'The Home Service App',
          style: AppTextStyles.h5SemiBold,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          'Application for easily find a\nHome Serviceman',
          style: AppTextStyles.bodyLargeRegular,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildButtonLoginSignUp(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
              width: double.infinity,
              child: BasicButton(
                  onPressed: () {
                    // Optimize navigation by using a builder function
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AuthScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  title: 'Login')),
          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Optimize navigation by using a builder function
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AuthScreen(initialTab: 1),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                side: BorderSide(
                  color: AppColors.blue,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Sign up',
                style: AppTextStyles.bodyLargeSemiBold
                    .copyWith(color: AppColors.blue),
              ),
            ),
          )
        ],
      ),
    );
  }
}
