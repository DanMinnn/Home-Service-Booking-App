import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/home/repo/task_repo.dart';
import 'package:home_service_tasker/routes/navigation_service.dart';
import 'package:home_service_tasker/theme/app_colors.dart';

import '../../../common/widget/app_bar.dart';
import '../../../providers/log_provider.dart';
import '../../../routes/route_name.dart';
import '../../../theme/app_assets.dart';
import '../../../widgets/notification_badge.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widget/task_card_widget.dart';

class HistoryTasksPage extends StatefulWidget {
  const HistoryTasksPage({super.key});

  @override
  State<HistoryTasksPage> createState() => _HistoryTasksPageState();
}

class _HistoryTasksPageState extends State<HistoryTasksPage> {
  final LogProvider logger = const LogProvider(':::HISTORY-TASK-PAGE:::');
  final NavigationService _navigationService = NavigationService();

  int taskerId = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      taskerId = args['taskerId'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: Column(
        children: [
          BasicAppBar(
            title: 'My Task History',
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
            trailing: NotificationBadge(),
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
            child: BlocProvider(
              create: (context) => TaskBloc(TaskRepo())
                ..add(
                  LoadTaskHistoryEvent(taskerId: taskerId),
                ),
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoadingState) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  } else if (state is TaskLoadedState) {
                    final tasks = state.tasks;
                    if (tasks.isEmpty) {
                      return Center(
                        child: Text(
                          'No tasks found',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                              itemBuilder: (_, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        _navigationService.navigateTo(
                                            RouteName.historyTaskDetailScreen,
                                            arguments: {
                                              'task': tasks[index],
                                              'taskerId': taskerId,
                                            });
                                      },
                                      child: TaskCardWidget(
                                        task: tasks[index],
                                      )),
                                );
                              },
                              itemCount: tasks.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics()),
                        ],
                      ),
                    );
                  } else if (state is TaskErrorState) {
                    logger.log('Error loading tasks: ${state.error}');
                    return const Center(
                      child: Text(
                        'Something went wrong',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          )),
        ],
      ),
    );
  }
}
