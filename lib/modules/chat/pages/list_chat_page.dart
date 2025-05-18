import 'package:flutter/material.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';

class ListChatPage extends StatefulWidget {
  const ListChatPage({super.key});

  @override
  State<ListChatPage> createState() => _ListChatPageState();
}

class _ListChatPageState extends State<ListChatPage> {
  final NavigationService _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          BasicAppBar(
            isLeading: false,
            isTrailing: false,
            leading: GestureDetector(
              onTap: () {
                _navigationService.goBack(true);
              },
              child: Image.asset(AppAssetIcons.arrowLeft),
            ),
            title: 'Chat',
          ),
          Expanded(child: _buildListChat()),
          //_buildChatItem(),
        ],
      ),
    );
  }

  Widget _buildListChat() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildChatItem();
      },
    );
  }

  Widget _buildChatItem() {
    return GestureDetector(
      onTap: () {
        _navigationService.navigateTo(RouteName.chatPage);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://example.com/user.jpg'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Name',
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last message preview',
                    style: AppTextStyles.bodyMediumRegular.copyWith(
                      color: AppColors.darkBlue.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '18 July 2023',
              style: AppTextStyles.captionRegular.copyWith(
                color: AppColors.darkBlue.withValues(alpha: 0.4),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
