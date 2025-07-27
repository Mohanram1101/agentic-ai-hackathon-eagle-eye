import 'package:flutter/material.dart';

void main() {
  runApp(const DrishtiApp());
}

class DrishtiApp extends StatelessWidget {
  const DrishtiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Drishti',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      //home: const LiveDashboard(),
    );
  }
}
