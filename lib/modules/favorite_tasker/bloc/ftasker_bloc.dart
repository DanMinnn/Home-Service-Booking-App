import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/favorite_tasker/repo/favorite_tasker_repo.dart';

import 'ftasker_event.dart';
import 'ftasker_state.dart';

class FTaskerBloc extends Bloc<FTaskerEvent, FTaskerState> {
  final FavoriteTaskerRepo favoriteTaskerRepo;
  FTaskerBloc(this.favoriteTaskerRepo) : super(FTaskerInitial()) {
    on<FTaskerLoadEvent>(_onFetchFavoriteTaskers);
    on<ChatTaskerEvent>(_onChatTasker);
  }

  Future<void> _onFetchFavoriteTaskers(
      FTaskerLoadEvent event, Emitter<FTaskerState> emit) async {
    emit(FTaskerLoading());
    try {
      final taskers =
          await favoriteTaskerRepo.fetchFavoriteTaskers(event.userId);
      emit(FTaskerLoaded(taskers: taskers));
    } catch (e) {
      emit(FTaskerError(message: e.toString()));
    }
  }

  Future<void> _onChatTasker(
    ChatTaskerEvent event,
    Emitter<FTaskerState> emit,
  ) async {
    try {
      final room = await favoriteTaskerRepo.createChatRoom(event.chatRoomReq);
      if (room.status == 201) {
        emit(ChatRoomCreated(room.message));
      } else {
        emit(FTaskerError(message: room.message));
      }
    } catch (e) {
      emit(FTaskerError(message: e.toString()));
    }
  }
}
