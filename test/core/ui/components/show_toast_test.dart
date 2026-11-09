import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

Future<void> _pump(
  WidgetTester tester,
  void Function(BuildContext context) onTap,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLightTheme(web: false),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => onTap(context),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the message as the system Toast', (tester) async {
    await _pump(tester, (c) => showPantasToast(c, 'Saved'));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(Toast), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(tester.widget<Toast>(find.byType(Toast)).onUndo, isNull);
  });

  testWidgets('a new toast replaces the current one', (tester) async {
    await _pump(tester, (c) {
      showPantasToast(c, 'First');
      showPantasToast(c, 'Second');
    });
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('lasts 4 seconds, and 8 with Undo', (tester) async {
    await _pump(tester, (c) => showPantasToast(c, 'Plain'));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 3800));
    expect(find.text('Plain'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Plain'), findsNothing);

    await _pump(tester, (c) => showPantasToast(c, 'Flagged', onUndo: () {}));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 7, milliseconds: 800));
    expect(find.text('Flagged'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Flagged'), findsNothing);
  });

  testWidgets('an explicit duration wins', (tester) async {
    await _pump(
      tester,
      (c) => showPantasToast(c, 'Long', duration: const Duration(seconds: 10)),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 9));
    expect(find.text('Long'), findsOneWidget);
  });

  testWidgets('Undo runs the callback and dismisses the toast', (tester) async {
    var undone = 0;
    await _pump(
      tester,
      (c) => showPantasToast(c, 'Flagged', onUndo: () => undone++),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(undone, 1);
    expect(find.text('Flagged'), findsNothing);
  });

  testWidgets('web layout comes from the parameter', (tester) async {
    await _pump(tester, (c) => showPantasToast(c, 'Wide', web: true));
    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.widget<Toast>(find.byType(Toast)).web, isTrue);
  });

  testWidgets('does nothing without a messenger', (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          showPantasToast(context, 'Lost');
          return const SizedBox();
        },
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
