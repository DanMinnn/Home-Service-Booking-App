import 'package:formz/formz.dart';

enum AddressValidatorError { required, invalid }

class AddressValidator extends FormzInput<String, AddressValidatorError> {
  const AddressValidator.pure([super.value = '']) : super.pure();
  const AddressValidator.dirty([super.value = '']) : super.dirty();

  @override
  AddressValidatorError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) {
      return AddressValidatorError.required;
    } else if (value.length < 15) {
      return AddressValidatorError.invalid;
    } else {
      return null;
    }
  }
}
