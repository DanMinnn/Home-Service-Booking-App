import 'package:home_service/modules/favorite_tasker/model/tasker.dart';

abstract class FTaskerState {}

class FTaskerInitial extends FTaskerState {}

class FTaskerLoading extends FTaskerState {}

class FTaskerLoaded extends FTaskerState {
  final List<Tasker> taskers;

  FTaskerLoaded({required this.taskers});
}

class FTaskerError extends FTaskerState {
  final String message;

  FTaskerError({required this.message});
}
