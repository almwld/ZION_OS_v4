import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'screens/settings_screen.dart';
import 'screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ar'),
      child: const ZionOSApp(),
    ),
  );
}

class ZionOSApp extends StatelessWidget {
  const ZionOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Zion OS 2027',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
              primaryColor: themeProvider.primaryColor,
              scaffoldBackgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.grey[100],
              fontFamily: 'Cairo',
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
                bodyMedium: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
              ),
            ),
            localizationsDelegates: [
              EasyLocalization.of(context)!.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const LockScreen(),
          );
        },
      ),
    );
  }
}
