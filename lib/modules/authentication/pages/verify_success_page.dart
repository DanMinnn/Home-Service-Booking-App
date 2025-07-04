import 'package:flutter/material.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/ui/onboarding_page.dart';

import '../../../common/widgets/stateless/basic_button.dart';

class VerifySuccessPage extends StatelessWidget {
  const VerifySuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // Bottom card
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Verified!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Hello! You have successfully\nverified the account.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Top green circle with check icon
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.green,
                  child: Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
              child: SizedBox(
                width: double.infinity,
                child: BasicButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OnboardingPage()));
                  },
                  title: "Browser Home",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
