import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/home/bloc/task_event.dart';
import 'package:home_service_tasker/modules/home/bloc/task_state.dart';
import 'package:home_service_tasker/modules/home/repo/task_repo.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepo _taskRepo;
  TaskBloc(this._taskRepo) : super(TaskInitialState()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AssignTaskEvent>(_onAssignTask);
    on<LoadTaskAssignedEvent>(_onLoadTaskAssigned);
    on<CancelTaskEvent>(_onCancelTask);
    on<CompleteTaskEvent>(_onCompleteTask);
    on<CreateChatRoomEvent>(_onCreateChatRoom);
  }

  Future<void> _onLoadTasks(
      LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    try {
      final tasks =
          await _taskRepo.getAllTasksPending(event.taskerId, event.serviceIds);
      emit(TaskLoadedState(tasks));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onAssignTask(
      AssignTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    try {
      final response =
          await _taskRepo.taskerGetTask(event.bookingId, event.taskerId);
      if (response.status == 400) {
        emit(TaskErrorState(response.message));
        return;
      }
      emit(TaskAssignedState(response.message));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onLoadTaskAssigned(
      LoadTaskAssignedEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    try {
      final tasks =
          await _taskRepo.getTaskAssigned(event.taskerId, event.selectedDate);
      emit(TaskAssignedListState(tasks));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onCancelTask(
      CancelTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    try {
      final response =
          await _taskRepo.taskerCancelTask(event.bookingId, event.reason);
      if (response.status == 400) {
        emit(TaskErrorState(response.message));
        return;
      }
      emit(LoadingSuccessState(response.message));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onCompleteTask(
      CompleteTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    try {
      final response = await _taskRepo.taskerCompleteTask(event.bookingId);
      emit(LoadingSuccessState(response));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onCreateChatRoom(
    CreateChatRoomEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final room = await _taskRepo.createChatRoom(event.chatRoomReq);
      if (room.status == 201) {
        emit(ChatRoomCreated(room.message));
      } else {
        emit(TaskErrorState(room.message));
      }
    } catch (e) {
      emit(TaskErrorState('Failed to create chat room: ${e.toString()}'));
    }
  }

  // Method to manually emit a state with cached tasks
  @override
  void emit(TaskState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }
}
