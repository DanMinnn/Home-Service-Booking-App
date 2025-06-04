import 'package:home_service_tasker/modules/home/models/task.dart';

abstract class TaskState {}

class TaskInitialState extends TaskState {}

class TaskLoadingState extends TaskState {}

class TaskLoadedState extends TaskState {
  final List<Task> tasks;

  TaskLoadedState(this.tasks);
}

class TaskAssignedState extends TaskState {
  final String message;

  TaskAssignedState(this.message);
}

class LoadingSuccessState extends TaskState {
  final String message;

  LoadingSuccessState(this.message);
}

class TaskErrorState extends TaskState {
  final String error;

  TaskErrorState(this.error);
}

class TaskAssignedListState extends TaskState {
  final List<Task> tasks;

  TaskAssignedListState(this.tasks);
}

class ChatRoomCreated extends TaskState {
  final String message;

  ChatRoomCreated(this.message);
}
