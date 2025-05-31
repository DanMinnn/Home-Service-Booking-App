import 'package:flutter/material.dart';
import 'package:home_service_tasker/routes/navigation_service.dart';

import '../../../common/widget/app_bar.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/notification_badge.dart';
import '../model/chat_model.dart';
import '../model/message_model.dart';
import 'chat_message_item.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatModel chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  ChatDetailScreenState createState() => ChatDetailScreenState();
}

class ChatDetailScreenState extends State<ChatDetailScreen> {
  final NavigationService _navigationService = NavigationService();
  final TextEditingController _messageController = TextEditingController();
  bool _hasFocus = false;
  List<MessageModel> messages = [];
  final bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BasicAppBar(
            title: 'Chat',
            backgroundColor: true,
            leading: GestureDetector(
              onTap: () {
                _navigationService.goBack();
              },
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                child: Image.asset(AppAssetsIcons.arrowLeft),
              ),
            ),
            trailing: GestureDetector(
              onTap: () {
                //_navigationService.changeTab(1);
              },
              child: NotificationBadge(),
            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            widget.chat.avatar,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.chat.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: widget.chat.isOnline
                                          ? Colors.green
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    widget.chat.isOnline ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.phone),
                        onPressed: () {
                          // Handle call
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : messages.isEmpty
                            ? Center(child: Text('No messages yet'))
                            : ListView.builder(
                                itemCount: messages.length,
                                reverse: false,
                                itemBuilder: (context, index) {
                                  return ChatMessageItem(
                                      message: messages[index]);
                                },
                              ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.dark.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            onChanged: (value) {
                              setState(() {
                                _hasFocus = value.isNotEmpty;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _hasFocus ? Icons.send : Icons.attach_file,
                            color: AppColors.primary,
                          ),
                          onPressed: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
