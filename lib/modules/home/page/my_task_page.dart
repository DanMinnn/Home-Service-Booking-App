import 'package:flutter/material.dart';
import 'package:home_service_tasker/modules/home/widget/task_card_widget.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:home_service_tasker/theme/styles_text.dart';
import 'package:intl/intl.dart';

import '../../../routes/navigation_service.dart';
import '../../../routes/route_name.dart';
import '../model/schedule_date.dart';

class MyTaskPage extends StatefulWidget {
  const MyTaskPage({super.key});

  @override
  State<MyTaskPage> createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<MyTaskPage> {
  final NavigationService _navigationService = NavigationService();
  final List<ScheduleDate> schedule = List.generate(7, (index) {
    final date = DateTime.now().add(Duration(days: index));
    return ScheduleDate(date: date, taskCount: index == 1 ? 1 : 0);
  });

  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
                            color: AppColors.primary.withValues(alpha: 0.8))
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
                                color:
                                    isSelected ? Colors.white : Colors.white)),
                      Text(
                        DateFormat('dd/MM').format(item.date),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.white),
                      ),
                      Text(
                        '${item.taskCount} task',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Nội dung tương ứng
        /*Expanded(
          child: Center(
            child: Text(
              'Nội dung ngày ${DateFormat('dd/MM/yyyy').format(selectedDate)}\nSố việc: ${schedule.firstWhere((e) => isSameDay(e.date, selectedDate)).taskCount}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),*/
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Afternoon',
            style: AppTextStyles.headline4,
          ),
        ),
        GestureDetector(
            onTap: () {
              _navigationService.navigateTo(RouteName.taskDetailScreen);
            },
            child: TaskCardWidget())
      ],
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
