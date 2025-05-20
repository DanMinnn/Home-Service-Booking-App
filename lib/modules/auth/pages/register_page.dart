import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/blocs/form_validate/form_bloc.dart';
import 'package:home_service_tasker/modules/auth/bloc/bloc_login/auth_bloc.dart';
import 'package:home_service_tasker/modules/auth/bloc/bloc_login/auth_event.dart';
import 'package:home_service_tasker/modules/auth/repo/auth_repo.dart';

import '../../../common/widget/app_bar.dart';
import '../../../common/widget/basic_button.dart';
import '../../../common/widget/custom_text_field.dart';
import '../../../common/widget/show_snack_bar.dart';
import '../../../routes/navigation_service.dart';
import '../../../routes/route_name.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';
import '../bloc/bloc_login/auth_state.dart';
import '../model/register_req.dart';

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
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullName.dispose();
    _phoneController.dispose();
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
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => FormFieldBloc(),
                ),
                BlocProvider(
                  create: (context) => AuthBloc(AuthRepo()),
                ),
              ],
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    ShowSnackBar.showSuccess(
                        context, state.message.toString(), 'Well done!');
                  } else if (state is AuthFailure) {
                    ShowSnackBar.showError(context, 'Signup failed');
                  }
                },
                child: BlocBuilder<FormFieldBloc, FormFieldStates>(
                  builder: (context, state) {
                    return Column(
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
                        Text(
                            "Seems you are new here, \nLet’s set up your profile.",
                            style: AppTextStyles.headlineSubTitle.copyWith(
                              color:
                                  AppColors.accentGrey.withValues(alpha: 0.5),
                            )),
                        const SizedBox(height: 30),
                        _buildFullNameField(context, state),
                        const SizedBox(height: 16),
                        _buildEmailField(context, state),
                        const SizedBox(height: 16),
                        _buildPhoneField(context, state),
                        const SizedBox(height: 16),
                        _buildPasswordField(context, state),
                        const SizedBox(height: 24),
                        _buildRegisterButton(context, state),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: AppTextStyles.paragraph3.copyWith(
                                color:
                                    AppColors.accentGrey.withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () {
                                _navigationService
                                    .navigateTo(RouteName.loginScreen);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
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
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameField(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    if (state.username.isPure && state.username.value.trim().isEmpty) {
      errors.add("Please enter your name.");
    } else if (state.username.value.length < 4) {
      errors.add("Name must be at least 4 characters.");
    }
    return CustomInputField(
      controller: _fullName,
      label: 'Full Name',
      onChanged: (value) {
        context.read<FormFieldBloc>().add(UsernameChanged(value));
      },
      isPassword: false,
      errorMessages: errors,
    );
  }

  Widget _buildEmailField(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    if (state.email.isPure && state.email.value.trim().isEmpty) {
      errors.add("Please enter your email.");
    } else if (!state.email.isValid) {
      errors.add("Please enter a valid email.");
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

  Widget _buildPhoneField(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    if (state.phoneNumber.isPure && state.phoneNumber.value.trim().isEmpty) {
      errors.add("Please enter your phone number.");
    } else if (!state.phoneNumber.isValid) {
      errors.add("Phone number is invalid");
    }
    return CustomInputField(
      controller: _phoneController,
      label: 'Phone Number',
      onChanged: (value) {
        context.read<FormFieldBloc>().add(PhoneNumberChanged(value));
      },
      isPassword: false,
      errorMessages: errors,
    );
  }

  Widget _buildPasswordField(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    if (state.password.isPure && state.password.value.trim().isEmpty) {
      errors.add("Please enter your password.");
    } else if (!state.password.isValid) {
      errors.add(
          "Minimum 8 characters with a number, uppercase, lowercase, and special character.");
    }
    return CustomInputField(
      controller: _passwordController,
      label: 'Password',
      onChanged: (value) {
        context.read<FormFieldBloc>().add(PasswordChanged(value));
      },
      isPassword: true,
      errorMessages: errors,
    );
  }

  Widget _buildRegisterButton(BuildContext context, FormFieldStates state) {
    bool isFormValid = state.username.isValid &&
        state.email.isValid &&
        state.phoneNumber.isValid &&
        state.password.isValid;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final bool isLoading = state is LoginLoading;

        return BasicButton(
          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
          text: isLoading ? 'Registering..' : 'Continue',
          onPressed:
              isFormValid && !isLoading ? () => _onRegister(context) : null,
        );
      },
    );
  }

  void _onRegister(BuildContext context) {
    final req = RegisterReq(
      firstLastName: _fullName.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      verify: true,
      isActive: true,
      status: 'available',
    );

    context.read<AuthBloc>().add(RegisterSubmitted(req));
  }
}
