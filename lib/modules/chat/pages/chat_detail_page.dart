import 'package:flutter/material.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/modules/chat/pages/chat_message_item.dart';
import 'package:home_service/themes/app_colors.dart';

import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';
import '../../authentication/widgets/custom_text_field.dart';

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final NavigationService _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BasicAppBar(
            isLeading: false,
            isTrailing: false,
            leading: GestureDetector(
              onTap: () {
                _navigationService.goBack();
              },
              child: Image.asset(AppAssetIcons.arrowLeft),
            ),
            action: GestureDetector(
              onTap: () {
                //_navigationService.navigateTo(RouteName.chatPage);
              },
              child: Image.asset(AppAssetIcons.calling),
            ),
            trailing: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://example.com/user.jpg'),
            ),
            title: 'User name',
          ),
          Expanded(
            child: ListView(
              children: [
                ChatMessageItem(isMe: false),
                ChatMessageItem(isMe: true),
                ChatMessageItem(isMe: false),
                ChatMessageItem(isMe: true),
                ChatMessageItem(isMe: false),
                ChatMessageItem(isMe: true),
                ChatMessageItem(isMe: false),
                ChatMessageItem(isMe: true),
              ],
            ),
          ),
          _buildSendMessage(),
        ],
      ),
    );
  }

  Widget _buildSendMessage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                //controller: _amount,
                hintText: 'Message...',
                prefixIcon: null,
                onChanged: (value) {
                  setState(() {
                    //_validateAmount(value);
                  });
                },
                label: '',
                keyboardType: TextInputType.text,
                onUnfocused: () {},
                showLabel: false,
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Image.asset(
                      width: 24,
                      height: 24,
                      AppAssetIcons.sendMessage,
                    ),
                    onPressed: () {
                      // Xử lý khi nhấn nút gửi
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
