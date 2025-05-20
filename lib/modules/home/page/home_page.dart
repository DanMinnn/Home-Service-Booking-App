import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/routes/route_name.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

import '../../../blocs/app_state_bloc.dart';

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
          context.read<AppStateBloc>().logout();
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
