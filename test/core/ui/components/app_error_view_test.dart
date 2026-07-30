import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/app_error_view.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('says one line and nothing else', (tester) async {
    await tester.pumpApp(const AppErrorView());

    expect(find.text('Something went wrong here.'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('shows no stack trace, no error code and no button', (
    tester,
  ) async {
    await tester.pumpApp(const AppErrorView());

    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(Icon), findsNothing);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('carries no apology and no instruction', (tester) async {
    await tester.pumpApp(const AppErrorView());

    final text = tester.widget<Text>(find.byType(Text)).data!;
    for (final banned in ['sorry', 'please', 'try again', 'error', 'oops']) {
      expect(
        text.toLowerCase().contains(banned),
        isFalse,
        reason: 'the copy is settled and contains no "$banned"',
      );
    }
    expect(text.contains('—'), isFalse, reason: 'no em dashes');
  });

  testWidgets('paints on paper, not on a card', (tester) async {
    await tester.pumpApp(const AppErrorView());

    // Scoped to the view's own subtree: the harness Scaffold supplies a
    // zero-elevation PhysicalModel of its own, and asserting against the
    // whole tree would be testing the harness.
    expect(
      find.descendant(
        of: find.byType(AppErrorView),
        matching: find.byType(Card),
      ),
      findsNothing,
    );

    // The identity bans elevation and drop shadows.
    final models = tester.widgetList<PhysicalModel>(
      find.descendant(
        of: find.byType(AppErrorView),
        matching: find.byType(PhysicalModel),
      ),
    );
    for (final model in models) {
      expect(model.elevation, 0);
    }
  });

  testWidgets('debug keeps the framework screen, which a developer needs', (
    tester,
  ) async {
    final original = ErrorWidget.builder;
    addTearDown(() => ErrorWidget.builder = original);

    installAppErrorView();

    // Tests run in debug, so the swap must be a no-op here. Asserting the
    // negative is the only way to catch a release-only guard that was dropped.
    expect(kReleaseMode, isFalse);
    expect(ErrorWidget.builder, same(original));
  });
}
