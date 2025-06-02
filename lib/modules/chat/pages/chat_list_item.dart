import 'package:flutter/material.dart';
import 'package:home_service/themes/styles_text.dart';

import '../../../themes/app_colors.dart';

class ChatListItem extends StatelessWidget {
  final VoidCallback onTap;
  const ChatListItem({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
