import 'package:flutter/material.dart';

import '../../../common/widget/app_bar.dart';
import '../../../common/widget/basic_button.dart';
import '../../../common/widget/custom_text_field.dart';
import '../../../routes/navigation_service.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final NavigationService _navigationService = NavigationService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullName = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullName.dispose();
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
                Text("Getting Started", style: AppTextStyles.headline1),
                const SizedBox(height: 12),
                Text("Seems you are new here, \nLet’s set up your profile.",
                    style: AppTextStyles.headlineSubTitle.copyWith(
                      color: AppColors.accentGrey.withValues(alpha: 0.5),
                    )),
                const SizedBox(height: 30),
                CustomInputField(
                  controller: _fullName,
                  label: 'Full Name',
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _emailController,
                  label: 'Email Address',
                  isPassword: false,
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _passwordController,
                  label: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                BasicButton(
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  text: 'Continue',
                  onPressed: () {
                    // Handle login action
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: AppTextStyles.paragraph3.copyWith(
                        color: AppColors.accentGrey.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Login',
                        style: AppTextStyles.headline6.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
