import 'package:flutter/material.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/modules/chat/pages/chat_detail_page.dart';
import 'package:home_service/modules/chat/pages/chat_list_item.dart';
import 'package:home_service/themes/app_colors.dart';

import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
                _navigationService.goBackToPreviousTab();
              },
              child: Image.asset(AppAssetIcons.arrowLeft),
            ),
            title: 'Chat',
          ),
          Expanded(
            child: ChatListItem(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailPage(
                        // room: room,
                        // taskerId: taskerId,
                        // userType: 'tasker',
                        ),
                  ),
                );
              },
            ),
          ),
          //_buildChatItem(),
        ],
      ),
    );
  }
}
