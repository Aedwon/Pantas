import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/no_scroll_bars.dart';
import 'package:pantas/core/storage/storage.dart';

import '../helpers/in_memory_database.dart';

Widget _longLists(ScrollBehavior behavior, TargetPlatform platform) {
  return MaterialApp(
    scrollBehavior: behavior,
    theme: ThemeData(platform: platform),
    home: Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 200,
              itemBuilder: (_, i) =>
                  SizedBox(height: 48, child: Text('Row $i')),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < 100; i++)
                    SizedBox(height: 48, child: Text('Line $i')),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() {
  for (final platform in TargetPlatform.values) {
    testWidgets('no scroll bar appears on $platform', (tester) async {
      await tester
          .pumpWidget(_longLists(const NoScrollBarsBehavior(), platform));
      await tester.pumpAndSettle();

      expect(find.byType(Scrollbar), findsNothing);
      expect(find.byType(RawScrollbar), findsNothing);
      expect(find.text('Row 0'), findsOneWidget);
    });
  }

  testWidgets('the default behavior does draw bars on desktop platforms',
      (tester) async {
    // Guards the test above: without our behavior the bars exist, so the
    // "findsNothing" checks are meaningful.
    await tester.pumpWidget(
      _longLists(const MaterialScrollBehavior(), TargetPlatform.macOS),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsWidgets);
  });

  testWidgets('scrolling still works without bars', (tester) async {
    await tester.pumpWidget(
      _longLists(const NoScrollBarsBehavior(), TargetPlatform.macOS),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.text('Row 1'), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Row 0'), findsNothing);
  });

  test('mouse drag is not added', () {
    expect(
      const NoScrollBarsBehavior().dragDevices,
      isNot(contains(PointerDeviceKind.mouse)),
    );
  });

  testWidgets('the app uses the no-scroll-bars behavior', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.scrollBehavior, isA<NoScrollBarsBehavior>());
  });
}
