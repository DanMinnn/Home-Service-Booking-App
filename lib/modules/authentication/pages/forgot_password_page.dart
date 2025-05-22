import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/blocs/form_validate/form_bloc.dart';
import 'package:home_service/modules/authentication/blocs/login/login_event.dart';
import 'package:home_service/modules/authentication/repos/login_repo.dart';
import 'package:home_service/themes/app_colors.dart';

import '../../../common/widgets/stateless/basic_button.dart';
import '../../../common/widgets/stateless/show_snack_bar.dart';
import '../../../themes/app_assets.dart';
import '../../../themes/styles_text.dart';
import '../blocs/login/login_bloc.dart';
import '../blocs/login/login_state.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FormFieldBloc(),
          ),
          BlocProvider(
            create: (context) => LoginBloc(LoginRepo()),
          ),
        ],
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              ShowSnackBar.showSuccess(context, state.message, 'Well done!');
            } else if (state is LoginFailure) {
              ShowSnackBar.showError(context, 'Check your email again!');
            }
          },
          child: BlocBuilder<FormFieldBloc, FormFieldStates>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      'Forgot Password',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please enter your email. We will send you a link to reset your password.',
                      style: AppTextStyles.bodyMediumRegular.copyWith(
                        color: AppColors.darkBlue.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildEmailTextField(context, state),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
                  ],
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
      errors.add("Invalid email format.");
    }
    return CustomTextField(
      controller: _email,
      label: 'Email',
      hintText: 'Enter email',
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

  Widget _buildSubmitButton() {
    bool isValidForm = _email.text.toString().trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          bool isLoading = state is LoginLoading;
          return BasicButton(
            title: isLoading ? 'Sending...' : 'Continue',
            onPressed: isValidForm && !isLoading
                ? () {
                    context
                        .read<LoginBloc>()
                        .add(ForgotPasswordEvent(email: _email.text));
                  }
                : null,
          );
        },
      ),
    );
  }
}
