import 'package:flutter/material.dart';
import 'package:home_service_tasker/common/widget/app_bar.dart';
import 'package:home_service_tasker/modules/home/widget/task_card_widget.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:home_service_tasker/ui/main_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

import '../../../routes/navigation_service.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/styles_text.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final NavigationService _navigationService = NavigationService();
  bool isFinished = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
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
              title: 'Task Detail',
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TaskCardWidget(),
                  const SizedBox(height: 16),
                  _buildTaskDetailCard(),
                  const SizedBox(height: 60),
                  _buildSwipeBtnGetTask(),
                ],
              ),
            ),
          ],
        ),
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
            _buildTaskDetailItem(
              AppAssetsIcons.locationIc,
              '123 Main St, Chicago, IL',
              true,
            ),
            const SizedBox(height: 8),
            _buildTaskDetailItem(
              AppAssetsIcons.homeIc,
              '2 rooms: 55 m²',
              false,
            ),
            const SizedBox(height: 8),
            _buildTaskDetailItem(
                AppAssetsIcons.timerIc, 'Do in 2 hours', false),
            const SizedBox(height: 8),
            _buildTaskDetailItem(AppAssetsIcons.noteIc, 'Testing app', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetailItem(String icon, String text, bool maps) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                icon,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 12),
              Text(text,
                  style: AppTextStyles.paragraph1.copyWith(
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          const SizedBox(width: 8),
          maps
              ? Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      AppAssetsIcons.locationFilledIc,
                      width: 20,
                      height: 20,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildSwipeBtnGetTask() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: SwipeableButtonView(
          onFinish: () async {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                child: const MainScreen(),
              ),
            );
          },
          buttonText: 'Slide to get task',
          buttontextstyle: AppTextStyles.headline5.copyWith(
            color: AppColors.white,
          ),
          buttonWidget:
              Image.asset(AppAssetsIcons.arrowRightIc, width: 24, height: 24),
          activeColor: AppColors.sunsetOrange,
          isFinished: isFinished,
          onWaitingProcess: () {
            Future.delayed(const Duration(seconds: 2), () async {
              setState(() {
                isFinished = true;
              });
            });
          },
        ),
      ),
    );
  }
}
