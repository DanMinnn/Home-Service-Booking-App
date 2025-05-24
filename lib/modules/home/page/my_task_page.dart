import 'package:flutter/material.dart';

class MyTaskPage extends StatefulWidget {
  const MyTaskPage({super.key});

  @override
  State<MyTaskPage> createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<MyTaskPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Job Received Page'),
    );
  }
}
