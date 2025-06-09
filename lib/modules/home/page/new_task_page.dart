import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/home/repo/task_repo.dart';
import 'package:home_service_tasker/modules/home/widget/task_card_widget.dart';
import 'package:home_service_tasker/routes/navigation_service.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:home_service_tasker/utils/load_tasker_info.dart';

import '../../../providers/log_provider.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final LogProvider logger = const LogProvider(':::NEW-TASK-PAGE:::');
  final NavigationService _navigationService = NavigationService();
  final LoadTaskerInfo _taskerInfo = LoadTaskerInfo();

  List<int> serviceIds = [];
  int taskerId = 0;
  @override
  initState() {
    super.initState();
    _loadTasker().then((_) {
      setState(() {});
    });
  }

  Future<void> _loadTasker() async {
    try {
      await _taskerInfo.loadTaskerInfo();
      setState(() {
        if (_taskerInfo.serviceIds != null) {
          serviceIds = _taskerInfo.serviceIds!;
        } else {
          serviceIds = [];
          logger.log('Warning: serviceIds is null');
        }

        if (_taskerInfo.taskerId != null) {
          taskerId = _taskerInfo.taskerId!;
        } else {
          taskerId = 0;
          logger.log('Warning: taskerId is null');
        }
      });
    } catch (e) {
      logger.log('Error loading tasker info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.log('Build method called with serviceIds: $serviceIds');
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SingleChildScrollView(
        child: serviceIds.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : BlocProvider(
                create: (context) => TaskBloc(TaskRepo())
                  ..add(
                    LoadTasksEvent(taskerId: taskerId, serviceIds: serviceIds),
                  ),
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoadingState) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is TaskLoadedState) {
                      final tasks = state.tasks;
                      if (tasks.isEmpty) {
                        return Center(
                          child: Text(
                            'No tasks available',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          ListView.builder(
                              itemBuilder: (_, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        _navigationService.navigateTo(
                                            RouteName.taskDetailScreen,
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
      ),
    );
  }
}
