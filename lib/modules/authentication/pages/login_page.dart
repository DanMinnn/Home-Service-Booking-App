import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/blocs/app_state_bloc.dart';
import 'package:home_service/blocs/form_validate/form_bloc.dart';
import 'package:home_service/common/widgets/stateless/basic_button.dart';
import 'package:home_service/common/widgets/stateless/show_snack_bar.dart';
import 'package:home_service/modules/authentication/blocs/login/login_event.dart';
import 'package:home_service/modules/authentication/widgets/custom_text_field.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';

import '../../../themes/styles_text.dart';
import '../blocs/login/login_bloc.dart';
import '../blocs/login/login_state.dart';
import '../models/login_req.dart';
import '../repos/login_repo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FormFieldBloc()),
        BlocProvider(create: (_) => LoginBloc(LoginRepo())),
      ],
      child: const LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  LogProvider get logger => const LogProvider('LOGIN-PAGE:::');
  final NavigationService _navigationService = NavigationService();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<AppStateBloc>().changeAppState(AppState.authorized);
          logger.log(
              "Login successful. Redirecting to home screen. email ${_email.text}");

          context.read<LoginBloc>().add(GetUserInfo(_email.text));
        } else if (state is LoginFailure) {
          ShowSnackBar.showError(
              context, 'Login failed. Please check your email and password.');
          logger.log("Login failed: ${state.error}");
        } else if (state is UserInfoLoaded) {
          final user = state.user;
          if (user.active == false) {
            ShowSnackBar.showError(context,
                'Sorry, your account is maybe deleted. Please contact admin.');
            return;
          }
          Future.delayed(const Duration(milliseconds: 100), () {
            _navigationService.navigateToAndClearStack(RouteName.homeScreen);
          });
        }
      },
      child: BlocBuilder<FormFieldBloc, FormFieldStates>(
        buildWhen: (previous, current) =>
            previous.email != current.email ||
            previous.password != current.password,
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: AppColors.white,
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildTextWelcomeBack(),
                          const SizedBox(height: 30),
                          _buildEmailTextField(context, state),
                          const SizedBox(height: 20),
                          _buildPasswordTextField(context, state),
                          const SizedBox(height: 16),
                          _buildForgetPassword(),
                          const SizedBox(height: 30),
                          _buildBtnLogin(),
                          const SizedBox(height: 10),
                          _buildOrSplitDivider(),
                          const SizedBox(height: 10),
                          _buildButtonLoginFbOrGoogle(),
                          const SizedBox(height: 20),
                          //_buildNotMember(),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<LoginBloc, LoginState>(
                    buildWhen: (previous, current) =>
                        previous is LoginLoading != current is LoginLoading,
                    builder: (context, state) {
                      if (state is LoginLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextWelcomeBack() {
    return Text(
      'Welcome to back',
      style: AppTextStyles.h4.copyWith(
        color: AppColors.darkBlue,
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
    return CustomTextField(
      controller: _email,
      label: 'Email',
      hintText: 'example@email.com',
      prefixIcon: Image.asset(AppAssetIcons.email),
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        context.read<FormFieldBloc>().add(EmailChanged(value));
      },
      onUnfocused: () {
        context.read<FormFieldBloc>().add(EmailUnfocused());
      },
      errorMessages: errors,
    );
  }

  Widget _buildPasswordTextField(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    if (state.password.isPure && state.password.value.trim().isEmpty) {
      errors.add("Please enter your password.");
    }

    return CustomTextField(
      controller: _password,
      label: 'Password',
      hintText: 'Enter password',
      prefixIcon: Image.asset(AppAssetIcons.password),
      keyboardType: TextInputType.visiblePassword,
      onChanged: (value) {
        context.read<FormFieldBloc>().add(PasswordChanged(value));
      },
      onUnfocused: () {
        context.read<FormFieldBloc>().add(PasswordUnfocused());
      },
      errorMessages: errors,
      isPassword: true,
    );
  }

  Widget _buildForgetPassword() {
    return GestureDetector(
      onTap: () {
        _navigationService.navigateTo(RouteName.forgotPasswordScreen);
      },
      child: Text(
        'Forget password?',
        style: AppTextStyles.bodyMediumRegular.copyWith(color: AppColors.green),
      ),
    );
  }

  Widget _buildBtnLogin() {
    bool isValidForm = _email.text.toString().isNotEmpty &&
        _password.text.toString().isNotEmpty;

    return SizedBox(
        width: double.infinity,
        child: BasicButton(
            onPressed: isValidForm ? () => _onLoginPressed(context) : null,
            title: 'Login'));
  }

  void _onLoginPressed(BuildContext context) {
    final req = LoginReq(
      email: _email.text.trim(),
      password: _password.text.trim(),
    );

    context.read<LoginBloc>().add(LoginSubmitted(req));
    logger.log('Login request: ${req.toJson()}');
  }

  Widget _buildOrSplitDivider() {
    return Row(
      children: [
        Expanded(
          child: DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            dashColor: AppColors.darkBlue.withValues(alpha: 0.20),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'Or',
            style: AppTextStyles.bodyMediumSemiBold
                .copyWith(color: AppColors.black),
          ),
        ),
        Expanded(
          child: DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            dashColor: AppColors.darkBlue.withValues(alpha: 0.20),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonLoginFbOrGoogle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.loginWith,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide.none,
              minimumSize: Size(156.0, 48.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
              child: Image.asset(
                AppAssetIcons.fb,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          flex: 1,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.loginWith,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide.none,
              minimumSize: Size(156.0, 48.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
              child: Image.asset(
                AppAssetIcons.google,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotMember() {
    return Row(
      children: [
        Text(
          'Not you member?',
          style: AppTextStyles.bodyLargeMedium.copyWith(
            color: AppColors.darkBlue.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          ' Sign up',
          style: AppTextStyles.bodyLargeMedium
              .copyWith(color: AppColors.blue, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
