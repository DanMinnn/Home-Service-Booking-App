import 'dart:convert';

import 'package:home_service_tasker/models/tasker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modules/auth/repo/login_repo.dart';
import '../providers/log_provider.dart';

class TaskerRepository {
  LogProvider get logger => const LogProvider('tasker-REPO');
  static final TaskerRepository _instance = TaskerRepository._internal();
  Tasker? _currentTasker;
  final LoginRepo _loginRepo = LoginRepo();

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
      await prefs.setString('Tasker_data', json.encode(tasker.toJson()));
      logger.log("Tasker saved to storage: ${tasker.toString()}");
    } catch (e) {
      logger.log("Error saving tasker to storage: ${e.toString()}");
    }
  }

  Future<void> updateTaskerInStorage(String name, String imagePath) async {
    try {
      await loadTaskerFromStorage();
      final tasker = _currentTasker;

      if (tasker != null) {
        tasker.name = name;
        tasker.profileImage = imagePath;
        await saveTaskerToStorage(tasker);
      }
      logger.log("Tasker updated in storage: ${tasker.toString()}");
    } catch (e) {
      logger.log("Error updating tasker in storage: ${e.toString()}");
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
