import 'package:flutter_test/flutter_test.dart';

import 'package:krishikhamar/main.dart';

void main() {
  testWidgets('App launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriVisionApp());
    expect(find.text('AgriVisionX AI'), findsOneWidget);
    expect(find.text('Smart Farming Powered by AI'), findsOneWidget);
    // Complete splash timers so the test tears down cleanly.
    await tester.pump(const Duration(seconds: 3));
  });
}
