import 'package:flutter/material.dart';
import 'package:home_service_tasker/modules/home/models/task.dart';
import 'package:home_service_tasker/providers/log_provider.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';

class TaskCardWidget extends StatefulWidget {
  final Task task;

  const TaskCardWidget({
    super.key,
    required this.task,
  });

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  final LogProvider logger = const LogProvider(':::TASK-CARD-WIDGET:::');
  late Task task;
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
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
                      task.serviceName,
                      style: AppTextStyles.headline5,
                    ),
                  ),
                ),
                Text(_getMainAddress(task.address),
                    style: AppTextStyles.headline4),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            AppColors.primary, BlendMode.srcIn),
                        child: Image.asset(AppAssetsIcons.calendarIc,
                            width: 20, height: 20)),
                    const SizedBox(width: 8),
                    Text(showDateWork(task.scheduledStart),
                        style: AppTextStyles.paragraph1),
                  ],
                ),
                Row(
                  children: [
                    ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            AppColors.sunsetOrange, BlendMode.srcIn),
                        child: Image.asset(AppAssetsIcons.timerIc,
                            width: 20, height: 20)),
                    const SizedBox(width: 8),
                    Text(showDurationTime(), style: AppTextStyles.paragraph1),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              color: AppColors.grey,
              thickness: 1,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (task.status == 'in_progress')
                  Text(
                    'In Progress',
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.primary,
                    ),
                  )
                else if (task.status == 'completed')
                  Text(
                    'Completed',
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.alertSuccess,
                    ),
                  )
                else if (task.status == 'cancelled')
                  Text(
                    'Cancelled',
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.alertFailed,
                    ),
                  ),
                Text(
                  '${formatPrice(task.totalPrice)}đ',
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.sunsetOrange,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###');
    String formattedPrice = formatter.format(price);
    return formattedPrice;
  }

  String _getMainAddress(String address) {
    return address.split(',').first;
  }

  String showDurationTime() {
    try {
      final startTime = task.scheduledStart;
      final endTime = task.scheduledEnd;
      final timeFormatter = DateFormat('H:mm');
      return '${timeFormatter.format(startTime)} - ${timeFormatter.format(endTime)}';
    } catch (e) {
      logger.log("Error parsing date: $e");
      return 'Invalid date';
    }
  }

  String showDateWork(DateTime startTime) {
    try {
      final outputFormat = DateFormat('dd/MM/yyyy');
      return outputFormat.format(startTime);
    } catch (e) {
      logger.log("Error parsing date: $e");
      return 'Invalid date';
    }
  }
}
