part of 'form_bloc.dart';

abstract class FormFieldEvent extends Equatable {
  const FormFieldEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends FormFieldEvent {
  final String email;
  const EmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class EmailUnfocused extends FormFieldEvent {}

class PasswordChanged extends FormFieldEvent {
  final String password;
  const PasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class PasswordUnfocused extends FormFieldEvent {}

class PhoneNumberChanged extends FormFieldEvent {
  final String phoneNumber;
  const PhoneNumberChanged(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class PhoneNumberUnfocused extends FormFieldEvent {}

class UsernameChanged extends FormFieldEvent {
  final String username;
  const UsernameChanged(this.username);

  @override
  List<Object> get props => [username];
}

class UsernameUnfocused extends FormFieldEvent {}

class DateTimeChanged extends FormFieldEvent {
  final String dateTime;
  const DateTimeChanged(this.dateTime);

  @override
  List<Object> get props => [dateTime];
}

class DateTimeUnfocused extends FormFieldEvent {}

class AddressChanged extends FormFieldEvent {
  final String address;
  const AddressChanged(this.address);

  @override
  List<Object> get props => [address];
}

class AddressUnfocused extends FormFieldEvent {}
