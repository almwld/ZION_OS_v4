import 'package:flutter_test/flutter_test.dart';
import 'package:zion_os/main.dart';

void main() {
  testWidgets('Zion OS application boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ZionOSApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ZionOSApp), findsOneWidget);
  });
}
