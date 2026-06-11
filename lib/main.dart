import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_manager.dart';
import 'core/services/notification_service.dart';
import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  notificationService.init();
  runApp(ZionOSApp(notificationService: notificationService));
}

class ZionOSApp extends StatelessWidget {
  final NotificationService notificationService;
  
  const ZionOSApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: notificationService),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Zion OS 2027',
            debugShowCheckedModeBanner: false,
            theme: themeManager.getThemeData(),
            home: const LockScreen(),
          );
        },
      ),
    );
  }
}
