import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/blocs/form_validate/form_bloc.dart';
import 'package:home_service/modules/authentication/blocs/signup/signup_bloc.dart';
import 'package:home_service/modules/authentication/repos/signup_repo.dart';

import '../../../common/widgets/stateless/basic_button.dart';
import '../../../providers/log_provider.dart';
import '../../../themes/app_assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';
import '../blocs/signup/signup_event.dart';
import '../blocs/signup/signup_state.dart';
import '../models/signup_req.dart';
import '../widgets/custom_text_field.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Optimizing providers to create only once
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FormFieldBloc()),
        BlocProvider(create: (_) => SignupBloc(SignupRepo())),
      ],
      child: const SignupForm(),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();

  LogProvider get logger => const LogProvider('SIGNUP PAGE');

  @override
  dispose() {
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state is SignupSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 5),
                backgroundColor: AppColors.green),
          );
          //Navigator.of(context).pushReplacementNamed('/login');
        } else if (state is SignupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Signup failed"),
                duration: Duration(seconds: 5),
                backgroundColor: Colors.red),
          );
          logger.log(
            "Signup failed: ${state.error}",
          );
        }
      },
      child: BlocBuilder<FormFieldBloc, FormFieldStates>(
        buildWhen: (previous, current) =>
            previous.username != current.username ||
            previous.email != current.email ||
            previous.phoneNumber != current.phoneNumber ||
            previous.password != current.password,
        builder: (context, state) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
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
                          _buildTextCreateAccount(),
                          const SizedBox(height: 15),
                          _buildNameTextField(context, state),
                          const SizedBox(height: 15),
                          _buildEmailTextField(context, state),
                          const SizedBox(height: 15),
                          _buildPhoneTextField(context, state),
                          const SizedBox(height: 15),
                          _buildPasswordTextField(context, state),
                          const SizedBox(height: 16),
                          _buildBtnSignup(context, state),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<SignupBloc, SignupState>(
                    buildWhen: (previous, current) =>
                        previous is SignupLoading != current is SignupLoading,
                    builder: (context, state) {
                      if (state is SignupLoading) {
                        return Container(
                          color: AppColors.black.withValues(alpha: 0.5),
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
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
      controller: _username,
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

  Widget _buildPhoneTextField(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    if (state.phoneNumber.isPure && state.phoneNumber.value.trim().isEmpty) {
      errors.add("Please enter your phone number.");
    } else if (!state.phoneNumber.isValid) {
      errors.add("Phone number is invalid");
    }

    return CustomTextField(
      controller: _phone,
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
      controller: _password,
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

  Widget _buildBtnSignup(BuildContext context, FormFieldStates state) {
    bool isFormValid = state.username.isValid &&
        state.email.isValid &&
        state.phoneNumber.isValid &&
        state.password.isValid;

    return SizedBox(
      width: double.infinity,
      child: BasicButton(
          onPressed: isFormValid ? () => _onSignupPressed(context) : null,
          title: 'Sign up'),
    );
  }

  void _onSignupPressed(BuildContext context) {
    final req = SignupReq(
      firstLastName: _username.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      password: _password.text.trim(),
      verify: false,
      isActive: true,
      type: 'customer',
    );
    context.read<SignupBloc>().add(SignupSubmitted(req));
    logger.log('Signup request: ${req.toJson()}');
  }
}
