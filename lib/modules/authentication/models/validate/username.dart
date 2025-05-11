import 'package:formz/formz.dart';

enum UsernameValidationError { invalid, required }

class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure([super.value = '']) : super.pure();
  const Username.dirty([super.value = '']) : super.dirty();

  @override
  UsernameValidationError? validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return UsernameValidationError.required;
    }
    if (value.length < 4) {
      return UsernameValidationError.invalid;
    }
    return null;
  }
}
