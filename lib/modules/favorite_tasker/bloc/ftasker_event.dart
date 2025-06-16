abstract class FTaskerEvent {}

class FTaskerLoadEvent extends FTaskerEvent {
  final int userId;

  FTaskerLoadEvent({required this.userId});
}
