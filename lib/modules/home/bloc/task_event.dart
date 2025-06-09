import '../../chat/model/chat_room_req.dart';

abstract class TaskEvent {}

class LoadTasksEvent extends TaskEvent {
  final int taskerId;
  final List<int> serviceIds;
  LoadTasksEvent({required this.taskerId, required this.serviceIds});
}

class AssignTaskEvent extends TaskEvent {
  final int bookingId;
  final int taskerId;
  AssignTaskEvent({required this.bookingId, required this.taskerId});
}

class LoadTaskAssignedEvent extends TaskEvent {
  final int taskerId;
  final String selectedDate;
  LoadTaskAssignedEvent({required this.taskerId, required this.selectedDate});
}

class CancelTaskEvent extends TaskEvent {
  final int bookingId;
  final String reason;
  CancelTaskEvent({required this.bookingId, required this.reason});
}

class CompleteTaskEvent extends TaskEvent {
  final int bookingId;
  CompleteTaskEvent({required this.bookingId});
}

class CreateChatRoomEvent extends TaskEvent {
  final ChatRoomReq chatRoomReq;

  CreateChatRoomEvent(this.chatRoomReq);
}
