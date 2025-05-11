import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:home_service/modules/authentication/models/validate/phone.dart';

import '../../modules/authentication/models/validate/email.dart';
import '../../modules/authentication/models/validate/password.dart';
import '../../modules/authentication/models/validate/username.dart';
import '../../modules/booking/models/address_validate.dart';
import '../../modules/booking/models/date_time_validate.dart';

part 'form_event.dart';
part 'form_state.dart';

class FormFieldBloc extends Bloc<FormFieldEvent, FormFieldStates> {
  FormFieldBloc() : super(const FormFieldStates()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<EmailUnfocused>(_onEmailUnfocused);
    on<PasswordUnfocused>(_onPasswordUnfocused);
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<PhoneNumberUnfocused>(_onPhoneNumberUnfocused);
    on<UsernameChanged>(_onUsernameChanged);
    on<UsernameUnfocused>(_onUsernameUnfocused);
    on<DateTimeChanged>(_onDateTimeChanged);
    on<DateTimeUnfocused>(_onDateTimeUnfocused);
    on<AddressChanged>(_onAddressChanged);
    on<AddressUnfocused>(_onAddressUnfocused);
  }

  void _onEmailChanged(EmailChanged event, Emitter<FormFieldStates> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email.isValid ? email : Email.pure(event.email),
      ),
    );
  }

  void _onPasswordChanged(
      PasswordChanged event, Emitter<FormFieldStates> emit) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password.isValid ? password : Password.pure(event.password),
      ),
    );
  }

  void _onPhoneNumberChanged(
      PhoneNumberChanged event, Emitter<FormFieldStates> emit) {
    final phoneNumber = PhoneNumber.dirty(event.phoneNumber);
    emit(
      state.copyWith(
        phoneNumber: phoneNumber.isValid
            ? phoneNumber
            : PhoneNumber.pure(event.phoneNumber),
      ),
    );
  }

  void _onUsernameChanged(
      UsernameChanged event, Emitter<FormFieldStates> emit) {
    final username = Username.dirty(event.username);
    emit(
      state.copyWith(
        username: username.isValid ? username : Username.pure(event.username),
      ),
    );
  }

  void _onEmailUnfocused(EmailUnfocused event, Emitter<FormFieldStates> emit) {
    final email = Email.dirty(state.email.value);
    emit(
      state.copyWith(
        email: email,
      ),
    );
  }

  void _onPasswordUnfocused(
    PasswordUnfocused event,
    Emitter<FormFieldStates> emit,
  ) {
    final password = Password.dirty(state.password.value);
    emit(
      state.copyWith(
        password: password,
      ),
    );
  }

  void _onPhoneNumberUnfocused(
    PhoneNumberUnfocused event,
    Emitter<FormFieldStates> emit,
  ) {
    final phoneNumber = PhoneNumber.dirty(state.phoneNumber.value);
    emit(
      state.copyWith(
        phoneNumber: phoneNumber,
      ),
    );
  }

  void _onUsernameUnfocused(
    UsernameUnfocused event,
    Emitter<FormFieldStates> emit,
  ) {
    final username = Username.dirty(state.username.value);
    emit(
      state.copyWith(
        username: username,
      ),
    );
  }

  void _onDateTimeChanged(
    DateTimeChanged event,
    Emitter<FormFieldStates> emit,
  ) {
    final dateTime = DateTimeValidate.dirty(event.dateTime);
    emit(
      state.copyWith(
        dateTime:
            dateTime.isValid ? dateTime : DateTimeValidate.pure(event.dateTime),
      ),
    );
  }

  void _onDateTimeUnfocused(
    DateTimeUnfocused event,
    Emitter<FormFieldStates> emit,
  ) {
    final dateTime = DateTimeValidate.dirty(state.dateTime.value);
    emit(
      state.copyWith(
        dateTime: dateTime,
      ),
    );
  }

  void _onAddressChanged(
    AddressChanged event,
    Emitter<FormFieldStates> emit,
  ) {
    final address = AddressValidator.dirty(event.address);
    emit(
      state.copyWith(
        address:
            address.isValid ? address : AddressValidator.pure(event.address),
      ),
    );
  }

  void _onAddressUnfocused(
    AddressUnfocused event,
    Emitter<FormFieldStates> emit,
  ) {
    final address = AddressValidator.dirty(state.address.value);
    emit(
      state.copyWith(
        address: address,
      ),
    );
  }
}
