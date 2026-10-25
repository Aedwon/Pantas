import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/loading_shapes.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'custom exam continues through date, days and Name before web completes',
    (tester) => _customFlow(tester, web: true),
  );

  testWidgets(
    'native custom exam completes after Name with no reminders step',
    (tester) => _customFlow(tester, web: false),
  );

  testWidgets('native resume after Name finishes instead of showing a blank',
      (tester) async {
    final telemetry = _Telemetry();
    final db = inMemoryDatabase();
    addTearDown(db.close);
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
        telemetryProvider.overrideWithValue(telemetry),
        appDatabaseProvider.overrideWithValue(db),
        onboardingWebProvider.overrideWithValue(false),
        onboardingProgressProvider.overrideWith(
          (ref) async => OnboardingProgress(
            agePassed: true,
            policyAccepted: true,
            examPicked: true,
            dateAnswered: true,
            daysAnswered: true,
            nameAnswered: true,
          ),
        ),
      ],
    );
    await tester.pump();
    expect(find.byType(LoadingShapes), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(await AppPreferencesRepository(db).hasCompletedOnboarding(), isTrue);
    expect(telemetry.steps, isNot(contains('reminders')));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _customFlow(WidgetTester tester, {required bool web}) async {
  {
    final telemetry = _Telemetry();
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
        telemetryProvider.overrideWithValue(telemetry),
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        onboardingWebProvider.overrideWithValue(web),
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
    expect(find.text('When is your exam?'), findsOneWidget);
    expect(
      await AppPreferencesRepository(db).hasCompletedOnboarding(),
      isFalse,
    );
    await tester.tap(find.text("I don't know"));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Every Day'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Aedwon');
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(
      telemetry.events
          .where((event) => event == TelemetryEvent.onboardingCompleted),
      hasLength(1),
    );
    expect(await AppPreferencesRepository(db).hasCompletedOnboarding(), isTrue);
    expect(find.text('Sounds Good'), findsNothing);
    expect(telemetry.steps, isNot(contains('reminders')));
    await tester.pumpWidget(const SizedBox.shrink());
  }
}

class _Telemetry extends DisabledTelemetry {
  final events = <TelemetryEvent>[];
  final steps = <Object?>[];
  @override
  Future<void> log(
    TelemetryEvent event, {
    Map<String, Object>? properties,
  }) async {
    events.add(event);
    if (event == TelemetryEvent.onboardingStepReached) {
      steps.add(properties?['step']);
    }
  }
}
