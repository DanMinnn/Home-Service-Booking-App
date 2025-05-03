import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_service/modules/authentication/repos/email_verification_handler.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/ui/splash_screen.dart';

import 'modules/authentication/pages/verify_success_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return EmailVerificationHandler(
      child: MaterialApp(
        navigatorKey:
            navigatorKey, // Using the navigatorKey from email_verification_handler.dart
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
        home: Splashscreen(),
        routes: {
          '/verified-screen': (context) => const VerifySuccessPage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/verify-screen') {
            return MaterialPageRoute(
              builder: (context) => const VerifySuccessPage(),
            );
          }
          return null;
        },
      ),
    );
  }
}
