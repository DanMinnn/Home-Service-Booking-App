import 'package:flutter/material.dart';
import 'package:home_service_tasker/common/widget/basic_button.dart';
import 'package:home_service_tasker/routes/navigation_service.dart';
import 'package:home_service_tasker/theme/app_assets.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

import '../../../common/widget/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final NavigationService _navigationService = NavigationService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                const SizedBox(height: 40),
                Text("Let's Sign You In", style: AppTextStyles.headline1),
                const SizedBox(height: 12),
                Text("Welcome back, you've been missed!",
                    style: AppTextStyles.headlineSubTitle.copyWith(
                      color: AppColors.accentGrey.withValues(alpha: 0.5),
                    )),
                const SizedBox(height: 30),
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Forgot Password ?',
                          style: AppTextStyles.headline6.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                BasicButton(
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  text: 'Login',
                  onPressed: () {
                    // Handle login action
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 0.5,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'OR',
                        style: AppTextStyles.headline6.copyWith(
                          fontSize: 14,
                          color: Color(
                            0xFF8F92A1,
                          ),
                          letterSpacing: 20 / 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BasicButton(
                  backgroundColor: Color(0xFFF3F6F8),
                  textColor: AppColors.dark,
                  text: 'Login with Google',
                  prefixIcon: Image.asset(
                    AppAssetsIcons.googleIc,
                    height: 24,
                    width: 24,
                  ),
                  onPressed: () {
                    // Handle login with Google action
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
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
                        'Sign Up',
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
