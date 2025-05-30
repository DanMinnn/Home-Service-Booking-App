import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_service/blocs/app_state_bloc.dart';
import 'package:home_service/modules/authentication/repos/email_verification_handler.dart';
import 'package:home_service/routes/routes.dart';
import 'package:home_service/services/firebase_messaging_service.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';

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
      child: const MyApp(),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Get the single instance of NavigationService
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

  Widget _builder(BuildContext context, Widget? child) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(1)),
      child: child!,
    );
  }
}
