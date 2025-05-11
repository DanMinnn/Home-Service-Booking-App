import 'package:flutter/material.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/modules/booking/models/booking_data.dart';
import 'package:home_service/modules/booking/models/payment_method.dart';
import 'package:home_service/modules/booking/widget/step_component.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';
import 'package:intl/intl.dart';

import '../../../themes/app_assets.dart';
import '../widget/confirm_box.dart';
import '../widget/price_next_navbar.dart';

class ConfirmAndPayPage extends StatefulWidget {
  const ConfirmAndPayPage({super.key});

  @override
  State<ConfirmAndPayPage> createState() => _ConfirmAndPayPageState();
}

class _ConfirmAndPayPageState extends State<ConfirmAndPayPage> {
  LogProvider get logger => const LogProvider("CONFIRM-AND-PAY-PAGE:::::");

  PaymentMethod? _selectedPaymentMethod = PaymentMethod.cash;

  late BookingData bookingData;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicAppBar(
              isLeading: false,
              isTrailing: false,
              title: "Confirm And Pay",
              leading: GestureDetector(
                onTap: Navigator.of(context).pop,
                child: Image.asset(AppAssetIcons.arrowLeft),
              ),
            ),
            StepComponent(isDone: false),
            const SizedBox(height: 16),
            ConfirmBox(
              title: 'Location',
              children: [
                _buildItemLocation(Image.asset(AppAssetIcons.locationFilled),
                    bookingData.address!, bookingData.address!),
                _buildItemLocation(Image.asset(AppAssetIcons.profileFilled),
                    bookingData.user!.name, bookingData.user!.phone),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ConfirmBox(
                title: 'Task Info',
                children: [
                  _buildItemTaskInfo(),
                ],
              ),
            ),
            _buildPaymentMethod(),
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          final updateBookingData = bookingData.copyWith(
            paymentMethod: _selectedPaymentMethod?.name,
          );

          logger.log("Booking data: ${updateBookingData.paymentMethod}");
        },
        child: PriceNextNavbar(
          pricePerHour: totalPrice(bookingData.formattedPrice),
          booking: false,
        ),
      ),
    );
  }

  Widget _buildItemLocation(Widget image, String? title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          image,
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title!,
                style: AppTextStyles.bodyMediumMedium,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmallMedium,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildItemTaskInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Working time',
            style: AppTextStyles.bodyMediumMedium,
          ),
          const SizedBox(height: 8),
          _itemTaskInfo('Date', bookingData.dateTime!),
          const SizedBox(height: 8),
          _itemTaskInfo('Duration',
              '${bookingData.packageName}, from ${convertStringToDateTime(bookingData.dateTime!, bookingData.packageName!)}'),
          const SizedBox(height: 8),
          Text(
            'Task detailed',
            style: AppTextStyles.bodyMediumMedium,
          ),
          const SizedBox(height: 8),
          if (bookingData.packageDescription == null) ...[
            _itemTaskInfo('People', bookingData.numberOfPeople.toString()),
            const SizedBox(height: 8),
            _itemTaskInfo('Course', bookingData.numberOfCourses.toString()),
            const SizedBox(height: 8),
            _itemTaskInfo('Courses',
                handleCoursesNames(bookingData.coursesNames!).join(', ')),
            if (bookingData.preferStyle != null) ...[
              _itemTaskInfo('Prefer Style', bookingData.preferStyle!),
            ],
          ] else ...[
            _itemTaskInfo('Workload', bookingData.packageDescription!),
          ],
        ],
      ),
    );
  }

  Widget _itemTaskInfo(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 3,
          child: Text(
            title,
            style: AppTextStyles.bodySmallMedium.copyWith(
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          flex: 5,
          child: Text(
            subtitle,
            style: AppTextStyles.bodySmallMedium.copyWith(
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: AppTextStyles.bodyLargeMedium,
          ),
          const SizedBox(height: 8),
          _buildPaymentItem(
            Image.asset(AppAssetIcons.digitalPay),
            'Digital Pay',
            PaymentMethod.wallet,
          ),
          const SizedBox(height: 8),
          _buildPaymentItem(
            Image.asset(AppAssetIcons.paymentCash),
            'Cash on Pay',
            PaymentMethod.cash,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Widget image, String method, PaymentMethod value) {
    return Container(
      width: MediaQuery.of(context).size.width - 36,
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: image,
                ),
                const SizedBox(width: 8),
                Text(
                  method,
                  style: AppTextStyles.bodyMediumMedium,
                ),
              ],
            ),
            Radio(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: AppColors.blue,
            ),
          ],
        ),
      ),
    );
  }

  String convertStringToDateTime(String dateString, String durationStr) {
    try {
      final inputFormat = DateFormat('EEEE, dd MMMM yyyy - hh:mm a');
      final startTime = inputFormat.parse(dateString);

      final durationParts = int.parse(durationStr.split(' ').first);

      final endTime = startTime.add(Duration(hours: durationParts));

      final outputFormat = DateFormat('hh:mm a');
      final formattedEndTime =
          '${outputFormat.format(startTime)} to ${outputFormat.format(endTime)}';

      logger.log("Durations: $formattedEndTime");

      return formattedEndTime;
    } catch (e) {
      logger.log("Error parsing date: $e");
      return 'Invalid date';
    }
  }

  String totalPrice(String pricePerHour) {
    final totalPrice = pricePerHour.split('/').first.trim();
    return totalPrice;
  }

  List<String> handleCoursesNames(List<String> coursesNames) {
    List<String> cleanedNames =
        coursesNames.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return cleanedNames;
  }
}
