import 'package:flutter/material.dart';
import 'features/dashboard/cosmic_dashboard.dart';

class ZionApp extends StatelessWidget {
  const ZionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Zion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF0000),
        scaffoldBackgroundColor: const Color(0xFF0A0000),
        fontFamily: 'monospace',
      ),
      home: const CosmicDashboard(),
    );
  }
}
