import 'package:flutter/material.dart';
import 'package:home_service/modules/chat/models/chat_room_model.dart';
import 'package:home_service/themes/styles_text.dart';

import '../../../themes/app_colors.dart';

class ChatListItem extends StatelessWidget {
  final ChatRoomModel room;
  final int userId;
  final String userType;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.onTap,
    required this.room,
    required this.userId,
    required this.userType,
  });

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
              radius: 28,
              backgroundColor: Color(0xFFFF6B35),
              child: room.taskerProfile != null
                  ? ClipOval(
                      child: Image.network(
                        '${room.taskerProfile}',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.taskerName!,
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.lastMessage!.messageText,
                    style: AppTextStyles.bodyMediumRegular.copyWith(
                      color: AppColors.darkBlue.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatTime(room.lastMessageAt!),
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
