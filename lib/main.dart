import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/biometric_service.dart';
import 'screens/lock_screen.dart';

void main() {
  runApp(const ZionOSApp());
}

class ZionOSApp extends StatelessWidget {
  const ZionOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BiometricService()),
      ],
      child: MaterialApp(
        title: 'Zion OS 2027',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          primaryColor: const Color(0xFF00BCD4),
          colorScheme: const ColorScheme.dark(primary: Color(0xFF00BCD4)),
        ),
        home: const LockScreen(),
      ),
    );
  }
}
