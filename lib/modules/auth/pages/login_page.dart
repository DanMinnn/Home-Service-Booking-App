import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/common/widget/basic_button.dart';
import 'package:home_service_tasker/modules/auth/repo/auth_repo.dart';
import 'package:home_service_tasker/providers/log_provider.dart';
import 'package:home_service_tasker/routes/navigation_service.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:home_service_tasker/theme/app_assets.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

import '../../../blocs/app_state_bloc.dart';
import '../../../blocs/form_validate/form_bloc.dart';
import '../../../common/widget/custom_text_field.dart';
import '../../../common/widget/show_snack_bar.dart';
import '../bloc/bloc_login/auth_bloc.dart';
import '../bloc/bloc_login/auth_event.dart';
import '../bloc/bloc_login/auth_state.dart';
import '../model/login_req.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final NavigationService _navigationService = NavigationService();
  final LogProvider logger = LogProvider("LOGIN-PAGE::::::");

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
      body: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(AuthRepo()),
          ),
          BlocProvider<FormFieldBloc>(
            create: (context) => FormFieldBloc(),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.read<AppStateBloc>().changeAppState(AppState.authorized);
              logger.log(
                  "Login successful. Redirecting to home screen. email ${_emailController.text}");

              context
                  .read<AuthBloc>()
                  .add(GetTaskerInfo(_emailController.text));
            } else if (state is AuthFailure) {
              ShowSnackBar.showError(context,
                  'Login failed. Please check your email and password.');
              logger.log("Login failed: ${state.error}");
            } else if (state is TaskerInfoLoaded) {
              final tasker = state.tasker;
              if (tasker.active == false) {
                ShowSnackBar.showError(context,
                    'Sorry, your account is maybe deleted. Please contact admin.');
                return;
              }
              Future.delayed(const Duration(milliseconds: 100), () {
                _navigationService
                    .navigateToAndClearStack(RouteName.homeScreen);
              });
            }
          },
          child: BlocBuilder<FormFieldBloc, FormFieldStates>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Text("Let's Sign You In",
                              style: AppTextStyles.headline1),
                          const SizedBox(height: 12),
                          Text(
                            "Welcome back, you've been missed!",
                            style: AppTextStyles.headlineSubTitle.copyWith(
                              color:
                                  AppColors.accentGrey.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildEmailTextField(context, state),
                          const SizedBox(height: 16),
                          _buildPasswordTextField(context, state),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  _navigationService.navigateTo(
                                      RouteName.forgotPasswordScreen);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.deepOrange,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
                          _buildLoginButton(),
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
                                  color: AppColors.accentGrey
                                      .withValues(alpha: 0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: () {
                                  _navigationService
                                      .navigateTo(RouteName.registerScreen);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.deepOrange,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    if (state.email.isPure && state.email.value.trim().isEmpty) {
      errors.add("Please enter your email.");
    } else if (!state.email.isValid) {
      errors.add("Email is invalid");
    }

    return CustomInputField(
      controller: _emailController,
      label: 'Email Address',
      onChanged: (value) {
        context.read<FormFieldBloc>().add(EmailChanged(value));
      },
      isPassword: false,
      errorMessages: errors,
    );
  }

  Widget _buildPasswordTextField(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    if (state.password.isPure && state.password.value.trim().isEmpty) {
      errors.add("Please enter your password.");
    }
    return CustomInputField(
      controller: _passwordController,
      label: 'Password',
      onChanged: (value) {
        context.read<FormFieldBloc>().add(PasswordChanged(value));
      },
      isPassword: true,
    );
  }

  Widget _buildLoginButton() {
    bool isValidForm = _emailController.text.toString().isNotEmpty &&
        _passwordController.text.toString().isNotEmpty;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, loginState) {
        final bool isLoading = loginState is LoginLoading;

        return BasicButton(
          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
          text: isLoading ? 'Logging in...' : 'Login',
          onPressed:
              isValidForm && !isLoading ? () => _onLoginPressed(context) : null,
        );
      },
    );
  }

  void _onLoginPressed(BuildContext context) {
    final req = LoginReq(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    context.read<AuthBloc>().add(LoginSubmitted(req));
    logger.log('Login request: ${req.toJson()}');
  }
}
