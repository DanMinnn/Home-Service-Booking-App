import 'package:flutter/material.dart';
import 'package:home_service_tasker/screens/notifications_screen.dart';

import '../modules/home/page/home_page.dart';
import '../providers/log_provider.dart';
import '../routes/navigation_service.dart';
import '../theme/app_assets.dart';
import '../theme/app_colors.dart';

class MainScreen extends StatefulWidget {
  final bool showServiceDialog;

  const MainScreen({super.key, this.showServiceDialog = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final NavigationService _navigationService = NavigationService();

  LogProvider get logger => const LogProvider(':::MAIN-SCREEN:::');

  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    NotificationsScreen(),
    Center(
      child: Text('Logout'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _navigationService.tabStream.listen((index) {
      setState(() {
        _selectedIndex = index;
      });
    });
  }

  void _onItemTapped(int index) {
    _navigationService.changeTab(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.dark,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: AppAssetsIcons.homeIcActive,
                  label: 'Home',
                  activeIcon: AppAssetsIcons.homeIcActive,
                  index: 0,
                ),
                _buildNavItem(
                  icon: AppAssetsIcons.emailActive,
                  label: 'Email',
                  activeIcon: AppAssetsIcons.emailActive,
                  index: 1,
                ),
                _buildNavItem(
                  icon: AppAssetsIcons.profileActive,
                  label: 'Profile',
                  activeIcon: AppAssetsIcons.profileActive,
                  index: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required String activeIcon,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            topLeft: Radius.circular(10),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tab indicator
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: 3,
              width: isSelected ? 30 : 0,
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Icon
            ColorFiltered(
              colorFilter: isSelected
                  ? ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    )
                  : ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
              child: Image.asset(
                isSelected ? activeIcon : icon,
                width: 24,
                height: 24,
              ),
            ),
            SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
