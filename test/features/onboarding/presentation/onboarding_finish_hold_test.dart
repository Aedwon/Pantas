import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_writes.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

/// The study settings go to the server in the background. Until they land,
/// the web Home cannot read a plan, so it showed "Could not load your plan"
/// for a moment after Done. Onboarding now stays on the Name page until they
/// have landed, and never swaps to an empty page while it waits.
class _SlowWrites extends StudyWrites {
  final landed = Completer<void>();
  @override
  Future<void> get settingsSettled => landed.future;
}

void main() {
  Future<AppDatabase> reachName(
    WidgetTester tester, {
    required bool web,
    required _SlowWrites writes,
  }) async {
    final db = inMemoryDatabase();
    final content = inMemoryContentDatabase();
    addTearDown(db.close);
    addTearDown(content.close);
    await seedContentExam(
      content,
      examId: 'exam_cse_pro',
      code: 'CSE',
      name: 'Civil Service',
    );
    await seedContentSubject(
      content,
      subjectId: 's1',
      examId: 'exam_cse_pro',
      name: 'Mathematics',
    );
    await seedContentTopic(
      content,
      topicId: 't1',
      subjectId: 's1',
      name: 'Algebra',
    );
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [
        telemetryProvider.overrideWithValue(const DisabledTelemetry()),
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        onboardingWebProvider.overrideWithValue(web),
        studyUsesServerProvider.overrideWithValue(web),
        studyWritesProvider.overrideWithValue(writes),
        onboardingProgressProvider.overrideWith(
          (ref) async =>
              OnboardingProgress(agePassed: true, policyAccepted: true),
        ),
        examPickerCatalogProvider.overrideWith((ref) => Stream.value(const [])),
      ],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text("My exam isn't listed"));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'My Exam');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mathematics'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("I don't know"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Every Day'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Aedwon');
    await tester.pump();
    return db;
  }

  testWidgets(
    'web: after Done the Name page stays, busy, until the settings land',
    (tester) async {
      final writes = _SlowWrites();
      final db = await reachName(tester, web: true, writes: writes);
      await tester.tap(find.text('Done'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('What should we call you?'), findsOneWidget);
        expect(find.byType(LoadingShapes), findsNothing);
        expect(find.text('Home'), findsNothing);
      }
      writes.landed.complete();
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(
        await AppPreferencesRepository(db).hasCompletedOnboarding(),
        isTrue,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'native: Home opens without waiting for the settings',
    (tester) async {
      final writes = _SlowWrites();
      await reachName(tester, web: false, writes: writes);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
