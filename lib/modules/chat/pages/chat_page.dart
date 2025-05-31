import 'dart:async';

import 'package:flutter/material.dart';

import '../../../common/widget/app_bar.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/notification_badge.dart';
import '../model/chat_model.dart';
import '../widget/chat_detail_screen.dart';
import '../widget/chat_list_item.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatModel> chats = [];
  StreamSubscription? _chatSubscription;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Column(
        children: [
          BasicAppBar(
            title: 'Chat',
            backgroundColor: true,
            leading: Image.asset(AppAssetsIcons.menuIc),
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
                  // Search bar
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color(0xFF3C3C3C),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      onChanged: (value) {
                        _searchQuery = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Search chats...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  // Chat list
                  Expanded(
                    child: chats.isEmpty
                        ? Center(
                            child: Text('No chats available'),
                          )
                        : ListView.builder(
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              return ChatListItem(
                                chat: chats[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChatDetailScreen(chat: chats[index]),
                                    ),
                                  );
                                },
                              );
                            },
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
