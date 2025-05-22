import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/authentication/models/ChangePasswordReq.dart';
import 'package:home_service/modules/authentication/repos/login_repo.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';

import '../../../blocs/form_validate/form_bloc.dart';
import '../../../common/widgets/stateless/basic_button.dart';
import '../../../common/widgets/stateless/show_snack_bar.dart';
import '../../../routes/route_name.dart';
import '../../../themes/styles_text.dart';
import '../blocs/login/login_bloc.dart';
import '../blocs/login/login_event.dart';
import '../blocs/login/login_state.dart';
import '../widgets/custom_text_field.dart';

class SetNewPasswordPage extends StatefulWidget {
  const SetNewPasswordPage({super.key});

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final NavigationService _navigationService = NavigationService();

  String _token = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _token = args['token'] as String? ?? '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _password.dispose();
    _confirmPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LoginBloc(LoginRepo()),
          ),
          BlocProvider(
            create: (context) => FormFieldBloc(),
          ),
        ],
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              ShowSnackBar.showSuccess(context, state.message, 'Well done!');
              _navigationService.navigateToAndClearStack(RouteName.authScreen);
            } else if (state is LoginFailure) {
              ShowSnackBar.showError(context, state.error);
            }
          },
          child: BlocBuilder<FormFieldBloc, FormFieldStates>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        'New Password',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildAddNewPassword(context, state),
                      const SizedBox(height: 20),
                      _buildConfirmPassword(context, state),
                      const SizedBox(height: 70),
                      _buildSubmitButton(context, state),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewPassword(BuildContext context, FormFieldStates state) {
    final error = <String>[];

    if (_password.text.isEmpty) {
      error.add("Please enter your password.");
    } else if (!state.password.isValid) {
      error.add(
          "Minimum 8 characters with a number, uppercase, lowercase, and special character.");
    }

    return CustomTextField(
      controller: _password,
      label: 'Add New Password',
      hintText: 'Enter password',
      isPassword: true,
      onChanged: (value) {
        context.read<FormFieldBloc>().add(PasswordChanged(value));
      },
      onUnfocused: () {
        context.read<FormFieldBloc>().add(PasswordUnfocused());
      },
      errorMessages: error,
      prefixIcon: null,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildConfirmPassword(BuildContext context, FormFieldStates state) {
    final error = <String>[];

    if (_confirmPassword.text.isEmpty) {
      error.add("Please enter your password.");
    } else if (_confirmPassword.text != _password.text) {
      error.add("Passwords do not match.");
    }

    return CustomTextField(
      controller: _confirmPassword,
      label: 'Confirm Password',
      hintText: 'Enter password',
      isPassword: true,
      onChanged: (value) {
        setState(() {
          _confirmPassword.text = value;
        });
      },
      onUnfocused: () {},
      errorMessages: error,
      prefixIcon: null,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildSubmitButton(BuildContext context, FormFieldStates state) {
    final isValidForm = _password.text.isNotEmpty &&
        _confirmPassword.text.isNotEmpty &&
        _password.text == _confirmPassword.text;

    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          bool isLoading = state is LoginLoading;
          return BasicButton(
            title: isLoading ? 'Loading...' : 'Done',
            onPressed: isValidForm && !isLoading
                ? () {
                    context.read<LoginBloc>().add(
                          ChangePasswordEvent(
                            changePasswordReq: ChangePasswordReq(
                                token: _token,
                                password: _password.text.toString(),
                                confirmPassword:
                                    _confirmPassword.text.toString()),
                          ),
                        );
                  }
                : null,
          );
        },
      ),
    );
  }
}
