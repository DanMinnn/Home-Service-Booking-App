import 'dart:convert';

import 'package:home_service_admin/modules/login/repo/login_repo.dart';
import 'package:home_service_admin/modules/user/models/user_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/log_provider.dart';

class AdminStorage {
  LogProvider get logger => const LogProvider('ADMIN-STORAGE');
  static final AdminStorage _instance = AdminStorage._internal();
  UserResponse? _currentAdmin;
  final LoginRepo _loginRepo = LoginRepo();

  factory AdminStorage() {
    return _instance;
  }

  AdminStorage._internal();

  UserResponse? get currentAdmin => _currentAdmin;

  Future<void> loadTaskerFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final taskerJson = prefs.getString('admin_data');
      if (taskerJson != null) {
        _currentAdmin = UserResponse.fromJson(json.decode(taskerJson));
      }
    } catch (e) {
      logger.log("Error loading tasker from storage: ${e.toString()}");
    }
  }

  Future<void> saveAdminToStorage(UserResponse admin) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_data', json.encode(admin.toJson()));
    } catch (e) {
      logger.log("Error saving tasker to storage: ${e.toString()}");
    }
  }

  void setCurrentAdmin(UserResponse admin) {
    _currentAdmin = admin;
    saveAdminToStorage(admin);
  }

  Future<UserResponse?> loadAdminByEmail(String email) async {
    try {
      final admin = await _loginRepo.getAdminInfo(email);
      setCurrentAdmin(admin);
      return admin;
    } catch (e) {
      return null;
    }
  }

  Future<void> clearTasker() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_data');
      _currentAdmin = null;
    } catch (e) {
      logger.log('Error clearing admin data: $e');
    }
  }
}
