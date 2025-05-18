import 'package:flutter/material.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';
import '../../authentication/widgets/custom_text_field.dart';

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          _buildMessage(isSender: true),
          _buildMessage(isSender: false),
          Spacer(),
          _buildSendMessage(),
        ],
      ),
    );
  }

  Widget _buildMessage({
    String? message,
    String? time,
    bool isSender = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: isSender
            ? BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(22),
                ),
              )
            : BoxDecoration(
                color: Color(0xFFF6F6F6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(20),
                ),
              ),
        child: Text(
          'Hello, how can I help you?',
          style: AppTextStyles.bodyMediumRegular.copyWith(
            color: AppColors.darkBlue,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
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
