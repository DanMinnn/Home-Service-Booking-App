part of 'form_bloc.dart';

class FormFieldStates extends Equatable {
  const FormFieldStates({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.phoneNumber = const PhoneNumber.pure(),
    this.username = const Username.pure(),
    this.dateTime = const DateTimeValidate.pure(),
    this.address = const AddressValidator.pure(),
  });

  final Email email;
  final Password password;
  final PhoneNumber phoneNumber;
  final Username username;
  final DateTimeValidate dateTime;
  final AddressValidator address;

  FormFieldStates copyWith({
    Email? email,
    Password? password,
    PhoneNumber? phoneNumber,
    Username? username,
    DateTimeValidate? dateTime,
    AddressValidator? address,
  }) {
    return FormFieldStates(
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      dateTime: dateTime ?? this.dateTime,
      address: address ?? this.address,
    );
  }

  @override
  List<Object> get props =>
      [email, password, phoneNumber, username, dateTime, address];
}
