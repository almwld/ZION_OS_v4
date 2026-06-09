import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/wm/window_manager.dart';
import 'zion_desktop.dart';
import 'zion_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  runApp(ChangeNotifierProvider(create: (_) => WindowManager(), child: const ZionOS()));
}

class ZionOS extends StatelessWidget {
  const ZionOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zion Linux',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: Colors.black, fontFamily: 'monospace'),
      home: LayoutBuilder(
        builder: (context, constraints) {
          // إذا كانت الشاشة عريضة (أكبر من 600px) → وضع سطح المكتب (PC Mode)
          if (constraints.maxWidth > 600) {
            return const ZionDesktop();
          }
          // إذا كانت الشاشة ضيقة → وضع التطبيق (App Mode)
          return const ZionHome();
        },
      ),
    );
  }
}
