import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportzones/main.dart';

void main() {
  testWidgets('App smoke test - builds without errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });
}
