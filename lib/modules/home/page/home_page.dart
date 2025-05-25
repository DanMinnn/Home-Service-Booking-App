import 'package:flutter/material.dart';
import 'package:home_service_tasker/modules/home/page/my_task_page.dart';
import 'package:home_service_tasker/modules/home/page/new_task_page.dart';
import 'package:home_service_tasker/modules/home/widget/dialog_add_tasker_service.dart';
import 'package:home_service_tasker/providers/log_provider.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:home_service_tasker/theme/styles_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widget/app_bar.dart';
import '../../../theme/app_assets.dart';

class HomePage extends StatefulWidget {
  final bool showDialogOnLoad;

  const HomePage({
    super.key,
    this.showDialogOnLoad = false,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final LogProvider logger = const LogProvider(':::HOME-PAGE:::');
  int selectedIndex = 0;
  Widget? _newTaskPage;
  Widget? _myTaskPage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();

    final prefs = SharedPreferences.getInstance();
    prefs.then((sharedPrefs) {
      final hasShownDialog =
          sharedPrefs.getBool('hasShownServiceDialog') ?? false;
      if (!hasShownDialog && widget.showDialogOnLoad) {
        showDialog(
          context: context,
          builder: (_) => DialogAddTaskerService(),
          barrierDismissible: true,
        ).then((_) {
          sharedPrefs.setBool('hasShownServiceDialog', true);
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Column(
        children: [
          BasicAppBar(
            title: 'Home',
            icon: true,
            backgroundColor: true,
            leading: Image.asset(AppAssetsIcons.menuIc),
            trailing: Image.asset(AppAssetsIcons.notificationIc),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Color(0xFFFFE5D0),
                    ]),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabBar(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey<int>(selectedIndex),
                        child: _getPage(selectedIndex),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeTab(int index) {
    if (selectedIndex == index) return;

    setState(() {
      selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    if (index == 0) {
      _newTaskPage ??= const NewTaskPage();
      return _newTaskPage!;
    } else {
      _myTaskPage ??= const MyTaskPage();
      return _myTaskPage!;
    }
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          // New Task Tab
          Expanded(
            child: GestureDetector(
              onTap: () => _changeTab(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? AppColors.primary
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'New Task',
                  style: selectedIndex == 0
                      ? AppTextStyles.headline4.copyWith(color: AppColors.white)
                      : AppTextStyles.headline4,
                ),
              ),
            ),
          ),

          // My Task Tab
          Expanded(
            child: GestureDetector(
              onTap: () => _changeTab(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? AppColors.primary
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('My Task',
                    style: selectedIndex == 1
                        ? AppTextStyles.headline4
                            .copyWith(color: AppColors.white)
                        : AppTextStyles.headline4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
