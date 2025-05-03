part of 'form_bloc.dart';

class FormFieldStates extends Equatable {
  const FormFieldStates({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.phoneNumber = const PhoneNumber.pure(),
    this.username = const Username.pure(),
  });

  final Email email;
  final Password password;
  final PhoneNumber phoneNumber;
  final Username username;

  FormFieldStates copyWith({
    Email? email,
    Password? password,
    PhoneNumber? phoneNumber,
    Username? username,
  }) {
    return FormFieldStates(
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
    );
  }

  @override
  List<Object> get props => [email, password, phoneNumber, username];
}
