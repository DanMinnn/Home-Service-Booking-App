import 'package:flutter/material.dart';
import 'package:home_service/modules/chat/models/chat_message_model.dart';

import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';

class ChatMessageItem extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const ChatMessageItem({
    super.key,
    required this.isMe,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.green.withValues(alpha: 0.2)
                      : Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.only(
                    topLeft: isMe ? Radius.circular(20) : Radius.circular(0),
                    topRight: isMe ? Radius.circular(0) : Radius.circular(20),
                    bottomLeft:
                        isMe ? Radius.circular(20) : Radius.circular(22),
                    bottomRight:
                        isMe ? Radius.circular(22) : Radius.circular(20),
                  ),
                ),
                child: Text(
                  message.messageText,
                  style: AppTextStyles.bodyMediumRegular.copyWith(
                    color: AppColors.darkBlue,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 4),
              Text(
                _formatTime(message.sentAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
