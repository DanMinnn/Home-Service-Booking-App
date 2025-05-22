import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/blocs/form_validate/form_bloc.dart';
import 'package:home_service_tasker/common/widget/show_snack_bar.dart';
import 'package:home_service_tasker/modules/auth/repo/auth_repo.dart';

import '../../../common/widget/app_bar.dart';
import '../../../common/widget/basic_button.dart';
import '../../../common/widget/custom_text_field.dart';
import '../../../routes/navigation_service.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';
import '../bloc/bloc_login/auth_bloc.dart';
import '../bloc/bloc_login/auth_event.dart';
import '../bloc/bloc_login/auth_state.dart';

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
      body: MultiBlocProvider(
        providers: [
          BlocProvider<FormFieldBloc>(
            create: (context) => FormFieldBloc(),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              AuthRepo(),
            ),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ShowSnackBar.showSuccess(context, state.message, 'Well done!');
            } else if (state is AuthFailure) {
              ShowSnackBar.showError(context, 'Check your email again!');
            }
          },
          child: BlocBuilder<FormFieldBloc, FormFieldStates>(
            builder: (context, state) {
              return SafeArea(
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
                        _buildEmailTextField(context, state),
                        const SizedBox(height: 30),
                        _onResetPassword(),
                      ],
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

  Widget _onResetPassword() {
    final validEmail = _emailController.text.trim().isNotEmpty;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        return BasicButton(
          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
          text: isLoading ? 'Sending...' : 'Reset Password',
          onPressed: validEmail && !isLoading
              ? () {
                  context.read<AuthBloc>().add(
                        ResetPasswordSubmitted(
                          email: _emailController.text.trim(),
                        ),
                      );
                }
              : null,
        );
      },
    );
  }
}
