import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/blocs/app_state_bloc.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

import '../../../repo/user_repository.dart';
import '../../../themes/app_assets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final NavigationService navigationService = NavigationService();
  final UserRepository _userRepository = UserRepository();

  LogProvider get logger => const LogProvider(":::PROFILE-PAGE:::");
  String _userName = '';
  String _userEmail = '';
  String _imageUrl = '';
  int _userId = 0;

  @override
  initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      await _userRepository.loadUserFromStorage();
      final userStorage = _userRepository.currentUser;
      if (userStorage != null) {
        setState(() {
          _userName = userStorage.name!;
          _userEmail = userStorage.email!;
          _userId = userStorage.id!;
          _imageUrl = userStorage.profileImage!;
        });
      }
    } catch (e) {
      logger.log("Failed to load user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            BasicAppBar(
              isLeading: false,
              isTrailing: false,
              leading: GestureDetector(
                onTap: () {
                  navigationService.goBackToPreviousTab();
                },
                child: Image.asset(AppAssetIcons.arrowLeft),
              ),
              title: 'Profile',
            ),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildItem(
              title: 'Wallet',
              icon: AppAssetIcons.digitalPay,
              onTap: () {
                //navigationService.navigateTo('/my-orders');
              },
            ),
            _buildItem(
              title: 'Favorite Taskers',
              icon: AppAssetIcons.heart,
              onTap: () {
                //navigationService.navigateTo('/my-orders');
              },
            ),
            _buildItem(
              title: 'Logout',
              icon: AppAssetIcons.logout,
              onTap: () {
                context.read<AppStateBloc>().logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.darkBlue.withValues(alpha: 0.05),
            child: ClipOval(
              child: _imageUrl.isNotEmpty
                  ? Image.network(
                      _imageUrl,
                      filterQuality: FilterQuality.high,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          AppAssetIcons.profile,
                          fit: BoxFit.fill,
                          width: 100,
                          height: 100,
                        );
                      },
                    )
                  : Image.asset(
                      AppAssetIcons.profile,
                      fit: BoxFit.fill,
                      width: 100,
                      height: 100,
                    ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            _userName,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.darkBlue,
            ),
          ),
          SizedBox(height: 5),
          Text(
            _userEmail,
            style: AppTextStyles.bodyLargeMedium.copyWith(
              color: AppColors.darkBlue.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              navigationService.navigateTo(RouteName.editProfile, arguments: {
                'id': _userId,
                'name': _userName,
                'email': _userEmail,
                'image': _imageUrl,
              });
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  'Edit Profile',
                  style: AppTextStyles.bodyMediumSemiBold.copyWith(
                    color: AppColors.darkBlue,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitDivider() {
    return const Divider(
      color: AppColors.darkBlue20,
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildItem({
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildSplitDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(icon),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyMediumSemiBold.copyWith(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Image.asset(AppAssetIcons.arrowRight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
