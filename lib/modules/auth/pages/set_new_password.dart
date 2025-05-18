import 'package:flutter/material.dart';
import 'package:home_service_tasker/common/widget/app_bar.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:home_service_tasker/theme/app_assets.dart';

import '../../../common/widget/basic_button.dart';
import '../../../common/widget/custom_text_field.dart';
import '../../../routes/navigation_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';

class SetNewPassword extends StatefulWidget {
  const SetNewPassword({super.key});

  @override
  State<SetNewPassword> createState() => _SetNewPasswordState();
}

class _SetNewPasswordState extends State<SetNewPassword> {
  final NavigationService _navigationService = NavigationService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _confirmPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                      _navigationService.navigateToAndClearStack(
                          RouteName.loginScreen); //navigate to login page
                    },
                    child: Image.asset(
                      AppAssetsIcons.arrowLeft,
                      color: AppColors.dark,
                    ),
                  ),
                  title: 'Set New Password',
                ),
                Text("Set new password", style: AppTextStyles.headline1),
                const SizedBox(height: 12),
                Text(
                  "Create strong and secured\nnew password.",
                  style: AppTextStyles.headlineSubTitle.copyWith(
                    color: AppColors.accentGrey.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 35),
                CustomInputField(
                  controller: _passwordController,
                  label: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _confirmPassword,
                  label: 'Confirm Password',
                  isPassword: true,
                ),
                const SizedBox(height: 30),
                BasicButton(
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  text: 'Save Password',
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
