import 'package:flutter/material.dart';

import '../../../common/widget/app_bar.dart';
import '../../../common/widget/basic_button.dart';
import '../../../common/widget/custom_text_field.dart';
import '../../../routes/navigation_service.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final NavigationService _navigationService = NavigationService();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BasicAppBar(
                  leading: GestureDetector(
                    onTap: () {
                      _navigationService.goBack();
                    },
                    child: Image.asset(
                      AppAssetsIcons.arrowLeft,
                      color: AppColors.dark,
                    ),
                  ),
                  title: 'Set New Password',
                ),
                Text("Forget Password", style: AppTextStyles.headline1),
                const SizedBox(height: 12),
                Text(
                  "Enter your email address\nto reset password.",
                  style: AppTextStyles.headlineSubTitle.copyWith(
                    color: AppColors.accentGrey.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 35),
                CustomInputField(
                  controller: _emailController,
                  label: 'Email Address',
                  isPassword: false,
                ),
                const SizedBox(height: 30),
                BasicButton(
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  text: 'Reset Password',
                  onPressed: () {
                    // Handle login action
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
