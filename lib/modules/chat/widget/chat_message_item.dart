import 'package:flutter/material.dart';

import '../model/message_model.dart';

class ChatMessageItem extends StatelessWidget {
  final MessageModel message;

  const ChatMessageItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isMe ? Color(0xFFFF6B35) : Color(0xFFE5E5E5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: message.isMe
                          ? Radius.circular(20)
                          : Radius.circular(4),
                      bottomRight: message.isMe
                          ? Radius.circular(4)
                          : Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message.time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe) SizedBox(width: 8),
        ],
      ),
    );
  }
}
