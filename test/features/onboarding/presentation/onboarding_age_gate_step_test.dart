import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_age_gate_step.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() => db.close());

  Future<void> pumpStep(WidgetTester tester, {VoidCallback? onPassed}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: OnboardingAgeGateStep(
              onAgeGatePassed: onPassed ?? () {},
              currentYear: 2026,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the prompt and disabled Continue initially',
      (tester) async {
    await pumpStep(tester);

    expect(find.text('Quick check'), findsOneWidget);
    expect(find.text('When were you born?'), findsOneWidget);
    final cont = tester
        .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'));
    expect(cont.onPressed, isNull);
  });

  testWidgets('selecting a valid year persists and invokes onAgeGatePassed',
      (tester) async {
    var passed = 0;
    await pumpStep(tester, onPassed: () => passed++);

    final picker = find.byType(CupertinoPicker);
    expect(picker, findsOneWidget);
    // Default selection is currentYear - 18 = 2008. Drag down to
    // confirm a year.
    await tester.drag(picker, const Offset(0, -32));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(passed, equals(1));
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isTrue);
  });

  testWidgets('under-13 year shows block state without persisting',
      (tester) async {
    var passed = 0;
    await pumpStep(tester, onPassed: () => passed++);

    // Scroll wheel up enough to reach a year > 2013 (under 13 in 2026).
    final picker = find.byType(CupertinoPicker);
    // Default index lands at 2008 (currentYear - 18). To reach 2014 we
    // scroll down by 6 items. CupertinoPicker default item extent is 32.
    await tester.drag(picker, const Offset(0, -32.0 * 6));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text("Sorry, this app isn't available for users under 13."),
      findsOneWidget,
    );
    expect(find.text('Try a different year'), findsOneWidget);
    expect(passed, equals(0));
    expect(await AppPreferencesRepository(db).hasPassedAgeGate(), isFalse);
  });

  testWidgets('Try a different year returns to input state', (tester) async {
    await pumpStep(tester);

    final picker = find.byType(CupertinoPicker);
    await tester.drag(picker, const Offset(0, -32.0 * 6));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try a different year'));
    await tester.pumpAndSettle();

    expect(find.text('When were you born?'), findsOneWidget);
    expect(
      find.text("Sorry, this app isn't available for users under 13."),
      findsNothing,
    );
  });
}
