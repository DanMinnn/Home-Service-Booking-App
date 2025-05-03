import 'package:flutter/material.dart';
import 'package:home_service/modules/authentication/pages/login_page.dart';
import 'package:home_service/modules/authentication/pages/signup_page.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

class AuthScreen extends StatefulWidget {
  final int initialTab;

  const AuthScreen({super.key, this.initialTab = 0});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Lazy-loaded pages to improve performance
  Widget? _loginPage;
  Widget? _signupPage;

  @override
  void initState() {
    super.initState();
    // Use initialTab value
    selectedIndex = widget.initialTab;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeTab(int index) {
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  // Get the appropriate page with lazy loading
  Widget _getPage(int index) {
    if (index == 0) {
      _loginPage ??= const LoginPage();
      return _loginPage!;
    } else {
      _signupPage ??= const SignupPage();
      return _signupPage!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom Tab Bar
              Container(
                width: 327,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    // Login Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _changeTab(0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedIndex == 0
                                ? AppColors.darkBlue
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Login',
                            style: selectedIndex == 0
                                ? AppTextStyles.bodyLargeSemiBold
                                : AppTextStyles.bodyLargeSemiBold.copyWith(
                                    color: AppColors.darkBlue
                                        .withValues(alpha: 0.6),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    // Sign Up Tab
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _changeTab(1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedIndex == 1
                                ? AppColors.darkBlue
                                : AppColors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Sign Up',
                            style: selectedIndex == 1
                                ? AppTextStyles.bodyLargeMedium
                                    .copyWith(color: AppColors.white)
                                : AppTextStyles.bodyLargeMedium.copyWith(
                                    color: AppColors.darkBlue
                                        .withValues(alpha: 0.6),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Content - lazy loaded
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _getPage(selectedIndex),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
