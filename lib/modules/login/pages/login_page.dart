import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/login/repo/login_repo.dart';
import 'package:home_service_admin/ui/main_screen.dart';

import '../../../themes/app_assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/style_text.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../models/login_req.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.text,
      body: Row(
        children: [
          Container(
            width: 400,
            color: AppColors.neutral,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        AppAssetsBackgrounds.logo,
                        height: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Home Service',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildFormField('Email', 'Enter your email'),
                  const SizedBox(height: 24),
                  _buildFormField('Password', 'Enter your password'),
                  const SizedBox(height: 10),

                  // Error message display
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),
                  BlocProvider(
                    create: (context) => AuthBloc(LoginRepo()),
                    child: BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is LoginSuccess) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => MainScreen(
                                  email: _emailController.text.toString()),
                            ),
                          );
                        } else if (state is LoginError) {
                          setState(() {
                            _errorMessage = 'Check your email and password';
                          });
                        }
                      },
                      builder: (context, state) {
                        final bool isLoading = state is LoginLoading;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: !isLoading
                                ? () => _onLoginPressed(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.5),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isLoading ? 'Logging in...' : 'Login',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Center(
                child: Image.asset(AppAssetsBackgrounds.bgLogin),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint) {
    return TextField(
      controller: label.toLowerCase() == 'email'
          ? _emailController
          : _passwordController,
      obscureText: label.toLowerCase() == 'password',
      onChanged: (value) {
        if (_errorMessage != null) {
          setState(() {
            _errorMessage = null;
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.titleSmall,
        hintStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textLight,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  void _onLoginPressed(BuildContext context) {
    setState(() {
      _errorMessage = null;
    });

    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Email cannot be empty";
      });
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Password cannot be empty";
      });
      return;
    }

    final req = LoginReq(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    context.read<AuthBloc>().add(LoginSubmitted(req));
  }
}
