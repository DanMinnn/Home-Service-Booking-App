import '../providers/log_provider.dart';
import '../repo/tasker_repository.dart';

class LoadTaskerInfo {
  final LogProvider logger = const LogProvider(':::LOAD-TASKER-INFO:::');
  static final LoadTaskerInfo _instance = LoadTaskerInfo._internal();
  final TaskerRepository _taskerRepository = TaskerRepository();

  factory LoadTaskerInfo() {
    return _instance;
  }

  LoadTaskerInfo._internal();

  int? _taskerId;
  List<int>? _serviceIds;

  int? get taskerId => _taskerId;
  List<int>? get serviceIds => _serviceIds;

  Future<void> loadTaskerInfo() async {
    try {
      final currentTasker = _taskerRepository.currentTasker;
      if (currentTasker != null) {
        _serviceIds =
            currentTasker.services!.map((service) => service.id).toList();
        _taskerId = currentTasker.id!;
        logger.log(
            'Tasker services loaded by login: ${_serviceIds?.length} services, taskerId: $_taskerId');
      }

      await _taskerRepository.loadTaskerFromStorage();
      final tasker = _taskerRepository.currentTasker;
      if (tasker != null) {
        _serviceIds = tasker.services!.map((service) => service.id).toList();
        _taskerId = tasker.id!;
        logger.log(
            'Tasker services loaded from storage: ${_serviceIds?.length} services, taskerId: $_taskerId');
      } else {
        logger.log('No tasker found in storage');
      }
    } catch (e) {
      logger.log('Error loading tasker info: $e');
      _serviceIds = [];
      _taskerId = 0;
    }
  }
}
