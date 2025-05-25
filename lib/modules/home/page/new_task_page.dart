import 'package:flutter/material.dart';
import 'package:home_service_tasker/modules/home/widget/task_card_widget.dart';
import 'package:home_service_tasker/routes/navigation_service.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:home_service_tasker/theme/app_colors.dart';

import '../../../providers/log_provider.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  final LogProvider logger = const LogProvider(':::NEW-TASK-PAGE:::');
  final NavigationService _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: GestureDetector(
                        onTap: () {
                          _navigationService
                              .navigateTo(RouteName.taskDetailScreen);
                        },
                        child: TaskCardWidget()),
                  );
                },
                itemCount: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics()),
          ],
        ),
      ),
    );
  }
}
