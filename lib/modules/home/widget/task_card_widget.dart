import 'package:flutter/material.dart';

import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';

class TaskCardWidget extends StatefulWidget {
  const TaskCardWidget({super.key});

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: _buildTaskCard(),
    );
  }

  Widget _buildTaskCard() {
    return Card(
      color: AppColors.white,
      shadowColor: AppColors.grey,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFirstRow(),
            const SizedBox(height: 8),
            _buildSecondRow(),
            const SizedBox(height: 8),
            Divider(
              color: AppColors.grey,
              thickness: 1,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Text('175,000đ',
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.sunsetOrange,
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFirstRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.alertSuccess.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Text(
              'Cleaning',
              style: AppTextStyles.headline5,
            ),
          ),
        ),
        Text('Chicago, IL', style: AppTextStyles.headline4),
      ],
    );
  }

  Widget _buildSecondRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ColorFiltered(
                colorFilter:
                    ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                child: Image.asset(AppAssetsIcons.calendarIc,
                    width: 20, height: 20)),
            const SizedBox(width: 8),
            Text('03/07/2025', style: AppTextStyles.paragraph1),
          ],
        ),
        Row(
          children: [
            ColorFiltered(
                colorFilter:
                    ColorFilter.mode(AppColors.sunsetOrange, BlendMode.srcIn),
                child:
                    Image.asset(AppAssetsIcons.timerIc, width: 20, height: 20)),
            const SizedBox(width: 8),
            Text('09:30 - 11:30', style: AppTextStyles.paragraph1),
          ],
        ),
      ],
    );
  }
}
