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
import '../models/task.dart';
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

  // Cache for tasks by date
  final Map<String, List<Task>> _tasksCache = {};
  // Track when the cache was last updated for each date
  final Map<String, DateTime> _cacheFreshness = {};
  // Maximum age of cache before refreshing (5 minutes)
  final Duration _cacheMaxAge = Duration(minutes: 5);

  late TaskBloc _taskBloc;

  @override
  initState() {
    super.initState();
    _taskBloc = TaskBloc(_taskRepo);

    schedule = List.generate(7, (index) {
      final date = DateTime.now().add(Duration(days: index));
      return ScheduleDate(date: date, taskCount: 0);
    });

    _loadTasker().then((_) {
      setState(() {
        selectedDateStr = DateFormat('dd/MM/yyyy').format(selectedDate);
      });
      _loadTaskCountsForAllDates();
    });
  }

  @override
  void dispose() {
    _taskBloc.close();
    super.dispose();
  }

  // Check if cache for a date is stale and needs refresh
  bool _isCacheStale(String dateStr) {
    if (!_tasksCache.containsKey(dateStr)) return true;
    if (!_cacheFreshness.containsKey(dateStr)) return true;

    final lastUpdate = _cacheFreshness[dateStr]!;
    final now = DateTime.now();
    return now.difference(lastUpdate) > _cacheMaxAge;
  }

  // Load task counts for all dates in schedule
  Future<void> _loadTaskCountsForAllDates() async {
    if (taskerId == 0) return;

    for (int i = 0; i < schedule.length; i++) {
      final date = schedule[i].date;
      final dateStr = DateFormat('dd/MM/yyyy').format(date);

      try {
        List<Task> tasks;

        // Use cache if available and fresh
        if (!_isCacheStale(dateStr)) {
          tasks = _tasksCache[dateStr]!;
          logger.log('Using cached tasks for date $dateStr');
        } else {
          // Fetch from API if cache is stale or missing
          tasks = await _taskRepo.getTaskAssigned(taskerId, dateStr);
          _tasksCache[dateStr] = tasks;
          _cacheFreshness[dateStr] = DateTime.now();
          logger.log('Fetched tasks for date $dateStr from API');
        }

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
    if (isSameDay(date, selectedDate) && taskCount == count) {
      return; // Avoid unnecessary updates
    }

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

  // Load tasks with caching for the selected date
  void _loadTasksForSelectedDate() {
    final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate);

    // Check if we need to fetch from API or can use cache
    if (_isCacheStale(dateStr)) {
      logger.log('Loading tasks from API for date: $dateStr');
      _taskBloc.add(LoadTaskAssignedEvent(
        taskerId: taskerId,
        selectedDate: dateStr,
      ));
    } else {
      // Use cached data
      logger.log('Using cached tasks for date: $dateStr');
      final tasks = _tasksCache[dateStr]!;
      _taskBloc.emit(TaskAssignedListState(tasks));
    }
  }

  @override
  Widget build(BuildContext context) {
    return taskerId != 0
        ? BlocProvider.value(
            value: _taskBloc,
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                // Schedule the update after the build is complete
                if (state is TaskAssignedListState &&
                    state.tasks.length != _lastTaskCount) {
                  _lastTaskCount = state.tasks.length;

                  // Store in cache when we get new data
                  final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate);
                  _tasksCache[dateStr] = state.tasks;
                  _cacheFreshness[dateStr] = DateTime.now();

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
                                selectedDateStr = DateFormat('dd/MM/yyyy')
                                    .format(selectedDate);
                                _loadTasksForSelectedDate();
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
                        child: CircularProgressIndicator(
                          color: Color(0xFFFD6B22),
                        ),
                      )
                    else if (state is TaskAssignedListState) ...[
                      if (state.tasks.isEmpty)
                        RefreshIndicator(
                          onRefresh: _refreshTasks,
                          child: SizedBox(
                            height: 200,
                            child: ListView(
                              physics: AlwaysScrollableScrollPhysics(),
                              children: [
                                Container(
                                  height: 200,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'You have no tasks assigned for this date.',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _refreshTasks,
                            child: ListView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
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
            child: const CircularProgressIndicator(color: Color(0xFFFD6B22)),
          );
  }

  Future<void> _refreshTasks() {
    final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate);
    return Future.delayed(const Duration(milliseconds: 500), () {
      _taskBloc.add(LoadTaskAssignedEvent(
        taskerId: taskerId,
        selectedDate: dateStr,
      ));
    });
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(now, date);
  }
}
