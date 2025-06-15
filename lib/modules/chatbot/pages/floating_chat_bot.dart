import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/chatbot/bloc/chatbot_bloc.dart';
import 'package:home_service/modules/chatbot/bloc/chatbot_event.dart';
import 'package:home_service/modules/chatbot/repo/chatbot_repo.dart';
import 'package:home_service/themes/app_assets.dart';

import '../../../repo/user_repository.dart';
import '../../../themes/app_colors.dart';
import '../bloc/chatbot_state.dart';
import '../model/chat_message.dart';

class FloatingChatBot extends StatefulWidget {
  final VoidCallback onClose;

  const FloatingChatBot({
    super.key,
    required this.onClose,
  });

  @override
  State<FloatingChatBot> createState() => _FloatingChatBotState();
}

class _FloatingChatBotState extends State<FloatingChatBot>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final TextEditingController _messageController = TextEditingController();
  final UserRepository _userRepository = UserRepository();
  int _userId = 0;
  final ChatbotBloc _chatbotBloc = ChatbotBloc(ChatbotRepo());
  bool _historyLoaded = false;

  Future<void> _loadUserInfo() async {
    final currentUser = _userRepository.currentUser;
    if (currentUser != null && currentUser.name != null) {
      setState(() {
        _userId = currentUser.id!;
      });
      return;
    }

    //if user data not in cache, get from local storage
    await _userRepository.loadUserFromStorage();
    final userStorage = _userRepository.currentUser;
    if (userStorage != null && userStorage.name != null) {
      setState(() {
        _userId = userStorage.id!;
      });
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadUserInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();

      // load chat history
      if (!_historyLoaded && _userId > 0) {
        _chatbotBloc.add(ChatbotLoadHistoryEvent(_userId));
        _historyLoaded = true;
      }
    } else {
      _animationController.reverse();
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final messageText = _messageController.text.trim();
      _chatbotBloc.add(ChatbotMessageSentEvent(_userId, messageText));

      _messageController.clear();
    }
  }

  void _refreshHistory() {
    if (_userId > 0) {
      _chatbotBloc.add(ChatbotLoadHistoryEvent(_userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Chat Window
        if (_isExpanded)
          BlocProvider.value(
            value: _chatbotBloc,
            child: Positioned(
              bottom: 80,
              right: 16,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 400,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.darkBlue,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.smart_toy,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'AI Assistant',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // Refresh button
                                  IconButton(
                                    onPressed: _refreshHistory,
                                    icon: Icon(
                                      Icons.refresh,
                                      color: AppColors.white,
                                      size: 20,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                  ),
                                  SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: widget.onClose,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.white
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: AppColors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BlocBuilder<ChatbotBloc, ChatbotState>(
                              builder: (context, state) {
                                if (state is ChatbotLoading) {
                                  return Expanded(
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Color(0xFF386DF3)),
                                    ),
                                  );
                                } else if (state is ChatbotMessagesLoaded) {
                                  final messages = state.messages;
                                  if (messages.isNotEmpty) {
                                    // Use a ScrollController to auto-scroll to bottom
                                    final scrollController = ScrollController();
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (scrollController.hasClients) {
                                        scrollController.animateTo(
                                          scrollController
                                              .position.maxScrollExtent,
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeOut,
                                        );
                                      }
                                    });

                                    return Expanded(
                                      child: ListView.builder(
                                        controller: scrollController,
                                        padding: EdgeInsets.all(16),
                                        itemCount: messages.length,
                                        itemBuilder: (context, index) {
                                          final message = messages[index];
                                          return _buildMessageBubble(message);
                                        },
                                      ),
                                    );
                                  }
                                } else if (state is ChatbotError) {
                                  return Expanded(
                                    child: Center(
                                      child: Text(
                                        'Error: ${state.message}',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Expanded(
                                  child: Center(
                                    child: Text(
                                      'Start chatting with AI Assistant',
                                      style: TextStyle(
                                        color: AppColors.darkBlue
                                            .withValues(alpha: 0.6),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Input Field
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.darkBlue20.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      decoration: InputDecoration(
                                        hintText: 'Type your message...',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _sendMessage,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkBlue,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Image.asset(
                                        AppAssetIcons.sendMessage,
                                        color: AppColors.white,
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Floating Button
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: _toggleChat,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBlue.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isExpanded ? Icons.close : Icons.chat_bubble,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: EdgeInsets.only(
          bottom: 12,
          left: message.isUser ? 40 : 0,
          right: message.isUser ? 0 : 40,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.darkBlue
              : AppColors.darkBlue20.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft:
                message.isUser ? Radius.circular(16) : Radius.circular(4),
            bottomRight:
                message.isUser ? Radius.circular(4) : Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: message.isUser ? AppColors.white : AppColors.black,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? AppColors.white.withValues(alpha: 0.7)
                    : AppColors.black.withValues(alpha: 0.5),
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();

    if (time.year == now.year &&
        time.month == now.month &&
        time.day == now.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
