import 'package:formz/formz.dart';
import 'package:intl/intl.dart';

enum DateTimeValidateError {
  invalid,
  required,
  notBeforeNow,
}

class DateTimeValidate extends FormzInput<String, DateTimeValidateError> {
  const DateTimeValidate.pure([super.value = '']) : super.pure();
  const DateTimeValidate.dirty([super.value = '']) : super.dirty();

  // Updated regex to accept formatted date time from DatePicker
  static final _dateTimeRegex = RegExp(
    r"^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday), \d{2} (January|February|March|April|May|June|July|August|September|October|November|December) \d{4} - \d{2}:\d{2} (AM|PM)$",
  );

  @override
  DateTimeValidateError? validator(String? value) {
    final dateTimeFormat = DateFormat('EEEE, dd MMMM yyyy - HH:mm a');
    final parseDateTime = dateTimeFormat.parse(value ?? '');
    final currentDateTime = DateTime.now();
    final isValidDateTime = parseDateTime.isBefore(currentDateTime);
    if (value == null || value.trim().isEmpty) {
      return DateTimeValidateError.required;
    } else if (isValidDateTime) {
      return DateTimeValidateError.notBeforeNow;
    } else if (!_dateTimeRegex.hasMatch(value)) {
      return DateTimeValidateError.invalid;
    } else {
      return null;
    }
  }
}
