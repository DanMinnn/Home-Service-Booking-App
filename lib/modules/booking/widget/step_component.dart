import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:home_service/themes/styles_text.dart';

import '../../../themes/app_assets.dart';
import '../../../themes/app_colors.dart';

class StepComponent extends StatelessWidget {
  final bool isDone;

  const StepComponent({super.key, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 56),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepIcon(
                isDone: true,
                iconPath: AppAssetIcons.tick,
                backgroundColor: AppColors.blue,
                iconColor: AppColors.white,
              ),
              DottedLine(
                direction: Axis.horizontal,
                lineLength: 100,
                dashColor: AppColors.darkBlue.withValues(alpha: 0.4),
              ),
              _buildStepIcon(
                isDone: false,
                iconPath:
                    isDone ? AppAssetIcons.tickOutline : AppAssetIcons.tick,
                backgroundColor: isDone
                    ? AppColors.blue.withValues(alpha: 0.2)
                    : AppColors.blue,
                iconColor: isDone
                    ? AppColors.darkBlue.withValues(alpha: 0.6)
                    : AppColors.white,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Step 1",
                  style: AppTextStyles.bodySmallMedium.copyWith(
                    color: AppColors.darkBlue,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Step 2",
                  style: isDone
                      ? AppTextStyles.bodySmallMedium.copyWith(
                          color: AppColors.darkBlue.withValues(alpha: 0.6),
                          fontSize: 14,
                        )
                      : AppTextStyles.bodySmallMedium.copyWith(
                          color: AppColors.darkBlue,
                          fontSize: 14,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon({
    required bool isDone,
    required String iconPath,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        child: Image.asset(iconPath),
      ),
    );
  }
}
