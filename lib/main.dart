import 'package:flutter/material.dart';
import 'package:home_service_tasker/modules/auth/pages/set_new_password.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
        fontFamily: 'DMSans',
      ),
      home: const SetNewPassword(),
      debugShowCheckedModeBanner: false,
    );
  }
}
