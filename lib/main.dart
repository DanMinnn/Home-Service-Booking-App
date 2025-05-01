import 'package:flutter/material.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/ui/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
    );
  }
}
