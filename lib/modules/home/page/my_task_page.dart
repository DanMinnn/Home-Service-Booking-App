import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/home/bloc/task_bloc.dart';
import 'package:home_service_tasker/modules/home/bloc/task_event.dart';
import 'package:home_service_tasker/modules/home/repo/task_repo.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:intl/intl.dart';

import '../../../providers/log_provider.dart';
import '../../../routes/navigation_service.dart';
import '../../../routes/route_name.dart';
import '../../../utils/load_tasker_info.dart';
import '../bloc/task_state.dart';
import '../model/schedule_date.dart';
import '../widget/task_card_widget.dart';

class MyTaskPage extends StatefulWidget {
  const MyTaskPage({super.key});

  @override
  State<MyTaskPage> createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<MyTaskPage> {
  final LogProvider logger = const LogProvider(':::MY-TASK-PAGE:::');
  final LoadTaskerInfo _taskerInfo = LoadTaskerInfo();
  final NavigationService _navigationService = NavigationService();
  late List<ScheduleDate> schedule;

  DateTime selectedDate = DateTime.now();

  int taskerId = 0;
  String selectedDateStr = '';
  int taskCount = 0;
  final TaskRepo _taskRepo = TaskRepo();
  int _lastTaskCount = -1; // Track last task count to avoid unnecessary updates

  @override
  initState() {
    super.initState();
    schedule = List.generate(7, (index) {
      final date = DateTime.now().add(Duration(days: index));
      return ScheduleDate(date: date, taskCount: 0);
    });

    _loadTasker().then((_) {
      setState(() {
        selectedDateStr = DateFormat('dd/MM').format(selectedDate);
      });
      _loadTaskCountsForAllDates();
    });
  }

  // Load task counts for all dates in schedule
  Future<void> _loadTaskCountsForAllDates() async {
    if (taskerId == 0) return;

    for (int i = 0; i < schedule.length; i++) {
      final date = schedule[i].date;
      final dateStr = DateFormat('dd/MM').format(date);

      try {
        // Use the repository to get tasks for this date
        final tasks = await _taskRepo.getTaskAssigned(
          taskerId,
          dateStr,
        );

        setState(() {
          schedule[i] = ScheduleDate(date: date, taskCount: tasks.length);

          // Update the taskCount for the selected date
          if (isSameDay(date, selectedDate)) {
            taskCount = tasks.length;
          }
        });
      } catch (e) {
        logger.log('Error loading task count for date $dateStr: $e');
      }
    }
  }

  Future<void> _loadTasker() async {
    try {
      await _taskerInfo.loadTaskerInfo();
      setState(() {
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

  // Update the task count for a specific date
  void _updateTaskCount(DateTime date, int count) {
    if (isSameDay(date, selectedDate) && taskCount == count)
      return; // Avoid unnecessary updates

    setState(() {
      for (int i = 0; i < schedule.length; i++) {
        if (isSameDay(schedule[i].date, date)) {
          schedule[i] = ScheduleDate(date: date, taskCount: count);
          break;
        }
      }

      if (isSameDay(date, selectedDate)) {
        taskCount = count;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return taskerId != 0
        ? BlocProvider(
            create: (context) => TaskBloc(TaskRepo())
              ..add(LoadTaskAssignedEvent(
                  taskerId: taskerId, selectedDate: selectedDateStr)),
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                // Schedule the update after the build is complete
                if (state is TaskAssignedListState &&
                    state.tasks.length != _lastTaskCount) {
                  _lastTaskCount = state.tasks.length;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateTaskCount(selectedDate, state.tasks.length);
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        itemCount: schedule.length,
                        separatorBuilder: (_, __) => SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final item = schedule[index];
                          final isSelected = isSameDay(item.date, selectedDate);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDate = item.date;
                                logger.log('Selected date: $selectedDate');
                                selectedDateStr =
                                    DateFormat('dd/MM').format(selectedDate);
                                context.read<TaskBloc>().add(
                                      LoadTaskAssignedEvent(
                                        taskerId: taskerId,
                                        selectedDate: selectedDateStr,
                                      ),
                                    );
                              });
                            },
                            child: Container(
                              width: 80,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.8)
                                    : Color(0xFF4A90A4),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.8))
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isToday(item.date))
                                    Text("Today",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  if (!isToday(item.date))
                                    Text(DateFormat('E').format(item.date),
                                        style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white)),
                                  Text(
                                    DateFormat('dd/MM').format(item.date),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white),
                                  ),
                                  Text(
                                    '${item.taskCount} task${item.taskCount != 1 && item.taskCount != 0 ? "s" : ""}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state is TaskLoadingState)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (state is TaskAssignedListState) ...[
                      if (state.tasks.isEmpty)
                        Center(
                          child: Text(
                            'You have no tasks for this date',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.tasks.length,
                            itemBuilder: (context, index) {
                              final task = state.tasks[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _navigationService.navigateTo(
                                      RouteName.taskDetailScreen,
                                      arguments: {
                                        'task': task,
                                        'taskerId': taskerId,
                                        'selectedDate': selectedDateStr,
                                      },
                                    );
                                  },
                                  child: TaskCardWidget(task: task),
                                ),
                              );
                            },
                          ),
                        )
                    ] else if (state is TaskErrorState)
                      Center(
                        child: Text(
                          'Something went wrong',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                      )
                  ],
                );
              },
            ),
          )
        : Center(
            child: const CircularProgressIndicator(),
          );
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(now, date);
  }
}
