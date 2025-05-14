import 'package:flutter/material.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

import '../../../themes/app_assets.dart';

class BookingPost extends StatefulWidget {
  const BookingPost({super.key});

  @override
  State<BookingPost> createState() => _BookingPostState();
}

class _BookingPostState extends State<BookingPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          BasicAppBar(
            isLeading: false,
            isTrailing: false,
            leading: GestureDetector(
              onTap: Navigator.of(context).pop,
              child: Image.asset(AppAssetIcons.arrowLeft),
            ),
            title: 'Bookings',
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildBookingCard();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _buildBookingFirstRow(),
            _buildBookingSecondRow(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Wait for the tasker to accept your booking',
                style: AppTextStyles.bodySmallSemiBold.copyWith(
                  color: AppColors.darkBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingFirstRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service name',
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: AppColors.darkBlue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price',
                style: AppTextStyles.captionMedium.copyWith(
                  color: AppColors.darkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.tanHide,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                'Pending',
                style: AppTextStyles.captionMedium.copyWith(
                  color: AppColors.red,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSecondRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildItemRow(
                  AppAssetIcons.calendarFilled, '22 July 2023, 10:00 AM'),
              const SizedBox(height: 8),
              _buildItemRow(
                  AppAssetIcons.timer, '2 hours, 10:00 AM to 12:00 PM'),
              const SizedBox(height: 8),
              _buildItemRow(AppAssetIcons.locationFilled, '863 Nguyen Xien'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(String icon, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(icon),
        const SizedBox(width: 12),
        Text(
          content,
          style: AppTextStyles.bodySmallSemiBold.copyWith(
            color: AppColors.darkBlue,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
