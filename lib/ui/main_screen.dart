import 'package:flutter/material.dart';
import 'package:home_service/modules/categories/pages/categories_page.dart';
import 'package:home_service/modules/chat/pages/chat_page.dart';
import 'package:home_service/modules/home/pages/home_page.dart';
import 'package:home_service/modules/posts/pages/booking_post.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_assets.dart';

import '../modules/profile/pages/profile_page.dart';
import '../providers/log_provider.dart';
import '../routes/route_name.dart';
import '../themes/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final NavigationService _navigationService = NavigationService();
  LogProvider get logger => const LogProvider('MAINSCR:::');

  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    BookingPost(),
    CategoriesPage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Listen for tab change events
    _navigationService.tabStream.listen((index) {
      setState(() {
        _selectedIndex = index;
      });
      logger.log('Tab changed to: $index');
    });
  }

  void _onItemTapped(int index) {
    // Update NavigationService when tab is changed directly
    _navigationService.changeTab(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  void navigateToPage(String routeName) {
    logger.log('Navigating to: $routeName');
    if (routeName == RouteName.categories) {
      setState(() {
        _selectedIndex = 2;
      });
      logger.log('Current index: $_selectedIndex');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
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
                  icon: AppAssetIcons.navHomeOutline,
                  label: 'Home',
                  activeIcon: AppAssetIcons.navHomeFilled,
                  index: 0,
                ),
                _buildNavItem(
                  icon: AppAssetIcons.navBookingsOutline,
                  label: 'Bookings',
                  activeIcon: AppAssetIcons.navBookingsFilled,
                  index: 1,
                ),
                _buildNavItem(
                  icon: AppAssetIcons.navCategoriesOutline,
                  label: 'Categories',
                  activeIcon: AppAssetIcons.navCategoriesFilled,
                  index: 2,
                ),
                _buildNavItem(
                  icon: AppAssetIcons.navChatOutline,
                  label: 'Chat',
                  activeIcon: AppAssetIcons.navChatFilled,
                  index: 3,
                ),
                _buildNavItem(
                  icon: AppAssetIcons.navProfileOutline,
                  label: 'Profile',
                  activeIcon: AppAssetIcons.navProfileFilled,
                  index: 4,
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
      child: SizedBox(
        width: 65,
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
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Icon
            Image.asset(
              isSelected ? activeIcon : icon,
              width: 24,
              height: 24,
            ),
            SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.darkBlue
                    : AppColors.darkBlue.withValues(alpha: 0.8),
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
