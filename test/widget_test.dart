import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zion_os/main.dart';

void main() {
  testWidgets('Zion OS application boots', (WidgetTester tester) async {
    await EasyLocalization.ensureInitialized();
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('ar'),
        child: const ZionOSApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ZionOSApp), findsOneWidget);
  });
}
