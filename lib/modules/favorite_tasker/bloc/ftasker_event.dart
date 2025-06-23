import 'package:home_service/modules/favorite_tasker/model/chat_room_req.dart';

abstract class FTaskerEvent {}

class FTaskerLoadEvent extends FTaskerEvent {
  final int userId;

  FTaskerLoadEvent({required this.userId});
}

class ChatTaskerEvent extends FTaskerEvent {
  final ChatRoomReq chatRoomReq;

  ChatTaskerEvent({required this.chatRoomReq});
}
