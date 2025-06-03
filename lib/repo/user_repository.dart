import 'dart:convert';

import 'package:home_service/models/user.dart';
import 'package:home_service/modules/authentication/repos/login_repo.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  LogProvider get logger => const LogProvider('USER-REPO');
  static final UserRepository _instance = UserRepository._internal();
  User? _currentUser;
  final LoginRepo _loginRepo = LoginRepo();

  factory UserRepository() {
    return _instance;
  }

  UserRepository._internal();

  User? get currentUser => _currentUser;

  Future<void> loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson));
        logger
            .log("User loaded from storage: ${_currentUser?.name.toString()}");
      }
    } catch (e) {
      logger.log("Error loading user from storage: ${e.toString()}");
    }
  }

  Future<void> saveUserToStorage(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(user.toJson()));
      await prefs.setInt('userId', user.id!);
      logger.log("User saved to storage: ${user.toString()}");
    } catch (e) {
      logger.log("Error saving user to storage: ${e.toString()}");
    }
  }

  Future<void> updateUserInStorage(String name, String imagePath) async {
    try {
      await loadUserFromStorage();
      final user = _currentUser;

      if (user != null) {
        user.name = name;
        user.profileImage = imagePath;
        await saveUserToStorage(user);
      }
      logger.log("User updated in storage: ${user.toString()}");
    } catch (e) {
      logger.log("Error updating user in storage: ${e.toString()}");
    }
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    saveUserToStorage(user);
    logger.log("Current user set: ${user.toString()}");
  }

  Future<User?> loadUserByEmail(String email) async {
    try {
      final user = await _loginRepo.getUserInfo(email);
      setCurrentUser(user);
      return user;
    } catch (e) {
      logger.log("Error loading user by email: ${e.toString()}");
      return null;
    }
  }

  Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      _currentUser = null;
      logger.log('User data cleared');
    } catch (e) {
      logger.log('Error clearing user data: $e');
    }
  }
}
