import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/bookings/pages/bookings_page.dart';
import 'package:home_service_admin/modules/login/bloc/auth_bloc.dart';
import 'package:home_service_admin/modules/login/bloc/auth_event.dart';
import 'package:home_service_admin/modules/login/repo/login_repo.dart';
import 'package:home_service_admin/modules/user/pages/tasker_page.dart';
import 'package:home_service_admin/themes/style_text.dart';

import '../modules/login/bloc/auth_state.dart';
import '../modules/user/pages/customer_page.dart';
import '../themes/app_assets.dart';
import '../themes/app_colors.dart';
import 'dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  final String? email;

  const MainScreen({super.key, this.email});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  String selectedMonth = 'Feb 2023';

  final List<String> months = [
    'Jan 2023',
    'Feb 2023',
    'Mar 2023',
    'Apr 2023',
    'May 2023',
    'Jun 2023',
    'Jul 2023',
    'Aug 2023'
  ];

  final List<String> menuIcons = [
    AppAssetsIcons.menuIc,
    AppAssetsIcons.clientIc,
    AppAssetsIcons.partnerIc,
    AppAssetsIcons.documentIc,
    AppAssetsIcons.invoiceIc,
    AppAssetsIcons.messageIc,
    AppAssetsIcons.notificationIc,
    AppAssetsIcons.settingIc,
  ];

  final List<String> menuTitles = [
    'Dashboard',
    'Customer',
    'Taskers',
    'Bookings',
    'Invoices',
    'Messages',
    'Notification',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            color: AppColors.neutral,
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          AppAssetsBackgrounds.logo,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Home Service',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu Items
                Expanded(
                  child: Column(
                    children: List.generate(menuIcons.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Container(
                            padding: EdgeInsets.only(left: 8),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            height: 50,
                            decoration: BoxDecoration(
                              color: selectedIndex == index
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  menuIcons[index],
                                  color: selectedIndex == index
                                      ? AppColors.primary
                                      : AppColors.textLight,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  menuTitles[index],
                                  style: AppTextStyles.titleSmall.copyWith(
                                    color: selectedIndex == index
                                        ? AppColors.primary
                                        : AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                // Profile
                BlocProvider(
                  create: (context) => AuthBloc(LoginRepo())
                    ..add(GetAdminInfo(
                      widget.email ?? '',
                    )),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AdminInfoLoaded) {
                        final admin = state.admin;
                        return Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                    admin.profileImage!.isNotEmpty
                                        ? admin.profileImage!
                                        : AppAssetsIcons.clientIc),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(admin.firstLastName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Image.asset(
                                AppAssetsIcons.logoutIc,
                              )
                            ],
                          ),
                        );
                      }
                      return Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(AppAssetsIcons.clientIc),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Admin',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Image.asset(
                              AppAssetsIcons.logoutIc,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: getContent(),
          ),
        ],
      ),
    );
  }

  Widget getContent() {
    switch (selectedIndex) {
      case 0:
        return DashboardScreen();
      case 1:
        return CustomerPage();
      case 2:
        return TaskerPage();
      case 3:
        return BookingsPage();
      case 4:
        return Center(
          child: Text(
            'Welcome to the Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      case 5:
        return Center(
          child: Text(
            'Welcome to the Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      default:
        return Center(
          child: Text(
            'Welcome to the Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
    }
  }
}
