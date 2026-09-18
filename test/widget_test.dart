import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:tempbox_app/main.dart";

void main() {
  testWidgets("TempBox App smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(const TempBoxApp());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining("TEMPBOX"), findsWidgets);
  });
}
