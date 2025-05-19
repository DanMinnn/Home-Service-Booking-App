import 'package:flutter/material.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
              RouteName.loginScreen, (context) => false);
        },
        child: Text(
          'Logout',
          style: AppTextStyles.headline6,
        ),
      ),
    );
  }
}
