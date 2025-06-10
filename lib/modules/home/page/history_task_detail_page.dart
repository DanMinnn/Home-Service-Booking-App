import 'package:flutter/material.dart';
import 'package:home_service_tasker/common/widget/app_bar.dart';
import 'package:home_service_tasker/theme/app_colors.dart';

import '../../../routes/navigation_service.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/styles_text.dart';
import '../models/task.dart';
import '../widget/task_card_widget.dart';

class HistoryTasksDetailPage extends StatefulWidget {
  const HistoryTasksDetailPage({super.key});

  @override
  State<HistoryTasksDetailPage> createState() => _HistoryTasksDetailPageState();
}

class _HistoryTasksDetailPageState extends State<HistoryTasksDetailPage> {
  final NavigationService _navigationService = NavigationService();

  late Task task;
  int taskerId = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      task = args['task'] as Task;
      taskerId = args['taskerId'] as int? ?? 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Column(
        children: [
          BasicAppBar(
            backgroundColor: true,
            leading: GestureDetector(
              onTap: () {
                _navigationService.goBack();
              },
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  AppAssetsIcons.arrowLeft,
                  color: AppColors.dark,
                ),
              ),
            ),
            title: 'Task History Detail',
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  TaskCardWidget(
                    task: task,
                  ),
                  const SizedBox(height: 16),
                  _buildTaskDetailCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetailCard() {
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
            _buildTaskDetailItem(AppAssetsIcons.userNameIc,
                task.userName ?? 'Unknown User', true),
            const SizedBox(height: 8),
            _buildTaskDetailItem(AppAssetsIcons.locationIc,
                _getSecondAddress(task.address), true),
            const SizedBox(height: 8),
            if (task.taskDetails['people'] != null &&
                task.taskDetails['course'] != null &&
                task.taskDetails['courses'] != null) ...[
              _buildTaskDetailItem(AppAssetsIcons.grPeopleIc,
                  task.taskDetails['people'] ?? '1', true),
              _buildTaskDetailItem(
                  AppAssetsIcons.dinnerIc,
                  handleCoursesNames(task.taskDetails['courses']).join(' - '),
                  false),
            ] else ...[
              _buildTaskDetailItem(AppAssetsIcons.homeIc,
                  task.taskDetails['workload'] ?? 'N/A', true),
            ],
            const SizedBox(height: 8),
            _buildTaskDetailItem(AppAssetsIcons.timerIc,
                'Do in ${task.durations} minutes', true),
            const SizedBox(height: 8),
            if (task.notes != null && task.notes!.isNotEmpty)
              _buildTaskDetailItem(
                  AppAssetsIcons.noteIc, task.notes ?? '', true),
            if (task.cancelReason != null && task.cancelReason!.isNotEmpty)
              _buildTaskDetailItem(
                  AppAssetsIcons.cancelReason, task.cancelReason ?? '', true),
            const SizedBox(height: 8),
            _buildTaskDetailItem(AppAssetsIcons.paymentStatus,
                task.paymentStatus.toUpperCase(), false),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetailItem(String icon, String text, bool colorFiltered) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          colorFiltered
              ? ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    icon,
                    width: 20,
                    height: 20,
                  ),
                )
              : Image.asset(
                  icon,
                  width: 20,
                  height: 20,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.paragraph1.copyWith(
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _getSecondAddress(String address) {
    final parts = address.split(',');
    String result = '';
    if (parts.length >= 4) {
      result = '${parts[1].trim()}, ${parts[2].trim()}';
    } else {
      result = parts[0].trim();
    }
    return result;
  }

  List<dynamic> handleCoursesNames(List<dynamic> coursesNames) {
    List<String> cleanedNames =
        coursesNames.map((name) => name.toString().trim()).toList();

    return cleanedNames;
  }
}
