import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_service_tasker/routes/navigation_service.dart';
import 'package:home_service_tasker/routes/routes.dart';
import 'package:home_service_tasker/services/firebase_messaging_service.dart';
import 'package:home_service_tasker/theme/app_colors.dart';

import 'blocs/app_state_bloc.dart';
import 'modules/auth/repo/email_verified_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // Initialize Firebase
  await Firebase.initializeApp();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Firebase messaging service
  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.init();

  runApp(
    EmailVerificationHandler(
      child: const TaskerApp(),
    ),
  );
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // You can perform background tasks here, but avoid UI operations
}

class TaskerApp extends StatelessWidget {
  const TaskerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();

    return BlocProvider<AppStateBloc>(
      create: (_) => AppStateBloc(),
      child: BlocBuilder<AppStateBloc, AppState>(
        builder: (context, state) {
          return MaterialApp(
            key: ValueKey('APP-STATE-${state.toString()}'),
            navigatorKey: navigationService.navigatorKey,
            title: 'Home service',
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                color: AppColors.white,
                centerTitle: false,
                titleSpacing: 0,
                elevation: 0,
              ),
              fontFamily: 'DMSans',
            ),
            debugShowCheckedModeBanner: false,
            onGenerateRoute: state == AppState.authorized
                ? Routes.authorizedRoute
                : Routes.unAuthorizedRoute,
            builder: _builder,
          );
        },
      ),
    );
  }

  //if user setting font size on device, app can not change it
  Widget _builder(BuildContext context, Widget? child) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(1)),
      child: child!,
    );
  }
}
