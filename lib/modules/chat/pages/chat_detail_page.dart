import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/modules/chat/models/chat_message_model.dart';
import 'package:home_service/modules/chat/pages/chat_message_item.dart';
import 'package:home_service/themes/app_colors.dart';

import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';
import '../../authentication/widgets/custom_text_field.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../models/chat_room_model.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatRoomModel room;
  final int userId;
  final String userType;

  const ChatDetailPage({
    super.key,
    required this.room,
    required this.userId,
    required this.userType,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage>
    with WidgetsBindingObserver {
  final NavigationService _navigationService = NavigationService();
  final TextEditingController _messageController = TextEditingController();
  bool _hasFocus = false;
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(ChatRoomSelected(widget.room.id));
      context.read<ChatBloc>().add(ChatMessagesLoadedEvent(widget.room.id));
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When app is resumed, refresh the chat messages
      context.read<ChatBloc>().add(ChatMessagesLoadedEvent(widget.room.id));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0) {
      // Load more messages when reaching the top
      final currentState = context.read<ChatBloc>().state;
      if (currentState is ChatMessagesLoaded && !currentState.hasReachedMax) {
        final currentPage = (currentState.messages.length / 50).floor();
        context.read<ChatBloc>().add(
              ChatMessagesLoadedEvent(widget.room.id, page: currentPage + 1),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.room.taskerName;
    final displayImage = widget.room.taskerProfile;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
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
              trailing: Stack(
                clipBehavior: Clip.none,
                children: [
                  displayImage != null
                      ? CircleAvatar(
                          radius: 24,
                          child: ClipOval(
                            child: Image.network(
                              displayImage,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.darkBlue.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: AppColors.darkBlue,
                          ),
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: BlocProvider.value(
                      value: context.read<ChatBloc>(),
                      child: BlocBuilder<ChatBloc, ChatState>(
                        buildWhen: (previous, current) =>
                            current is ChatOnlineStatusState,
                        builder: (context, state) {
                          bool isOnline = false;
                          if (state is ChatOnlineStatusState) {
                            isOnline =
                                state.onlineUsers[widget.room.taskerId] ??
                                    false;
                          } else {
                            isOnline = context
                                .read<ChatBloc>()
                                .isUserOnline(widget.room.taskerId);
                          }
                          return Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isOnline ? AppColors.green : AppColors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              title: displayName,
            ),
            BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is ChatMessagesLoaded &&
                    state.roomId == widget.room.id) {
                  // Scroll to bottom when new message arrives
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              },
              builder: (context, state) {
                List<ChatMessageModel> messages = [];

                if (state is ChatConnected && state.roomId == widget.room.id) {
                  messages = state.messages;
                } else if (state is ChatMessagesLoaded &&
                    state.roomId == widget.room.id) {
                  messages = state.messages;
                }
                // if (state is ChatMessagesLoaded &&
                //     state.roomId == widget.room.id) {
                //   final messages = state.messages.reversed.toList();
                //   return Expanded(
                //     child: ListView.builder(
                //       padding: EdgeInsets.zero,
                //       controller: _scrollController,
                //       itemCount: messages.length,
                //       reverse: true,
                //       itemBuilder: (context, index) {
                //         final message = messages[index];
                //         final isMe = message.senderId == widget.userId;
                //         return ChatMessageItem(
                //           message: messages[index],
                //           isMe: isMe,
                //         );
                //       },
                //     ),
                //   );
                // }
                messages = messages.reversed.toList();
                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    controller: _scrollController,
                    itemCount: messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == widget.userId;
                      return ChatMessageItem(
                        message: messages[index],
                        isMe: isMe,
                      );
                    },
                  ),
                );
                // if (state is ChatLoading) {
                //   return Center(
                //     child: CircularProgressIndicator(color: Color(0xFF386DF3)),
                //   );
                // }
                // return Center(
                //   child: Text(
                //     state.toString(),
                //     style: TextStyle(
                //       color: Colors.grey,
                //       fontSize: 16,
                //     ),
                //   ),
                // );
              },
            ),
            _buildSendMessage(),
          ],
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
                controller: _messageController,
                hintText: 'Message...',
                prefixIcon: null,
                onChanged: (value) {
                  setState(() {
                    _hasFocus = _messageController.text.trim().isNotEmpty;
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
                  color: _hasFocus ? AppColors.darkBlue : AppColors.darkBlue20,
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
                    onPressed: _hasFocus ? _sendMessage : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTypingChanged(String text) {
    final isCurrentlyTyping = text.isNotEmpty;

    if (isCurrentlyTyping != _isTyping) {
      _isTyping = isCurrentlyTyping;
      if (_isTyping) {
        context.read<ChatBloc>().add(ChatTypingStarted(widget.room.id));
      } else {
        context.read<ChatBloc>().add(ChatTypingStopped(widget.room.id));
      }
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatBloc>().add(ChatMessageSent(widget.room.id, message));
      _messageController.clear();
      // _isTyping = false;
      // context.read<ChatBloc>().add(ChatTypingStopped(widget.room.id));
    }
  }
}
