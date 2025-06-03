import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/chat/bloc/chat_bloc.dart';
import 'package:home_service_tasker/modules/chat/bloc/chat_event.dart';
import 'package:home_service_tasker/providers/log_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widget/app_bar.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/notification_badge.dart';
import '../bloc/chat_state.dart';
import '../widget/chat_detail_screen.dart';
import '../widget/chat_list_item.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final LogProvider logger = LogProvider('::::CHAT-PAGE::::');
  String authToken = '';
  int taskerId = 0;
  late final ChatBloc _chatBloc;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatBloc = ChatBloc();
    _initData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // When returning to this page, refresh chat rooms if already initialized
    if (_isInitialized && mounted) {
      logger.log("didChangeDependencies - refreshing chat rooms");
      _chatBloc.add(ChatRoomsLoadedEvent(taskerId));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isInitialized) {
      // Reinitialize chat when app comes back to foreground
      logger.log("App resumed - reinitializing chat");
      _chatBloc.add(ChatInitialized(authToken, taskerId, 'tasker'));
    }
  }

  Future<void> _initData() async {
    await loadTaskerInfo();
    if (taskerId > 0 && authToken.isNotEmpty) {
      logger.log("Initializing chat with taskerId: $taskerId");
      _chatBloc.add(ChatInitialized(authToken, taskerId, 'tasker'));
      _isInitialized = true;

      // Load chat rooms after a short delay to ensure connection is established
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          logger.log("Loading chat rooms for taskerId: $taskerId");
          _chatBloc.add(ChatRoomsLoadedEvent(taskerId));
        }
      });
    } else {
      logger.log(
          "Cannot initialize chat: taskerId=$taskerId, token=${authToken.isNotEmpty}");
    }
  }

  Future<void> loadTaskerInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawId = prefs.getInt('taskerId');
      final token = prefs.getString('access_token');

      bool hasToken = token != null && token.isNotEmpty;
      bool hasId = rawId != null && rawId > 0;

      logger.log(
          "Failed to load tasker credentials - Token: $hasToken, ID: $hasId");

      if (hasToken) {
        setState(() {
          authToken = token;
        });
      }

      if (hasId) {
        setState(() {
          taskerId = rawId;
        });
      }

      logger.log("Final Tasker ID: $taskerId");
    } catch (e) {
      logger.log("Error loading tasker info: $e");
    }
  }

  @override
  void dispose() {
    logger.log("Disposing ChatPage");
    WidgetsBinding.instance.removeObserver(this);
    _chatBloc.close();
    super.dispose();
  }

  void _refreshChatRooms() {
    if (taskerId > 0) {
      logger.log("Manually refreshing chat rooms");
      _chatBloc.add(ChatRoomsLoadedEvent(taskerId));
    }
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
          BlocProvider.value(
            value: _chatBloc,
            child: Expanded(
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
                    // Chat list
                    BlocConsumer<ChatBloc, ChatState>(
                      listener: (context, state) {
                        if (state is ChatError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (state is ChatConnected &&
                            state.isConnected) {
                          // Load rooms when connected
                          logger.log("Chat connected, loading rooms");
                          _chatBloc.add(ChatRoomsLoadedEvent(taskerId));
                        }
                      },
                      builder: (context, state) {
                        if (state is ChatLoading || state is ChatInitial) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                    color: AppColors.primary),
                                SizedBox(height: 16),
                                Text('Connecting to chat...'),
                              ],
                            ),
                          );
                        }
                        if (state is ChatError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline,
                                    size: 64, color: Colors.red),
                                SizedBox(height: 16),
                                Text(state.message),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refreshChatRooms,
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is ChatRoomsLoaded) {
                          final chatRooms = state.rooms;
                          if (chatRooms.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline,
                                      size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text(
                                    'No conversations yet',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Start a conversation to see it here',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                _chatBloc.add(ChatRoomsLoadedEvent(taskerId));
                              },
                              child: ListView.builder(
                                itemCount: chatRooms.length,
                                itemBuilder: (context, index) {
                                  final room = chatRooms[index];
                                  return ChatListItem(
                                    chatBloc: _chatBloc,
                                    room: room,
                                    taskerId: taskerId,
                                    userType: 'tasker',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BlocProvider.value(
                                            value: _chatBloc,
                                            child: ChatDetailScreen(
                                              room: room,
                                              taskerId: taskerId,
                                              userType: 'tasker',
                                            ),
                                          ),
                                        ),
                                      ).then((_) {
                                        // Refresh rooms when returning from detail page
                                        if (mounted) {
                                          _chatBloc.add(
                                              ChatRoomsLoadedEvent(taskerId));
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Waiting for connection...'),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshChatRooms,
                                child: Text('Load Chats'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
