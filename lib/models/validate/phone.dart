import 'package:formz/formz.dart';

enum PhoneNumberValidationError { invalid, required }

class PhoneNumber extends FormzInput<String, PhoneNumberValidationError> {
  const PhoneNumber.pure([super.value = '']) : super.pure();
  const PhoneNumber.dirty([super.value = '']) : super.dirty();

  static final _phoneNumberRegex =
      RegExp(r'^(03|05|07|08|09|01[2|6|8|9])[0-9]{8}$');

  @override
  PhoneNumberValidationError? validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return PhoneNumberValidationError.required;
    } else if (!_phoneNumberRegex.hasMatch(value)) {
      return PhoneNumberValidationError.invalid;
    } else {
      return null;
    }
  }
}
