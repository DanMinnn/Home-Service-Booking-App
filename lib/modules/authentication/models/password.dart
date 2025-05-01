import 'package:formz/formz.dart';

enum PasswordValidationError { invalid, required }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure([super.value = '']) : super.pure();
  const Password.dirty([super.value = '']) : super.dirty();

  static final _passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~])[A-Za-z\d!@#\$&*~]{8,}$');

  @override
  PasswordValidationError? validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return PasswordValidationError.required;
    } else if (!_passwordRegex.hasMatch(value)) {
      return PasswordValidationError.invalid;
    } else {
      return null;
    }
  }
}
