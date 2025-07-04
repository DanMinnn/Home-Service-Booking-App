import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:home_service/common/widgets/stateless/show_snack_bar.dart';
import 'package:home_service/modules/authentication/widgets/custom_text_field.dart';
import 'package:home_service/modules/booking/models/booking_data.dart';
import 'package:home_service/modules/booking/widget/price_next_navbar.dart';
import 'package:home_service/modules/booking/widget/step_component.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';
import 'package:intl/intl.dart';

import '../../../blocs/form_validate/form_bloc.dart';
import '../../../common/widgets/stateless/basic_app_bar.dart';
import '../../../providers/log_provider.dart';
import '../../../routes/route_name.dart';
import '../../../themes/app_assets.dart';

class ChooseWorkingTimePage extends StatefulWidget {
  const ChooseWorkingTimePage({super.key});

  @override
  State<ChooseWorkingTimePage> createState() => _ChooseWorkingTimePageState();
}

class _ChooseWorkingTimePageState extends State<ChooseWorkingTimePage> {
  LogProvider get logger => const LogProvider('CHOOSE-WORKING-TIME-PAGE:::');
  final NavigationService navigationService = NavigationService();
  final TextEditingController _selectedDateTime = TextEditingController();
  final TextEditingController _selectedAddress = TextEditingController();
  final TextEditingController _description = TextEditingController();

  final FormFieldBloc _formFieldBloc = FormFieldBloc();

  late BookingData bookingData;
  double _latitude = 0.001;
  double _longitude = 0.002;

  DateTime scheduledStart = DateTime.now().add(const Duration(minutes: 30));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is BookingData) {
      bookingData = args;
    } else {
      bookingData = BookingData();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _selectedDateTime.dispose();
    _selectedAddress.dispose();
    _description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.log(
        'Booking data = ${bookingData.serviceName} - ${bookingData.packageName} - ${bookingData.packageDescription}');

    bool checkValidation = _selectedDateTime.text.toString().isNotEmpty &&
        _selectedAddress.text.toString().isNotEmpty;

    logger.log('Check validation = $checkValidation');

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BasicAppBar(
                isLeading: false,
                isTrailing: false,
                leading: GestureDetector(
                  onTap: Navigator.of(context).pop,
                  child: Image.asset(AppAssetIcons.arrowLeft),
                ),
                title: 'Choose Working Time',
              ),
              StepComponent(isDone: true),
              _buildEnterInformation(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          if (checkValidation) {
            //Update booking data with the collected information
            bookingData = bookingData.copyWith(
              dateTime: _selectedDateTime.text,
              scheduledStart: scheduledStart,
              address: _selectedAddress.text,
              notes: _description.text,
              latitude: _latitude,
              longitude: _longitude,
            );

            Navigator.pushNamed(context, RouteName.confirmAndPay,
                arguments: bookingData);

            logger.log(
                'Lat: ${bookingData.latitude} - - Lng: ${bookingData.longitude}');
          } else {
            ShowSnackBar.showError(
                context, 'Please fill date-time and address');
          }
        },
        child: PriceNextNavbar(
          pricePerHour: bookingData.formattedPrice,
        ),
      ),
    );
  }

  Widget _buildEnterInformation() {
    return BlocProvider(
      create: (context) => _formFieldBloc,
      child: BlocBuilder<FormFieldBloc, FormFieldStates>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Enter your information',
                  style: AppTextStyles.bodyLargeSemiBold.copyWith(
                    color: AppColors.darkBlue,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  width: MediaQuery.of(context).size.width - 36,
                  height: MediaQuery.of(context).size.height - 270,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSelectedDateTime(context, state),
                        const SizedBox(height: 20),
                        _buildSelectedAddress(context, state),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 100),
                                () async {
                              final result = await navigationService.navigateTo(
                                  RouteName.mapsScreen,
                                  arguments: bookingData);

                              if (result is BookingData) {
                                setState(() {
                                  bookingData = result;
                                  _selectedAddress.text =
                                      bookingData.address ?? '';
                                  _latitude = bookingData.latitude!;
                                  _longitude = bookingData.longitude!;
                                });
                              }
                            });
                          },
                          child: Text(
                            'Choose from map',
                            style: AppTextStyles.captionRegular.copyWith(
                              color: AppColors.blue,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Description',
                          style: AppTextStyles.bodyMediumMedium.copyWith(
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: TextField(
                              controller: _description,
                              keyboardType: TextInputType.text,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Enter description',
                                hintStyle:
                                    AppTextStyles.bodyMediumMedium.copyWith(
                                  color:
                                      AppColors.darkBlue.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                              ),
                              style: AppTextStyles.bodySmallMedium.copyWith(
                                color: AppColors.darkBlue,
                                fontSize: 16,
                              ),
                              cursorColor: AppColors.darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDateTime(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    if (state.dateTime.isPure && state.dateTime.value.trim().isEmpty) {
      errors.add("Please select date-time in calendar beside.");
    } else if (state.dateTime.isNotValid) {
      errors.add("Date-time is invalid. Date-time must be in the future.");
    }

    return CustomTextField(
      controller: _selectedDateTime,
      label: 'Date And Time',
      hintText: '16 July 2025, 12:35 PM',
      prefixIcon: GestureDetector(
          onTap: () {
            _showCalendar(context);
          },
          child: Image.asset(AppAssetIcons.calendarOutline)),
      keyboardType: TextInputType.datetime,
      onChanged: (value) {
        if (value.isNotEmpty) {
          context.read<FormFieldBloc>().add(DateTimeChanged(value));
        }
      },
      onUnfocused: () {
        if (_selectedDateTime.text.isNotEmpty) {
          context.read<FormFieldBloc>().add(DateTimeUnfocused());
        }
      },
      fillColor: false,
      errorMessages: errors,
      readOnly: true,
    );
  }

  Widget _buildSelectedAddress(BuildContext context, FormFieldStates state) {
    final errors = <String>[];

    // if (state.address.isPure && state.address.value.trim().isEmpty) {
    //   errors.add("Please enter address.");
    // }

    return CustomTextField(
      controller: _selectedAddress,
      label: 'Enter Address',
      hintText: 'Enter Address',
      prefixIcon: Image.asset(AppAssetIcons.location),
      suffixIcon: ColorFiltered(
          colorFilter: ColorFilter.mode(
              AppColors.darkBlue.withValues(alpha: 0.6), BlendMode.srcIn),
          child: Image.asset(AppAssetIcons.gps)),
      keyboardType: TextInputType.text,
      onChanged: (value) {
        context.read<FormFieldBloc>().add(AddressChanged(value));
      },
      onUnfocused: () {
        context.read<FormFieldBloc>().add(AddressUnfocused());
      },
      fillColor: false,
      errorMessages: errors,
      readOnly: false,
    );
  }

  void _showCalendar(BuildContext context) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(), // At least 30 minutes in the future
      maxTime: DateTime.now().add(const Duration(days: 365)),
      onConfirm: (date) {
        try {
          String formatted =
              DateFormat('EEEE, dd MMMM yyyy - hh:mm a').format(date);

          setState(() {
            _selectedDateTime.text = formatted;
          });

          scheduledStart = date;

          context.read<FormFieldBloc>().add(DateTimeChanged(formatted));
          logger.log('scheduledStart: $scheduledStart');
        } catch (e) {
          logger.log('Error formatting date: $e');
          ShowSnackBar.showError(context, 'Invalid date format');
        }
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
  }
}
