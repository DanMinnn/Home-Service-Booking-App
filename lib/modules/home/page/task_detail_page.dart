import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/common/widget/app_bar.dart';
import 'package:home_service_tasker/common/widget/show_snack_bar.dart';
import 'package:home_service_tasker/modules/home/bloc/task_bloc.dart';
import 'package:home_service_tasker/modules/home/bloc/task_event.dart';
import 'package:home_service_tasker/modules/home/page/note_cancel_job_dialog.dart';
import 'package:home_service_tasker/modules/home/repo/task_repo.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/navigation_service.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/styles_text.dart';
import '../../../ui/main_screen.dart';
import '../bloc/task_state.dart';
import '../models/task.dart';
import '../widget/task_card_widget.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final NavigationService _navigationService = NavigationService();
  bool isFinished = false;

  late Task task;
  int taskerId = 0;
  String selectedDateStr = '';
  bool enableBtn = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      task = args['task'] as Task;
      taskerId = args['taskerId'] as int? ?? 0;
      if (args.containsKey('selectedDate')) {
        selectedDateStr = args['selectedDate'] as String;
      }
    }
  }

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
                  TaskCardWidget(
                    task: task,
                  ),
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
              _getSecondAddress(task.address),
              true,
            ),
            const SizedBox(height: 8),
            _buildTaskDetailItem(
              AppAssetsIcons.homeIc,
              task.taskDetails['workload'] ?? 'General',
              false,
            ),
            const SizedBox(height: 8),
            _buildTaskDetailItem(AppAssetsIcons.timerIc,
                'Do in ${task.durations} minutes', false),
            const SizedBox(height: 8),
            if (task.notes != null && task.notes!.isNotEmpty)
              _buildTaskDetailItem(
                  AppAssetsIcons.noteIc, task.notes ?? '', false),
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
              Text(
                text,
                style: AppTextStyles.paragraph1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(width: 8),
          maps
              ? GestureDetector(
                  onTap: () {
                    /* _navigationService
                        .navigateTo(RouteName.mapsScreen, arguments: {
                      'latitude': task.latitude,
                      'longitude': task.longitude,
                      'address': task.address,
                    });*/
                    openGoogleMaps(task.latitude, task.longitude);
                  },
                  child: Container(
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
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildSwipeBtnGetTask() {
    return BlocProvider(
      create: (context) => TaskBloc(TaskRepo()),
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskAssignedState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ShowSnackBar.showSuccess(context, state.message, 'Well done!');
            });
          } else if (state is TaskErrorState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ShowSnackBar.showError(context, state.error);
            });
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Center(
                child: selectedDateStr.isEmpty
                    ? _buildSwipeGetCancel(
                        context, 'Slide to get task', AppColors.dodgerBlue)
                    : _buildButtonCancelJob(context)),
          );
        },
      ),
    );
  }

  Widget _buildSwipeGetCancel(
      BuildContext context, String title, Color backgroundColor) {
    return SwipeableButtonView(
      onFinish: () async {
        context.read<TaskBloc>().add(AssignTaskEvent(
              bookingId: task.bookingId,
              taskerId: taskerId,
            ));
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const MainScreen(),
          ),
        );
      },
      buttonText: title,
      buttontextstyle: AppTextStyles.headline5.copyWith(
        color: AppColors.white,
      ),
      buttonWidget:
          Image.asset(AppAssetsIcons.arrowRightIc, width: 24, height: 24),
      activeColor: backgroundColor,
      isFinished: isFinished,
      onWaitingProcess: () {
        Future.delayed(const Duration(seconds: 2), () async {
          setState(() {
            isFinished = true;
          });
        });
      },
    );
  }

  Widget _buildButtonCancelJob(BuildContext context) {
    return GestureDetector(
      onTap: enableBtn
          ? () {
              showDialog(
                context: context,
                builder: (context) =>
                    NoteCancelJobDialog(bookingId: task.bookingId),
              ).then((result) {
                setState(() {
                  enableBtn = false;
                });
              });
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: enableBtn ? AppColors.sunsetOrange : AppColors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cancel Job',
            style: AppTextStyles.headline5.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  String getDuration(String duration) {
    return duration.split(',').first;
  }

  String _getSecondAddress(String address) {
    final parts = address.split(',');
    String result = '';
    if (parts.length >= 4) {
      result = '${parts[1].trim()}, ${parts[2].trim()}';
    } else {
      result = parts[1].trim();
    }
    return result;
  }

  Future<void> openGoogleMaps(double latitude, double longitude) async {
    try {
      // Create a properly formatted uri string first
      final String googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final Uri uri = Uri.parse(googleMapsUrl);

      // Launch directly without checking canLaunchUrl to avoid the channel error
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening Google Maps')),
      );
    }
  }
}
