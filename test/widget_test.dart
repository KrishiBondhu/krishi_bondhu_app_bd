// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:krishibondhu/main.dart';

void main() {
  testWidgets('KrishiBondhu app creates MaterialApp with correct title',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KrishiBondhuApp());

    // Verify that the MaterialApp is created
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that the app title is KrishiBondhu
    final MaterialApp materialApp =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'KrishiBondhu');

    // Verify that debug banner is disabled
    expect(materialApp.debugShowCheckedModeBanner, false);
  });
}
