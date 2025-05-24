import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/common/widget/app_bar.dart';
import 'package:home_service_tasker/common/widget/show_snack_bar.dart';
import 'package:home_service_tasker/modules/auth/bloc/bloc_login/auth_event.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:home_service_tasker/theme/app_assets.dart';

import '../../../blocs/form_validate/form_bloc.dart';
import '../../../common/widget/basic_button.dart';
import '../../../common/widget/custom_text_field.dart';
import '../../../providers/log_provider.dart';
import '../../../routes/navigation_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';
import '../bloc/bloc_login/auth_bloc.dart';
import '../bloc/bloc_login/auth_state.dart';
import '../model/change_password_req.dart';
import '../repo/auth_repo.dart';

class SetNewPassword extends StatefulWidget {
  const SetNewPassword({super.key});

  @override
  State<SetNewPassword> createState() => _SetNewPasswordState();
}

class _SetNewPasswordState extends State<SetNewPassword> {
  final NavigationService _navigationService = NavigationService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final LogProvider logger = const LogProvider('SET-NEW-PASSWORD::::');
  String token = '';
  bool isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    logger.log('Received arguments: $args');

    if (args != null && args is Map<String, dynamic>) {
      setState(() {
        token = args['token'] as String? ?? '';
        logger.log('Token set to: $token');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(AuthRepo()),
          ),
          BlocProvider(
            create: (context) => FormFieldBloc(),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ShowSnackBar.showSuccess(context, state.message, 'Well done!');
              _navigationService.navigateToAndClearStack(RouteName.loginScreen);
            } else if (state is AuthFailure) {
              ShowSnackBar.showError(context, state.error);
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
                              _navigationService.navigateToAndClearStack(
                                  RouteName.loginScreen);
                            },
                            child: Image.asset(
                              AppAssetsIcons.arrowLeft,
                              color: AppColors.dark,
                            ),
                          ),
                          title: 'Set New Password',
                        ),
                        Text("Set new password",
                            style: AppTextStyles.headline1),
                        const SizedBox(height: 12),
                        Text(
                          "Create strong and secured\nnew password.",
                          style: AppTextStyles.headlineSubTitle.copyWith(
                            color: AppColors.accentGrey.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 35),
                        _buildPasswordTextField(context, state),
                        const SizedBox(height: 16),
                        _buildConfirmPasswordTextField(context, state),
                        const SizedBox(height: 30),
                        _buildSaveButton(context, state),
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

  Widget _buildPasswordTextField(BuildContext context, FormFieldStates state) {
    final error = <String>[];

    if (_passwordController.text.isEmpty) {
      error.add("Please enter your password.");
    } else if (!state.password.isValid) {
      error.add(
          "Minimum 8 characters with a number, uppercase, lowercase, and special character.");
    }
    return CustomInputField(
      controller: _passwordController,
      label: 'Password',
      onChanged: (value) {
        context.read<FormFieldBloc>().add(PasswordChanged(value));
      },
      isPassword: true,
      errorMessages: error,
    );
  }

  Widget _buildConfirmPasswordTextField(
      BuildContext context, FormFieldStates state) {
    final error = <String>[];

    if (_confirmPassword.text.isEmpty) {
      error.add("Please enter confirm password.");
    } else if (_confirmPassword.text != _passwordController.text) {
      error.add("Passwords do not match.");
    }
    return CustomInputField(
      controller: _confirmPassword,
      label: 'Password',
      onChanged: (value) {
        setState(() {
          _confirmPassword.text = value;
        });
      },
      isPassword: true,
      errorMessages: error,
    );
  }

  Widget _buildSaveButton(BuildContext context, FormFieldStates state) {
    final isValid = _passwordController.text.isNotEmpty &&
        _confirmPassword.text.isNotEmpty &&
        _passwordController.text == _confirmPassword.text;

    final req = ChangePasswordReq(
      secretCode: token,
      newPassword: _passwordController.text,
      confirmPassword: _confirmPassword.text,
    );
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is LoginLoading;
        return BasicButton(
          backgroundColor: AppColors.primary,
          textColor: AppColors.white,
          text: isLoading ? 'Saving...' : 'Save Password',
          onPressed: isValid && !isLoading
              ? () {
                  context
                      .read<AuthBloc>()
                      .add(ChangePasswordSubmitted(changePasswordReq: req));
                }
              : null,
        );
      },
    );
  }
}
