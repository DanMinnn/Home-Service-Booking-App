import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/repo/user_repository.dart';
import 'package:home_service/utils/prefs_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/log_provider.dart';

enum AppState { loading, unAuthorized, authorized }

class AppStateBloc extends Cubit<AppState> {
  LogProvider get logger => const LogProvider('APP-STATE-BLOC:::');
  final UserRepository _userRepository = UserRepository();
  AppStateBloc() : super(AppState.loading) {
    _launchApp();
  }

  Future<void> _launchApp() async {
    final prefs = await SharedPreferences.getInstance();
    final authorLevel = prefs.getInt(PrefsKey.authorLevel);

    logger.log('Authorization level: $authorLevel');

    if (authorLevel == 2) {
      await _userRepository.loadUserFromStorage();
      emit(AppState.authorized);
      logger.log('User is authorized');
    } else {
      emit(AppState.unAuthorized);
      logger.log('User is unauthorized');
    }
  }

  Future<void> changeAppState(AppState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKey.authorLevel, state.index);
    logger.log('Authorization level changed to: ${state.index}');
    emit(state);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefsKey.authorLevel);
    await _userRepository.clearUser();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('userId');
    logger.log('User logged out');
    emit(AppState.unAuthorized);
  }
}
