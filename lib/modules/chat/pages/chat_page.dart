import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/common/widgets/stateless/show_snack_bar.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/log_provider.dart';
import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../models/chat_room_model.dart';
import 'chat_detail_page.dart';
import 'chat_list_item.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final NavigationService _navigationService = NavigationService();
  final LogProvider logger = LogProvider('::::CHAT-PAGE::::');
  String authToken = '';
  int userId = 0;
  late final ChatBloc _chatBloc;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); //observer when event occurs
    _chatBloc = ChatBloc();
    _initData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isInitialized) {
      // Reinitialize chat when app comes back to foreground
      logger.log("App resumed - reinitializing chat");
      _chatBloc.add(ChatInitialized(authToken, userId, 'user'));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // When returning to this page, refresh chat rooms if already initialized
    if (_isInitialized && mounted) {
      logger.log("didChangeDependencies - refreshing chat rooms");
      _chatBloc.add(ChatRoomsLoadedEvent(userId));
    }
  }

  Future<void> _initData() async {
    await loadUserInfo();
    if (userId > 0 && authToken.isNotEmpty) {
      logger.log("Initializing chat with userId: $userId");
      _chatBloc.add(ChatInitialized(authToken, userId, 'user'));
      _isInitialized = true;

      // Load chat rooms after a short delay to ensure connection is established
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          logger.log("Loading chat rooms for userId: $userId");
          _chatBloc.add(ChatRoomsLoadedEvent(userId));
        }
      });
    } else {
      logger.log(
          "Cannot initialize chat: userId=$userId, token=${authToken.isNotEmpty}");
    }
  }

  Future<void> loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawId = prefs.getInt('userId');
      final token = prefs.getString('access_token');

      bool hasToken = token != null && token.isNotEmpty;
      bool hasId = rawId != null && rawId > 0;

      logger.log(
          "Failed to load user credentials - Token: $hasToken, ID: $hasId");

      if (hasToken) {
        setState(() {
          authToken = token;
        });
      }

      if (hasId) {
        setState(() {
          userId = rawId;
        });
      }

      logger.log("Final Tasker ID: $userId");
    } catch (e) {
      logger.log("Error loading user info: $e");
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
    if (userId > 0) {
      logger.log("Manually refreshing chat rooms");
      _chatBloc.add(ChatRoomsLoadedEvent(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
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
            BlocProvider.value(
              value: _chatBloc,
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatError) {
                    ShowSnackBar.showError(context, state.message);
                  } else if (state is ChatConnected && state.isConnected) {
                    // Load rooms when connected
                    logger.log("Chat connected, loading rooms");
                    _chatBloc.add(ChatRoomsLoadedEvent(userId));
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading || state is ChatInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF386DF3)),
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

                  List<ChatRoomModel> rooms = [];
                  if (state is ChatRoomsLoaded) {
                    final chatRooms = state.rooms;
                    rooms = chatRooms;

                    logger.log(
                      "Chat rooms loaded with ${rooms.length} rooms",
                    );
                  } else if (state is ChatConnected) {
                    rooms = state.rooms;

                    logger.log(
                      "Chat connected with ${rooms.length} rooms",
                    );
                  }

                  if (rooms.isNotEmpty) {
                    // return Center(
                    //   child: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Icon(Icons.chat_bubble_outline,
                    //           size: 64, color: Colors.grey),
                    //       SizedBox(height: 16),
                    //       Text(
                    //         'No conversations yet',
                    //         style: TextStyle(fontSize: 18, color: Colors.grey),
                    //       ),
                    //       SizedBox(height: 8),
                    //       Text(
                    //         'Start a conversation to see it here',
                    //         style: TextStyle(color: Colors.grey),
                    //       ),
                    //     ],
                    //   ),
                    // );
                    return Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          _chatBloc.add(ChatRoomsLoadedEvent(userId));
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 10),
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            return ChatListItem(
                              room: room,
                              userId: userId,
                              userType: 'user',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider.value(
                                      value: _chatBloc,
                                      child: ChatDetailPage(
                                        room: room,
                                        userId: userId,
                                        userType: 'user',
                                      ),
                                    ),
                                  ),
                                ).then((_) {
                                  // Refresh rooms when returning from detail page
                                  if (mounted) {
                                    _chatBloc.add(ChatRoomsLoadedEvent(userId));
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
                        Text(state.runtimeType.toString()),
                        SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _refreshChatRooms,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.darkBlue,
                            ),
                            child: Text(
                              'Load Chats',
                              style: TextStyle(color: Colors.white),
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
