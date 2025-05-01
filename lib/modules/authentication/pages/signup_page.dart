import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/authentication/blocs/form_bloc.dart';

import '../../../common/widgets/stateless/basic_button.dart';
import '../../../themes/app_assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';
import '../widgets/custom_text_field.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormFieldBloc(),
      child: SignupForm(),
    );
  }
}

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormFieldBloc, FormFieldStates>(
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
                    SizedBox(height: 30),
                    _buildTextCreateAccount(),
                    SizedBox(height: 15),
                    _buildNameTextField(context, state),
                    SizedBox(height: 15),
                    _buildEmailTextField(context, state),
                    SizedBox(height: 15),
                    _buildPhoneTextField(context, state),
                    SizedBox(height: 15),
                    _buildPasswordTextField(context, state),
                    SizedBox(height: 16),
                    _buildBtnSignup(),
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

Widget _buildTextCreateAccount() {
  return Text(
    'Create an account',
    style: AppTextStyles.h4.copyWith(
      color: AppColors.darkBlue,
    ),
  );
}

Widget _buildNameTextField(BuildContext context, FormFieldStates state) {
  final errors = <String>[];

  if (state.username.isPure && state.username.value.trim().isEmpty) {
    errors.add("Please enter your name.");
  } else if (state.username.value.length < 4) {
    errors.add("Name must be at least 4 characters.");
  }
  return CustomTextField(
    label: 'First and last name',
    hintText: 'John Legend',
    prefixIcon: ColorFiltered(
        colorFilter: ColorFilter.mode(
          AppColors.darkBlue.withValues(alpha: 0.6),
          BlendMode.srcIn,
        ),
        child: Image.asset(AppAssetIcons.profile)),
    keyboardType: TextInputType.text,
    onChanged: (value) {
      context.read<FormFieldBloc>().add(UsernameChanged(value));
    },
    onUnfocused: () {
      context.read<FormFieldBloc>().add(UsernameUnfocused());
    },
    errorMessages: errors,
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

Widget _buildPhoneTextField(BuildContext context, FormFieldStates state) {
  final errors = <String>[];

  if (state.phoneNumber.isPure && state.phoneNumber.value.trim().isEmpty) {
    errors.add("Please enter your phone number.");
  } else if (!state.phoneNumber.isValid) {
    errors.add("Phone number is invalid");
  }

  return CustomTextField(
    label: 'Phone',
    hintText: '0978123456',
    prefixIcon: ColorFiltered(
      colorFilter: ColorFilter.mode(
        AppColors.darkBlue.withValues(alpha: 0.6),
        BlendMode.srcIn,
      ),
      child: Image.asset(AppAssetIcons.phoneNumber),
    ),
    keyboardType: TextInputType.phone,
    onChanged: (value) {
      context.read<FormFieldBloc>().add(PhoneNumberChanged(value));
    },
    onUnfocused: () {
      context.read<FormFieldBloc>().add(PhoneNumberUnfocused());
    },
    errorMessages: errors,
  );
}

Widget _buildPasswordTextField(BuildContext context, FormFieldStates state) {
  final errors = <String>[];

  if (state.password.isPure && state.password.value.trim().isEmpty) {
    errors.add("Please enter your password.");
  } else if (!state.password.isValid) {
    errors.add("Password is invalid");
  }
  return CustomTextField(
    label: 'Password',
    hintText: 'Enter password',
    prefixIcon: Image.asset(AppAssetIcons.password),
    keyboardType: TextInputType.text,
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

Widget _buildBtnSignup() {
  return SizedBox(
      width: double.infinity,
      child: BasicButton(onPressed: () {}, title: 'Sign up'));
}
