import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/blocs/app_state_bloc.dart';
import 'package:home_service_tasker/repo/tasker_repository.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

import '../../../common/widget/app_bar.dart';
import '../../../providers/log_provider.dart';
import '../../../routes/navigation_service.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/notification_badge.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final NavigationService navigationService = NavigationService();
  final TaskerRepository _taskerRepository = TaskerRepository();
  final LogProvider logger = const LogProvider(":::PROFILE-PAGE:::");
  int _taskerId = 0;
  String _taskerName = '';
  String _taskerEmail = '';
  String _taskerImage = '';

  @override
  initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      await _taskerRepository.loadTaskerFromStorage();
      final tasker = _taskerRepository.currentTasker;
      if (tasker != null) {
        setState(() {
          _taskerName = tasker.name!;
          _taskerEmail = tasker.email!;
          _taskerId = tasker.id!;
          _taskerImage = tasker.profileImage ?? '';
        });
      }
    } catch (e) {
      logger.log("Failed to load user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Column(
        children: [
          BasicAppBar(
            title: 'Profile',
            backgroundColor: true,
            leading: Image.asset(AppAssetsIcons.menuIc),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Center(child: _buildProfileTop()),
                  const SizedBox(height: 24),
                  _buildProfileItem(
                    'My Tasks',
                    'View your tasks',
                    AppAssetsIcons.historyIc,
                  ),
                  _buildProfileItem(
                    'My Address',
                    'Manage your addresses',
                    AppAssetsIcons.markerIc,
                  ),
                  _buildProfileItem(
                    'Logout',
                    'Sign out of your account',
                    AppAssetsIcons.logoutIc,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileTop() {
    // Replace with actual image URL or logic
    return Column(
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(28),
          ),
          child: _taskerImage.isEmpty
              ? Center(
                  child: Text(
                    'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _taskerImage, // Replace with actual image URL
                    fit: BoxFit.cover,
                    width: 86,
                    height: 86,
                  ),
                ),
        ),
        const SizedBox(height: 9),
        Text(_taskerName, // Replace with actual user name
            style: AppTextStyles.headline4),
        Text(
          _taskerEmail, // Replace with actual user name
          style: AppTextStyles.paragraph3.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 9),
        OutlinedButton(
          onPressed: () {
            navigationService
                .navigateTo(RouteName.editProfileScreen, arguments: {
              'id': _taskerId,
              'name': _taskerName,
              'email': _taskerEmail,
              'image': _taskerImage,
            });
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 7),
          ),
          child: Text(
            'Edit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 24 / 13,
              color: AppColors.dark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(String title, String subtitle, String icon) {
    return ListTile(
      leading: Image.asset(
        icon,
        width: 24,
        height: 24,
      ),
      title: Text(title, style: AppTextStyles.headline5),
      subtitle: Text(subtitle, style: AppTextStyles.paragraph3),
      trailing: Image.asset(AppAssetsIcons.arrowBackRightIc),
      onTap: () {
        if (title == 'Logout') {
          context.read<AppStateBloc>().logout();
          navigationService.navigateToAndClearStack(RouteName.loginScreen);
        } else if (title == 'My Tasks') {
          //navigationService.navigateTo(RouteName.myTasksScreen);
        } else if (title == 'My Address') {
          //navigationService.navigateTo(RouteName.myAddressScreen);
        }
      },
    );
  }
}
