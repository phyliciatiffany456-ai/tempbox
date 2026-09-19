import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:tempbox_app/main.dart";
import "package:tempbox_app/widgets/horizontal_choice_chip_scroller.dart";

void main() {
  testWidgets("TempBox App smoke test", (WidgetTester tester) async {
    await tester.pumpWidget(const TempBoxApp());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining("TEMPBOX"), findsWidgets);
  });

  testWidgets("App-wide typography uses Poppins", (WidgetTester tester) async {
    await tester.pumpWidget(const TempBoxApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.textTheme.bodyMedium?.fontFamily, 'Poppins');
    expect(
      app.theme?.primaryTextTheme.titleLarge?.fontFamily,
      'Poppins',
    );
  });

  testWidgets("Long chip selectors can be dragged horizontally", (
    WidgetTester tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 200));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HorizontalChoiceChipScroller(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: List.generate(
              10,
              (index) => ChoiceChip(
                label: Text('Kategori $index'),
                selected: index == 0,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.axisDirection, AxisDirection.right);
    await tester.drag(find.byType(ListView), const Offset(-220, 0));
    await tester.pump();
    expect(scrollable.position.pixels, greaterThan(0));
  });

  testWidgets(
    "Splash screen stays usable on compact, phone, and tablet widths",
    (WidgetTester tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final size in const [
        Size(320, 568),
        Size(390, 844),
        Size(768, 1024),
      ]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(const TempBoxApp());
        await tester.pump();

        expect(find.text('Reservasi Cepat (Tamu)'), findsOneWidget);
        expect(find.text('Masuk / Daftar Member'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
