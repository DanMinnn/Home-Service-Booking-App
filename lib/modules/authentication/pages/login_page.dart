import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/common/widgets/stateless/basic_button.dart';
import 'package:home_service/modules/authentication/blocs/form_bloc.dart';
import 'package:home_service/modules/authentication/widgets/custom_text_field.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';

import '../../../themes/styles_text.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormFieldBloc(),
      child: const LoginForm(),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormFieldBloc, FormFieldStates>(
      buildWhen: (previous, current) => 
        previous.email != current.email || previous.password != current.password,
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: AppColors.white,
            body: Padding(
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
                    _buildNotMember(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
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
  return Text(
    'Forget password?',
    style: AppTextStyles.bodyMediumRegular.copyWith(color: AppColors.green),
  );
}

Widget _buildBtnLogin() {
  return SizedBox(
      width: double.infinity,
      child: BasicButton(onPressed: () {}, title: 'Login'));
}

Widget _buildOrSplitDivider() {
  return Row(
    children: [
      Expanded(
        child: DottedLine(
          direction: Axis.horizontal,
          lineLength: double.infinity,
          dashColor: AppColors.darkBlue.withAlpha(20),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Text(
          'Or',
          style:
              AppTextStyles.bodyMediumSemiBold.copyWith(color: AppColors.black),
        ),
      ),
      Expanded(
        child: DottedLine(
          direction: Axis.horizontal,
          lineLength: double.infinity,
          dashColor: AppColors.darkBlue.withAlpha(20),
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
          color: AppColors.darkBlue.withAlpha(60),
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

