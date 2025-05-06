import 'package:flutter/material.dart';
import 'package:home_service/themes/app_assets.dart';

import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';

class ServiceItem extends StatelessWidget {
  final String icon;
  final String title;

  const ServiceItem({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssetIcons.iconPath + icon,
            width: 40,
            height: 40,
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodyMediumMedium.copyWith(
              color: AppColors.darkBlue.withValues(alpha: 0.8),
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
