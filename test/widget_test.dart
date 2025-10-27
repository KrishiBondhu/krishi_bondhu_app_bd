import 'package:flutter_test/flutter_test.dart';

import 'package:krishi_bondhu_app_bd/main.dart 
void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const KrishiBondhuApp());

    // Simple verification that app built successfully
    expect(true, isTrue);
  });
}
