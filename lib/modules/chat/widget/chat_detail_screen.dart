import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/chat/bloc/chat_bloc.dart';
import 'package:home_service_tasker/modules/chat/bloc/chat_event.dart';
import 'package:home_service_tasker/modules/chat/model/chat_message_model.dart';
import 'package:home_service_tasker/routes/navigation_service.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

import '../../../common/widget/app_bar.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/notification_badge.dart';
import '../bloc/chat_state.dart';
import '../model/chat_room_model.dart';
import 'chat_message_item.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatRoomModel room;
  final int taskerId;
  final String userType;

  const ChatDetailScreen(
      {super.key,
      required this.room,
      required this.taskerId,
      required this.userType});

  @override
  ChatDetailScreenState createState() => ChatDetailScreenState();
}

class ChatDetailScreenState extends State<ChatDetailScreen>
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
    final displayName = widget.room.userName;
    final displayImage = widget.room.userProfile;

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
                        child: displayImage == null
                            ? Center(
                                child: Text(
                                  'U',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  displayImage,
                                  fit: BoxFit.cover,
                                  width: 48,
                                  height: 48,
                                ),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName ?? 'Unknown User',
                                  style: AppTextStyles.headline4.copyWith(
                                    fontWeight: FontWeight.w500,
                                  )),
                              SizedBox(height: 4),
                              BlocProvider.value(
                                value: context.read<ChatBloc>(),
                                child: BlocBuilder<ChatBloc, ChatState>(
                                  buildWhen: (previous, current) =>
                                      current is ChatOnlineStatusState ||
                                      (current is ChatInitial &&
                                          previous is! ChatInitial),
                                  builder: (context, state) {
                                    bool isOnline = false;
                                    if (state is ChatOnlineStatusState) {
                                      isOnline = state.onlineUsers[
                                              widget.room.userId] ??
                                          false;
                                    }
                                    if (state is! ChatOnlineStatusState) {
                                      try {
                                        final chatBloc =
                                            context.read<ChatBloc>();
                                        if (chatBloc.state
                                            is ChatOnlineStatusState) {
                                          final onlineState = chatBloc.state
                                              as ChatOnlineStatusState;
                                          isOnline = onlineState.onlineUsers[
                                                  widget.room.userId] ??
                                              false;
                                        } else {
                                          isOnline = chatBloc
                                              .isUserOnline(widget.room.userId);
                                        }
                                      } catch (e) {
                                        //Handle the case where the bloc is not available
                                      }
                                    }

                                    return Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isOnline
                                                ? AppColors.alertSuccess
                                                : Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          isOnline ? 'Online' : 'Offline',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isOnline
                                                ? AppColors.alertSuccess
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Color(0xFFFEF8ED),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.asset(AppAssetsIcons.phoneIc),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  BlocConsumer<ChatBloc, ChatState>(
                    listener: (context, state) {
                      if (state is ChatError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Something went wrong'),
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
                      if (state is ChatMessagesLoaded &&
                          state.roomId == widget.room.id) {
                        messages = state.messages;
                      } else if (state is ChatConnected &&
                          state.roomId == widget.room.id) {
                        messages = state.messages;
                      }

                      messages = messages.reversed.toList();
                      return Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: messages.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId == widget.taskerId;
                            return ChatMessageItem(
                              message: messages[index],
                              isMe: isMe,
                            );
                          },
                        ),
                      );

                      /*if (state is ChatMessagesLoaded &&
                          state.roomId == widget.room.id) {
                        final messages = state.messages.reversed.toList();
                        return Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length,
                            reverse: true,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == widget.taskerId;
                              return ChatMessageItem(
                                message: messages[index],
                                isMe: isMe,
                              );
                            },
                          ),
                        );
                      }
                      if (state is ChatLoading) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Center(
                        child: Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      );*/
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _hasFocus
                                  ? AppColors.primary
                                  : AppColors.grey,
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _hasFocus = value.isNotEmpty;
                              });
                            },
                            controller: _messageController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFF2F2F2),
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: _messageController.text.trim().isNotEmpty
                            ? _sendMessage
                            : null,
                        child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                _messageController.text.trim().isNotEmpty
                                    ? AppColors.primary
                                    : AppColors.dark,
                                BlendMode.srcIn),
                            child: Image.asset(AppAssetsIcons.sendIc)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
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
      _isTyping = false;
      context.read<ChatBloc>().add(ChatTypingStopped(widget.room.id));
    }
  }
}
