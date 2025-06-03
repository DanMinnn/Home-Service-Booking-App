import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/chat/model/chat_room_model.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

import '../../../theme/app_colors.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';

class ChatListItem extends StatelessWidget {
  final ChatRoomModel room;
  final int taskerId;
  final String userType;
  final VoidCallback onTap;
  final ChatBloc chatBloc;

  const ChatListItem({
    super.key,
    required this.room,
    required this.taskerId,
    required this.userType,
    required this.onTap,
    required this.chatBloc,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFFF6B35),
                  child: room.userProfile != null
                      ? ClipOval(
                          child: Image.network(
                            '${room.userProfile}',
                            width: 56, // 2 * radius
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
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      final isConnected = chatBloc.isConnected;
                      return Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? AppColors.alertSuccess
                              : AppColors.transparent,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Color(0xFF2C2C2C), width: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(room.userName!, style: AppTextStyles.headline4),
                      Text(
                        _formatTime(room.lastMessageAt!),
                        style: TextStyle(
                          color: Color(0xFFB4B1B0),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessage!.messageText,
                          style: AppTextStyles.paragraph3.copyWith(
                            color: Color(0xFF000000).withValues(alpha: 0.5),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
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
