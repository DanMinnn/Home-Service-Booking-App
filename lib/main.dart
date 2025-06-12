import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_service_admin/routes/navigation_service.dart';
import 'package:home_service_admin/themes/app_colors.dart';
import 'package:home_service_admin/ui/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = NavigationService();
    return MaterialApp(
      title: 'Admin Home Service',
      navigatorKey: navigationService.navigatorKey,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: AppColors.neutral,
          centerTitle: false,
          titleSpacing: 0,
          elevation: 0,
        ),
        fontFamily: 'DMSans',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
