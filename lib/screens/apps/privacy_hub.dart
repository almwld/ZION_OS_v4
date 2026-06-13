import 'package:flutter/material.dart';

class PrivacyHubApp extends StatelessWidget {
  const PrivacyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Privacy Hub', style: TextStyle(color: Color(0xFF00BCD4))),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00BCD4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          'Privacy Hub - Coming Soon',
          style: TextStyle(color: Color(0xFF00BCD4), fontSize: 18),
        ),
      ),
    );
  }
}
