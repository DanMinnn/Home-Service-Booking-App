import 'dart:convert';

import 'package:home_service_tasker/models/tasker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modules/auth/repo/auth_repo.dart';
import '../providers/log_provider.dart';

class TaskerRepository {
  LogProvider get logger => const LogProvider('TASKER-REPO');
  static final TaskerRepository _instance = TaskerRepository._internal();
  Tasker? _currentTasker;
  final AuthRepo _loginRepo = AuthRepo();

  factory TaskerRepository() {
    return _instance;
  }

  TaskerRepository._internal();

  Tasker? get currentTasker => _currentTasker;

  Future<void> loadTaskerFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final taskerJson = prefs.getString('tasker_data');
      if (taskerJson != null) {
        _currentTasker = Tasker.fromJson(json.decode(taskerJson));
        logger.log(
            "Tasker loaded from storage: ${_currentTasker?.name.toString()}");
      }
    } catch (e) {
      logger.log("Error loading tasker from storage: ${e.toString()}");
    }
  }

  Future<void> saveTaskerToStorage(Tasker tasker) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasker_data', json.encode(tasker.toJson()));
      await prefs.setInt('taskerId', tasker.id!);
      logger.log("Tasker saved to storage: ${tasker.toString()}");
    } catch (e) {
      logger.log("Error saving tasker to storage: ${e.toString()}");
    }
  }

  void setCurrentTasker(Tasker tasker) {
    _currentTasker = tasker;
    saveTaskerToStorage(tasker);
    logger.log("Current tasker set: ${tasker.toString()}");
  }

  Future<Tasker?> loadTaskerByEmail(String email) async {
    try {
      final tasker = await _loginRepo.getTaskerInfo(email);
      setCurrentTasker(tasker);
      return tasker;
    } catch (e) {
      logger.log("Error loading tasker by email: ${e.toString()}");
      return null;
    }
  }

  Future<void> clearTasker() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('tasker_data');
      _currentTasker = null;
      logger.log('Tasker data cleared');
    } catch (e) {
      logger.log('Error clearing tasker data: $e');
    }
  }
}
