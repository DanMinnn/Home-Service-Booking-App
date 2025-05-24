class TaskerServiceReq {
  int taskerId;
  List<int> serviceIds;

  TaskerServiceReq({required this.taskerId, required this.serviceIds});

  Map<String, dynamic> toJson() {
    return {
      'taskerId': taskerId,
      'serviceIds': serviceIds,
    };
  }
}
