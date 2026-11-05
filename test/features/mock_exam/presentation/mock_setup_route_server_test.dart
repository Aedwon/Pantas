import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/mock_exam/application/mock_blueprint_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/custom_blueprint_repository.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_setup_route.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

const _examId = 'exam_cse_sub';

Map<String, Object?> _reply(String status, {Object? next, String? exam}) => {
      'examId': exam ?? _examId,
      'serverNow': 2000,
      'nextEligibleAt': next,
      'status': status,
      'proCovered': false,
      if (status == 'available')
        'setup': {'questionCount': 170, 'expectedQuestionCount': 170},
    };

Future<void> _open(
  WidgetTester tester,
  Future<Object?> Function() reply,
) async {
  var starts = 0;
  final router = GoRouter(
    initialLocation: '/quiz',
    routes: [
      GoRoute(path: '/quiz', builder: (_, __) => const Text('Quiz tab')),
      GoRoute(
        path: '/quiz/mock/setup',
        builder: (_, __) => MockSetupRoute(
          examId: _examId,
          onStart: (_, {required strictMode}) => starts++,
        ),
      ),
    ],
  );
  await tester.pumpAppWithRouter(
    router,
    overrides: [
      mockUsesServerProvider.overrideWithValue(true),
      serverMockIdentityProvider.overrideWithValue('a'),
      serverMockActorProvider.overrideWithValue(() => 'a'),
      entitlementProvider
          .overrideWith((ref) => Stream.value(const Entitlement.free())),
      userSettingsProvider.overrideWith((_) async => UserSettings.defaults()),
      mockSetupParsedBlueprintProvider(_examId).overrideWith(
        (_) async => const ParsedMockBlueprint(
          blueprint: MockBlueprint(
            id: 'bp_1',
            examId: _examId,
            name: 'CSE Practice Paper',
            durationMinutes: 170,
            sectionsJson: '[]',
          ),
          sections: [],
        ),
      ),
      serverMockApiProvider
          .overrideWithValue(ServerMockApi((_, __) => reply())),
    ],
  );
  unawaited(router.push('/quiz/mock/setup'));
  await tester.pumpAndSettle();
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
}

void main() {
  testWidgets('cooldown shows when the next mock opens and no Start',
      (tester) async {
    await _open(tester, () async => _reply('cooldown', next: 2592002000));
    expect(find.text('Free includes one mock every 30 days.'), findsOneWidget);
    expect(find.textContaining('Your next one opens '), findsOneWidget);
    expect(find.text('Something went wrong.'), findsNothing);
    expect(find.text('Start the Mock Exam'), findsNothing);
    expect(find.byType(MockSetupPage), findsNothing);
  });

  testWidgets('cooldown offers a way back', (tester) async {
    await _open(tester, () async => _reply('cooldown', next: 2592002000));
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Quiz tab'), findsOneWidget);
  });

  testWidgets('no blueprint shows the status card wording and no Start',
      (tester) async {
    await _open(tester, () async => _reply('no-blueprint'));
    expect(find.text('Mock paper not ready'), findsOneWidget);
    expect(find.text('Something went wrong.'), findsNothing);
    expect(find.text('Start the Mock Exam'), findsNothing);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets(
      'too few questions for the paper shows "Mock paper not ready", '
      'not an error with Try Again', (tester) async {
    await _open(
      tester,
      () async => throw const ServerMockException(
        code: 'failed-precondition',
        message: 'There are not enough questions for this mock yet.',
      ),
    );
    expect(find.text('Mock paper not ready'), findsOneWidget);
    expect(find.text('Something went wrong.'), findsNothing);
    expect(find.text('Try Again'), findsNothing);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('a cooldown reply with no date is still an error',
      (tester) async {
    await _open(tester, () async => _reply('cooldown'));
    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('a reply for another exam is still an error', (tester) async {
    await _open(
      tester,
      () async => _reply('cooldown', next: 2592002000, exam: 'other'),
    );
    expect(find.text('Something went wrong.'), findsOneWidget);
  });

  testWidgets('a network failure is still an error with Try Again',
      (tester) async {
    await _open(
      tester,
      () async => throw const ServerMockException(code: 'unavailable'),
    );
    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('an available mock still shows setup', (tester) async {
    await _open(tester, () async => _reply('available'));
    expect(find.byType(MockSetupPage), findsOneWidget);
  });

  group('a custom exam', () {
    const customId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';

    const saved = ParsedMockBlueprint(
      blueprint: MockBlueprint(
        id: 'custom_x',
        examId: customId,
        name: 'PUP CET',
        durationMinutes: 90,
        sectionsJson: '[]',
      ),
      sections: [],
    );

    Future<void> openCustom(
      WidgetTester tester,
      Future<Object?> Function() reply, {
      bool hasPaper = true,
    }) async {
      final paper = hasPaper ? saved : null;
      final router = GoRouter(
        initialLocation: '/quiz',
        routes: [
          GoRoute(path: '/quiz', builder: (_, __) => const Text('Quiz tab')),
          GoRoute(
            path: '/quiz/mock/custom-setup',
            builder: (_, __) => const Text('Custom setup page'),
          ),
          GoRoute(
            path: '/quiz/mock/setup',
            builder: (_, __) => MockSetupRoute(
              examId: customId,
              onStart: (_, {required strictMode}) {},
            ),
          ),
        ],
      );
      await tester.pumpAppWithRouter(
        router,
        overrides: [
          mockUsesServerProvider.overrideWithValue(true),
          serverMockIdentityProvider.overrideWithValue('a'),
          serverMockActorProvider.overrideWithValue(() => 'a'),
          entitlementProvider
              .overrideWith((ref) => Stream.value(const Entitlement.free())),
          userSettingsProvider
              .overrideWith((_) async => UserSettings.defaults()),
          mockSetupParsedBlueprintProvider(customId)
              .overrideWith((_) async => paper),
          serverMockApiProvider
              .overrideWithValue(ServerMockApi((_, __) => reply())),
        ],
      );
      unawaited(router.push('/quiz/mock/setup?examId=$customId'));
      await tester.pumpAndSettle();
      addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));
    }

    testWidgets(
        'a paper the server cannot build opens the custom setup, not '
        '"Mock paper not ready"', (tester) async {
      await openCustom(
        tester,
        () async => throw const ServerMockException(
          code: 'failed-precondition',
          message: 'There are not enough questions for this mock yet.',
        ),
      );
      expect(find.text('Custom setup page'), findsOneWidget);
      expect(find.text('Mock paper not ready'), findsNothing);
    });

    testWidgets('a server with no paper opens the custom setup too',
        (tester) async {
      await openCustom(
        tester,
        () async => _reply('no-blueprint', exam: customId),
      );
      expect(find.text('Custom setup page'), findsOneWidget);
    });

    testWidgets('setup is a replacement, so Back from it goes to the Quiz tab',
        (tester) async {
      await openCustom(
        tester,
        () async => _reply('no-blueprint', exam: customId),
      );
      GoRouter.of(tester.element(find.text('Custom setup page'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('Quiz tab'), findsOneWidget);
    });

    testWidgets('with no paper on this device the old wording stays',
        (tester) async {
      await openCustom(
        tester,
        () async => _reply('no-blueprint', exam: customId),
        hasPaper: false,
      );
      expect(find.text('Mock paper not ready'), findsOneWidget);
      expect(find.text('Custom setup page'), findsNothing);
    });

    testWidgets('a cooldown still shows its date', (tester) async {
      await openCustom(
        tester,
        () async => _reply('cooldown', next: 2592002000, exam: customId),
      );
      expect(
        find.text('Free includes one mock every 30 days.'),
        findsOneWidget,
      );
      expect(find.text('Custom setup page'), findsNothing);
    });

    testWidgets('an available paper still shows the start page',
        (tester) async {
      await openCustom(
        tester,
        () async => _reply('available', exam: customId),
      );
      expect(find.byType(MockSetupPage), findsOneWidget);
      expect(find.text('PUP CET simulation'), findsOneWidget);
    });
  });

  group('the start page of a custom paper', () {
    const customId = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';
    const partRule = 'This paper runs part by part. '
        "Once a part ends, you can't go back to it.";
    const oneBlockRule = 'This paper runs as one block. You can move around '
        "the whole paper and submit when you're done.";

    final focus = activeExamFocusProvider.overrideWith(
      (_) async => const ActiveExamFocus.selected(
        Exam(
          id: customId,
          code: 'MINE',
          name: 'PUP CET',
          shortName: 'PUP CET',
          language: 'en',
          isActive: true,
          subjects: [],
          isCustom: true,
        ),
      ),
    );

    Future<AppDatabase> paper({
      required bool timedSeparately,
      List<(String, int, int)> parts = const [
        ('Mathematics', 40, 50),
        ('Reasoning', 40, 30),
        ('Science', 40, 40),
      ],
    }) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await CustomBlueprintRepository(db).save(
        CustomBlueprint(
          examId: customId,
          totalQuestions: 120,
          totalMinutes: 120,
          sectionsTimedSeparately: timedSeparately,
          sections: [
            for (final (name, items, minutes) in parts)
              CustomBlueprintSectionDraft(
                subjectId: 'subj_$name',
                name: name,
                questions: items,
                minutes: minutes,
              ),
          ],
        ),
        topicsBySubject: {
          for (final (name, _, _) in parts) 'subj_$name': ['topic_$name'],
        },
        now: DateTime.utc(2026, 11, 5),
      );
      return db;
    }

    Future<ParsedMockBlueprint> parse(
      AppDatabase db,
    ) async {
      final box = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db), focus],
      );
      addTearDown(box.dispose);
      final parsed =
          await box.read(mockSetupParsedBlueprintProvider(customId).future);
      return parsed!;
    }

    test('timed separately with parts runs part by part, with each time',
        () async {
      final parsed = await parse(await paper(timedSeparately: true));
      expect(parsed.blueprint.sectionalTiming, SectionalTiming.sectional);
      expect(parsed.sections.map((s) => s.sectionalMinutes), [50, 30, 40]);
      expect(parsed.blueprint.durationMinutes, 120);
    });

    test('the same parts on one clock show no part times', () async {
      final parsed = await parse(await paper(timedSeparately: false));
      expect(parsed.blueprint.sectionalTiming, SectionalTiming.roamable);
      expect(
        parsed.sections.map((s) => s.sectionalMinutes),
        [null, null, null],
      );
    });

    test('one part cannot run part by part, as on the server', () async {
      final parsed = await parse(
        await paper(
          timedSeparately: true,
          parts: const [('Mathematics', 40, 50)],
        ),
      );
      expect(parsed.blueprint.sectionalTiming, SectionalTiming.roamable);
    });

    for (final byPart in [true, false]) {
      testWidgets('the page for byPart=$byPart', (tester) async {
        final db = await paper(timedSeparately: byPart);
        final router = GoRouter(
          initialLocation: '/quiz',
          routes: [
            GoRoute(path: '/quiz', builder: (_, __) => const Text('Quiz tab')),
            GoRoute(
              path: '/quiz/mock/setup',
              builder: (_, __) => MockSetupRoute(
                examId: customId,
                onStart: (_, {required strictMode}) {},
              ),
            ),
          ],
        );
        await tester.pumpAppWithRouter(
          router,
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            focus,
            mockUsesServerProvider.overrideWithValue(true),
            mockSetupQuestionCountProvider(customId)
                .overrideWith((_) async => 120),
            userSettingsProvider
                .overrideWith((_) async => UserSettings.defaults()),
          ],
        );
        unawaited(router.push('/quiz/mock/setup'));
        await tester.pumpAndSettle();
        addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

        expect(find.text('PUP CET simulation'), findsOneWidget);
        expect(find.text('120 total items · 2 hr'), findsOneWidget);
        expect(find.text(byPart ? partRule : oneBlockRule), findsOneWidget);
        expect(find.text('TIME'), byPart ? findsOneWidget : findsNothing);
        expect(find.text('50 min'), byPart ? findsOneWidget : findsNothing);
        expect(find.text('30 min'), byPart ? findsOneWidget : findsNothing);
        expect(find.text('40 min'), byPart ? findsOneWidget : findsNothing);
        expect(
          find.text(
            'Closest to the real exam. Turn it on when you can take the whole '
            'mock without interruptions.',
          ),
          findsOneWidget,
        );
      });
    }
  });
}
