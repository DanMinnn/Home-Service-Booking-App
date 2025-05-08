import 'package:flutter/material.dart';

import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';

class PriceNextNavbar extends StatelessWidget {
  final String pricePerHour;
  final bool booking;

  const PriceNextNavbar(
      {super.key, required this.pricePerHour, this.booking = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !booking
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price:',
                        style: AppTextStyles.bodyLargeMedium,
                      ),
                      Text(
                        pricePerHour,
                        style: AppTextStyles.bodyLargeMedium,
                      ),
                    ],
                  ),
                )
              : const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: booking
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          pricePerHour,
                          style: AppTextStyles.bodyLargeSemiBold.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        'Next',
                        style: AppTextStyles.bodyLargeRegular
                            .copyWith(color: AppColors.white),
                      ),
                    ],
                  )
                : Text(
                    'Book',
                    style: AppTextStyles.bodyLargeSemiBold,
                    textAlign: TextAlign.center,
                  ),
          ),
        ],
      ),
    );
  }
}
