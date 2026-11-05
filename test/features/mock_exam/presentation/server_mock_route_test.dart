import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_leave_guard.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/server_mock_route.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_finale.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

import '../../../helpers/in_memory_database.dart';

const _mockId = 'abcdefghij1';
final _actorEvents = StateProvider<String?>((ref) => 'uid_a');

class _ErrorSink extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

class _Server {
  final telemetry = _ErrorSink();
  String examId = 'exam_cse_pro';

  /// Sent for a custom exam only, as the server does.
  String? examName;
  bool strict = false;
  int remainingMs = 8000000;
  bool paused = false;
  bool resumed = false;
  bool completed = false;
  String availability = 'available';

  /// What the server reports once a mock has been started.
  String? availabilityAfterStart;
  int? nextEligibleAt;
  Exception? failAvailability;
  List<Map<String, Object?>> answers = [];
  final calls = <(String, Map<String, Object?>)>[];
  Exception? failStart;
  Completer<void>? holdStart;

  Map<String, Object?> view() => {
        'mockId': _mockId,
        'examId': examId,
        if (examName != null) 'examName': examName,
        'startedAt': 1790000000000,
        'strict': strict,
        'limitMs': 9000000,
        'remainingMs': remainingMs,
        'paused': paused,
        'paper': {
          'expectedQuestionCount': 3,
          'sections': [
            {
              'sectionId': 'gi',
              'name': 'General Information',
              'questions': [
                {'id': 'q1', 'setId': ''},
                {'id': 'q2', 'setId': ''},
                {'id': 'q3', 'setId': ''},
              ],
            },
          ],
        },
        'answers': answers,
      };

  Future<Object?> call(String name, Map<String, Object?> data) async {
    calls.add((name, Map.of(data)));
    switch (name) {
      case 'startMock':
        await holdStart?.future;
        final failure = failStart;
        if (failure != null) {
          failStart = null;
          throw failure;
        }
        availability = availabilityAfterStart ?? availability;
        return {...view(), 'resumed': resumed};
      case 'getMockAvailability':
        final unreadable = failAvailability;
        if (unreadable != null) throw unreadable;
        return {
          'examId': examId,
          'serverNow': 1790000000000,
          'status': availability,
          'proCovered': false,
          'nextEligibleAt': nextEligibleAt,
          'lastMockId': null,
          if (availability == 'in-progress')
            'open': {'mockId': _mockId, 'examId': examId, 'paused': paused},
        };
      case 'getMockPaper':
        return completed ? {'open': false} : {'open': true, ...view()};
      case 'getMockResults':
        return {
          ...view(),
          'serverNow': 1790000001000,
          'submittedAt': 1790000001000,
          'durationMs': 1000,
          'endedBy': 'time-out',
          'canReview': true,
          'proCovered': false,
          'reviewUntil': 1792592001000,
          'score': {
            'correct': 0,
            'answered': 0,
            'wrong': 0,
            'blank': 3,
            'total': 3,
          },
          'sections': [
            {
              'sectionId': 'gi',
              'name': 'General Information',
              'correct': 0,
              'answered': 0,
              'wrong': 0,
              'blank': 3,
              'total': 3,
            }
          ],
        };
      case 'controlMock':
        switch (data['action']) {
          case 'save':
            answers = [
              for (final a in data['answers']! as List<Object?>)
                Map<String, Object?>.of(a! as Map<String, Object?>),
            ];
          case 'pause':
            paused = true;
          case 'resume':
            paused = false;
          case 'discard':
            answers = [];
            paused = false;
        }
        return view();
      case 'submitMock':
        return {'mockId': _mockId, 'status': 'submitted'};
    }
    throw StateError(name);
  }

  Iterable<(String, Map<String, Object?>)> named(String name) =>
      calls.where((c) => c.$1 == name);
}

class _Clock {
  Duration now = Duration.zero;
}

class _Fixture {
  _Fixture(this.server, this.router, this.actor, this.clock);
  final _Server server;
  final _Clock clock;
  final GoRouter router;
  String? Function() actor;
}

Future<_Fixture> _open(
  WidgetTester tester, {
  required _Server server,
  String examId = 'exam_cse_pro',
  bool strict = false,
  String? uid = 'uid_a',
  String? Function()? actor,
  bool warningSeen = true,
  bool resume = false,
  bool stableEntitlement = false,
  bool underQuiz = false,
}) async {
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final content = openTestContentDatabase();
  addTearDown(content.close);
  await seedContentExam(content, examId: 'exam_cse_pro');
  await seedContentSubject(
    content,
    subjectId: 'subject',
    examId: 'exam_cse_pro',
  );
  await seedContentTopic(content, topicId: 'topic', subjectId: 'subject');
  for (final id in ['q1', 'q2', 'q3']) {
    await seedContentQuestion(
      content,
      questionId: id,
      topicId: 'topic',
      examId: 'exam_cse_pro',
    );
  }
  await AppPreferencesRepository(db).setSelectedExamId('exam_other');
  if (warningSeen) {
    await AppPreferencesRepository(db)
        .setDeviceValue('mock_pause_warning_seen', 'true');
  }
  final clock = _Clock();
  final fixture =
      _Fixture(server, GoRouter(routes: const []), () => uid, clock);
  if (actor != null) fixture.actor = actor;
  final router = GoRouter(
    initialLocation: underQuiz ? '/quiz' : '/mock',
    routes: [
      GoRoute(
        path: '/quiz',
        // With [underQuiz] the tab reads the exam's open-mock status as the
        // real Quiz tab does, so a stale status shows.
        builder: (_, __) => Consumer(
          builder: (_, ref, __) => Scaffold(
            body: Column(
              children: [
                const Text('Quiz tab'),
                if (underQuiz)
                  Text(
                    'status ${_status(ref)}',
                  ),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/mock/results/:id',
        builder: (_, state) => Scaffold(
          body: Text('Server results ${state.pathParameters['id']}'),
        ),
      ),
      GoRoute(
        path: '/mock',
        // The same question the real web route asks (mock_routes_web.dart).
        onExit: (context, _) => ProviderScope.containerOf(context)
            .read(mockLeaveGuardProvider)
            .allowLeave(),
        builder: (_, __) => ServerMockRoute(
          examId: examId,
          strictMode: strict,
          resumeMockId: resume ? _mockId : null,
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (stableEntitlement)
          entitlementProvider
              .overrideWith((ref) => const Stream<Entitlement>.empty()),
        appDatabaseProvider.overrideWithValue(db),
        telemetryProvider.overrideWithValue(server.telemetry),
        contentDatabaseProvider.overrideWithValue(content),
        serverMockApiProvider.overrideWithValue(ServerMockApi(server.call)),
        serverMockActorProvider.overrideWithValue(() => fixture.actor()),
        serverMockIdentityProvider
            .overrideWith((ref) => ref.watch(_actorEvents)),
        serverMockElapsedProvider.overrideWithValue(() => clock.now),
      ],
      child: MaterialApp.router(
        theme: buildLightTheme(),
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
  await advance(tester, 50);
  if (underQuiz) {
    unawaited(router.push<void>('/mock'));
    await tester.pump();
    // The page slides in; wait for it to settle.
    await advance(tester, 700);
  }
  return _Fixture(server, router, fixture.actor, clock);
}

/// Time passes in small steps so every async step in between can finish.
Future<void> advance(WidgetTester tester, int milliseconds) async {
  for (var spent = 0; spent < milliseconds; spent += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Object? _status(WidgetRef ref) => ref
    .watch(serverMockAvailabilityProvider('exam_cse_pro'))
    .valueOrNull?['status'];

void main() {
  testWidgets(
      'resuming a completed paper opens its result '
      'without a new start or finale', (tester) async {
    final server = _Server()..completed = true;
    final fixture = await _open(tester, server: server, resume: true);
    await advance(tester, 500);
    expect(find.text('Server results $_mockId'), findsOneWidget);
    expect(server.named('startMock'), isEmpty);
    expect(server.named('getMockResults'), hasLength(1));
    expect(
      fixture.router.routeInformationProvider.value.uri.queryParameters,
      isEmpty,
    );
  });

  testWidgets('A-to-B-to-A auth events cannot revive a loading paper',
      (tester) async {
    var uid = 'uid_a';
    final gate = Completer<void>();
    final server = _Server()..holdStart = gate;
    await _open(tester, server: server, actor: () => uid);
    final c =
        ProviderScope.containerOf(tester.element(find.byType(ServerMockRoute)));
    uid = 'uid_b';
    c.read(_actorEvents.notifier).state = uid;
    await tester.pump();
    uid = 'uid_a';
    c.read(_actorEvents.notifier).state = uid;
    gate.complete();
    await advance(tester, 500);
    expect(find.text('Quiz tab'), findsOneWidget);
    expect(find.text('General Information'), findsNothing);
    expect(server.named('controlMock'), isEmpty);
  });

  testWidgets(
      'an account change while loading leaves without publishing the old paper',
      (tester) async {
    String? actor = 'uid_a';
    final gate = Completer<void>();
    final server = _Server()..holdStart = gate;
    await _open(tester, server: server, actor: () => actor);
    actor = 'uid_b';
    gate.complete();
    await advance(tester, 500);
    expect(find.text('Quiz tab'), findsOneWidget);
    expect(find.text('1 of 3'), findsNothing);
    expect(server.calls, hasLength(1));
  });

  testWidgets(
      'an idle account change removes the old paper without a server write',
      (tester) async {
    String? actor = 'uid_a';
    final server = _Server();
    await _open(tester, server: server, actor: () => actor);
    expect(find.text('1 of 3'), findsOneWidget);
    actor = 'uid_b';
    await advance(tester, 500);
    expect(find.text('Quiz tab'), findsOneWidget);
    expect(find.text('1 of 3'), findsNothing);
    expect(server.calls, hasLength(1));
  });

  testWidgets('it starts the paper the server gives, whatever exam is shown',
      (tester) async {
    final server = _Server()
      ..examId = 'exam_cse_pro'
      ..resumed = true;
    await _open(tester, server: server, examId: 'exam_other');

    expect(server.named('startMock').single.$2, {
      'examId': 'exam_other',
      'strict': false,
    });
    // The open paper is shown as the server pinned it.
    expect(find.text('Question q1?'), findsOneWidget);
    expect(find.text('GENERAL INFORMATION'), findsOneWidget);
    expect(find.text('1 of 3'), findsOneWidget);
    expect(find.text('2:13:20'), findsOneWidget);
  });

  testWidgets('an answer reaches the server as the choice and its correctness',
      (tester) async {
    final server = _Server();
    await _open(tester, server: server);

    await tester.tap(find.text('Choice A'));
    await tester.pump();
    expect(server.named('controlMock'), isEmpty);
    await advance(tester, 1000);

    final save = server.named('controlMock').single.$2;
    expect(save['action'], 'save');
    final sent = (save['answers']! as List<Object?>).single! as Map;
    expect(sent['questionId'], 'q1');
    expect(sent['chosen'], 'q1_a');
    expect(sent['correct'], isTrue);
  });

  testWidgets('a reopened mock shows the choice the student made',
      (tester) async {
    final server = _Server()
      ..resumed = true
      ..answers = [
        {
          'questionId': 'q1',
          'chosen': 'q1_b',
          'correct': false,
          'answeredAt': 1790000100000,
        },
      ];
    await _open(tester, server: server);
    await advance(tester, 50);
    expect(find.text('Question q1?'), findsOneWidget);
    final rows = tester.widgetList<ChoiceRow>(find.byType(ChoiceRow)).toList();
    final picked = rows.where((row) => row.state == ChoiceRowState.picked);
    expect(picked, hasLength(1));
    expect(picked.single.text, 'Choice B');
  });

  testWidgets('next and previous move through the pinned order',
      (tester) async {
    final server = _Server();
    await _open(tester, server: server);
    await tester.tap(find.byKey(const ValueKey('mock-next')));
    await advance(tester, 500);
    expect(find.text('Question q2?'), findsOneWidget);
    expect(find.text('2 of 3'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('mock-prev')));
    await advance(tester, 500);
    expect(find.text('Question q1?'), findsOneWidget);
    // Moving about never calls the server.
    expect(server.calls.map((c) => c.$1), ['startMock']);
  });

  testWidgets(
      'leaving a discarded server paper refreshes cached card availability',
      (tester) async {
    final server = _Server();
    await _open(tester, server: server, stableEntitlement: true);
    final c =
        ProviderScope.containerOf(tester.element(find.byType(ServerMockRoute)));
    final before =
        await c.read(serverMockAvailabilityProvider('exam_cse_pro').future);
    expect(before['status'], 'available');
    server.availability = 'in-progress';
    await tester.tap(find.byKey(const ValueKey('mock-pause')));
    await advance(tester, 3000);
    await tester.ensureVisible(find.text('Discard This Mock'));
    await tester.tap(find.text('Discard This Mock'));
    await advance(tester, 300);
    await tester.tap(find.text('Discard'));
    await advance(tester, 500);
    expect(find.text('Quiz tab'), findsOneWidget);
    final after =
        await c.read(serverMockAvailabilityProvider('exam_cse_pro').future);
    expect(after['status'], 'in-progress');
    expect((after['open']! as Map<String, Object?>)['mockId'], _mockId);
  });

  testWidgets(
      'discarding keeps the server clock still, since the server restarts it '
      'on the same paper', (tester) async {
    final server = _Server();
    await _open(tester, server: server);
    await tester.tap(find.byKey(const ValueKey('mock-pause')));
    await advance(tester, 3000);
    await tester.ensureVisible(find.text('Discard This Mock'));
    await tester.tap(find.text('Discard This Mock'));
    await advance(tester, 300);
    await tester.tap(find.text('Discard'));
    await advance(tester, 500);
    expect(
      server.named('controlMock').map((c) => c.$2['action']),
      ['pause', 'discard', 'pause'],
    );
    expect(server.paused, isTrue);
  });
  testWidgets(
      'a mock opened from the Quiz card, with no exam in its address, '
      "refreshes that exam's status when it is submitted", (tester) async {
    final server = _Server()..availability = 'in-progress';
    // The card pushes /quiz/mock/resume/<id> with no exam in the address.
    final fixture = await _open(
      tester,
      server: server,
      examId: '',
      resume: true,
      underQuiz: true,
    );
    server.availability = 'available';
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await advance(tester, 500);
    await tester.ensureVisible(find.text('Submit the Exam'));
    await tester.pump();
    await tester.tap(find.text('Submit the Exam'));
    await advance(tester, 300);
    await tester.tap(find.text('Submit'));
    await advance(tester, 600);
    expect(find.text('Server results $_mockId'), findsOneWidget);
    fixture.router.go('/quiz');
    await advance(tester, 300);
    // The tab shows what the server says now, not what it said before.
    expect(find.text('status available'), findsOneWidget);
  });

  testWidgets('starting a mock tells the Quiz tab that one is open',
      (tester) async {
    final server = _Server()..availabilityAfterStart = 'in-progress';
    await _open(tester, server: server, underQuiz: true);
    final c =
        ProviderScope.containerOf(tester.element(find.byType(ServerMockRoute)));
    final status =
        await c.read(serverMockAvailabilityProvider('exam_cse_pro').future);
    expect(status['status'], 'in-progress');
  });

  group('browser Back, which changes the page without a pop,', () {
    testWidgets('pauses a running paper instead of leaving it', (tester) async {
      final server = _Server();
      final fixture = await _open(tester, server: server, underQuiz: true);
      fixture.router.go('/quiz');
      await advance(tester, 300);
      expect(server.named('controlMock').single.$2['action'], 'pause');
      expect(find.byType(PausePage), findsOneWidget);
      expect(find.byType(ServerMockRoute), findsOneWidget);
    });

    testWidgets('asks first when the pause warning has not been seen',
        (tester) async {
      final server = _Server();
      final fixture = await _open(
        tester,
        server: server,
        warningSeen: false,
        underQuiz: true,
      );
      fixture.router.go('/quiz');
      await advance(tester, 300);
      expect(find.text("Real exams don't pause."), findsOneWidget);
      expect(server.named('controlMock'), isEmpty);
      await tester.tap(find.text('Keep Going'));
      await advance(tester, 300);
      expect(find.text('Question q1?'), findsOneWidget);
      expect(server.named('controlMock'), isEmpty);
      expect(find.byType(ServerMockRoute), findsOneWidget);
    });

    testWidgets('asks first on wide web too', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final server = _Server();
      final fixture = await _open(
        tester,
        server: server,
        warningSeen: false,
        underQuiz: true,
      );
      fixture.router.go('/quiz');
      await advance(tester, 300);
      expect(find.text("Real exams don't pause."), findsOneWidget);
      expect(server.named('controlMock'), isEmpty);
      expect(find.byType(ServerMockRoute), findsOneWidget);
    });

    testWidgets('keeps a strict paper open and says why', (tester) async {
      final server = _Server()..strict = true;
      final fixture = await _open(
        tester,
        server: server,
        strict: true,
        underQuiz: true,
      );
      fixture.router.go('/quiz');
      await advance(tester, 300);
      expect(
        find.text('Strict mode is on. Back is off until you submit.'),
        findsWidgets,
      );
      expect(server.named('controlMock'), isEmpty);
      expect(server.named('submitMock'), isEmpty);
      expect(find.text('Question q1?'), findsOneWidget);
    });

    testWidgets('does nothing on the paused page, as in the app',
        (tester) async {
      final server = _Server();
      final fixture = await _open(tester, server: server, underQuiz: true);
      await tester.tap(find.byKey(const ValueKey('mock-pause')));
      await advance(tester, 300);
      final writes = server.named('controlMock').length;
      fixture.router.go('/quiz');
      await advance(tester, 300);
      expect(find.byType(PausePage), findsOneWidget);
      expect(server.named('controlMock').length, writes);
      expect(server.named('submitMock'), isEmpty);
    });
  });

  testWidgets('pause follows the server and Resume plays back first',
      (tester) async {
    final server = _Server();
    await _open(tester, server: server);

    await tester.tap(find.byKey(const ValueKey('mock-pause')));
    await advance(tester, 50);
    expect(server.named('controlMock').single.$2['action'], 'pause');
    expect(find.byType(PausePage), findsOneWidget);
    expect(find.byKey(const ValueKey('pause-paper')), findsOneWidget);

    await advance(tester, 3000);
    await tester.tap(find.text('Resume'));
    await advance(tester, 1000);
    expect(server.named('controlMock'), hasLength(1));
    await advance(tester, 1800);
    await advance(tester, 50);
    expect(server.named('controlMock').last.$2['action'], 'resume');
    expect(find.byType(PausePage), findsNothing);
    expect(find.text('Question q1?'), findsOneWidget);
  });

  testWidgets(
      'submitting from the grid sends the paper and opens its server result',
      (tester) async {
    final server = _Server();
    final fixture = await _open(tester, server: server);

    await tester.tap(find.text('Choice A'));
    await tester.tap(find.byKey(const ValueKey('mock-grid')));
    await advance(tester, 500);
    await tester.ensureVisible(find.text('Submit the Exam'));
    await tester.pump();
    await tester.tap(find.text('Submit the Exam'));
    await advance(tester, 300);
    await tester.tap(find.text('Submit'));
    await advance(tester, 100);
    await advance(tester, 500);

    final submit = server.named('submitMock').single.$2;
    expect(submit['reason'], 'student');
    expect(submit['answers']! as List<Object?>, hasLength(3));
    expect(find.text('Server results $_mockId'), findsOneWidget);
    final input =
        GoRouterState.of(tester.element(find.text('Server results $_mockId')))
            .extra! as MockFinaleInput;
    // The finale card prints this name, so it must not be the raw exam id.
    expect(input.parts.single.name, 'CSE Professional');
    expect(input.parts.single.questions.map((q) => q.id), ['q1', 'q2', 'q3']);
    expect(
      input.parts.single.questions
          .skip(1)
          .every((q) => q.outcome == MockFinaleOutcome.blank),
      true,
    );
    expect(fixture.router.canPop(), isFalse);
  });

  group('a refusal to start', () {
    const freeLimit = ServerMockException(
      code: 'failed-precondition',
      message: 'Free accounts can take one mock every 30 days.',
    );

    testWidgets(
        'the Free limit shows the waiting state with its date, not an error',
        (tester) async {
      final server = _Server()
        ..failStart = freeLimit
        ..availability = 'cooldown'
        ..nextEligibleAt = 1790000000000 + 30 * 86400000;
      await _open(tester, server: server);

      expect(
        find.text('Free includes one mock every 30 days.'),
        findsOneWidget,
      );
      expect(find.textContaining('Your next one opens '), findsOneWidget);
      expect(find.text('Could not load your mock.'), findsNothing);
      expect(find.text('Try Again'), findsNothing);
      expect(
        find.text('Free accounts can take one mock every 30 days.'),
        findsNothing,
      );
      // A normal refusal is not a failure to report.
      expect(server.telemetry.errors, isEmpty);
      expect(server.named('startMock'), hasLength(1));
    });

    testWidgets('the waiting state goes back to the Quiz tab', (tester) async {
      final server = _Server()
        ..failStart = freeLimit
        ..availability = 'cooldown'
        ..nextEligibleAt = 1790000000000 + 30 * 86400000;
      await _open(tester, server: server);

      await tester.tap(find.text('Back'));
      await advance(tester, 500);
      expect(find.text('Quiz tab'), findsOneWidget);
    });

    testWidgets('an exam with no mock yet shows "Mock paper not ready"',
        (tester) async {
      final server = _Server()
        ..failStart = const ServerMockException(
          code: 'failed-precondition',
          message: 'This exam has no mock yet.',
        )
        ..availability = 'no-blueprint';
      await _open(tester, server: server);

      expect(find.text('Mock paper not ready'), findsOneWidget);
      expect(find.text('Could not load your mock.'), findsNothing);
      expect(find.text('Try Again'), findsNothing);
      expect(server.telemetry.errors, isEmpty);
    });

    testWidgets(
        'too few questions, with the exam open and no limit, '
        'shows "Mock paper not ready"', (tester) async {
      final server = _Server()
        ..failStart = const ServerMockException(
          code: 'failed-precondition',
          message: 'There are not enough questions for this mock yet.',
        )
        ..availability = 'available';
      await _open(tester, server: server);

      expect(find.text('Mock paper not ready'), findsOneWidget);
      expect(find.text('Could not load your mock.'), findsNothing);
      expect(find.text('Try Again'), findsNothing);
    });

    testWidgets('a network failure still shows the error with Try Again',
        (tester) async {
      final server = _Server()
        ..failStart = const ServerMockException(code: 'unavailable');
      await _open(tester, server: server);

      expect(find.text('Could not load your mock.'), findsOneWidget);
      expect(server.named('getMockAvailability'), isEmpty);
      expect(server.telemetry.errors.single, isA<ServerMockException>());
      await tester.tap(find.text('Try Again'));
      await advance(tester, 100);
      expect(find.text('Question q1?'), findsOneWidget);
      expect(server.named('startMock'), hasLength(2));
    });

    testWidgets(
        'a refusal that cannot be explained keeps the error and hides raw text',
        (tester) async {
      final server = _Server()
        ..failStart = freeLimit
        ..failAvailability = const ServerMockException(code: 'unavailable');
      await _open(tester, server: server);

      expect(
        find.text('Free accounts can take one mock every 30 days.'),
        findsNothing,
      );
      expect(find.text('Could not load your mock.'), findsOneWidget);
      expect(
        (server.telemetry.errors.single as ServerMockException).message,
        'Free accounts can take one mock every 30 days.',
      );
      await tester.tap(find.text('Try Again'));
      await advance(tester, 100);
      expect(find.text('Question q1?'), findsOneWidget);
    });

    testWidgets('another refusal code keeps the error and offers Try Again',
        (tester) async {
      final server = _Server()
        ..failStart = const ServerMockException(
          code: 'resource-exhausted',
          message: 'Too many attempts. Try again later.',
        );
      await _open(tester, server: server);

      expect(find.text('Too many attempts. Try again later.'), findsNothing);
      expect(find.text('Could not load your mock.'), findsOneWidget);
      expect(server.named('getMockAvailability'), isEmpty);
    });
  });

  testWidgets('without a signed-in account nothing is called', (tester) async {
    final server = _Server();
    await _open(tester, server: server, uid: null);
    expect(server.calls, isEmpty);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('when time runs out the paper is submitted', (tester) async {
    final server = _Server()..remainingMs = 600;
    final fixture = await _open(tester, server: server);
    fixture.clock.now = const Duration(seconds: 2);
    await advance(tester, 2000);
    await advance(tester, 500);
    expect(server.named('submitMock').single.$2['reason'], 'student');
    expect(find.text('Server results $_mockId'), findsOneWidget);
  });

  testWidgets('a strict paper left for more than ten seconds is handed in',
      (tester) async {
    final server = _Server()..strict = true;
    await _open(tester, server: server, strict: true);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await advance(tester, 11000);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await advance(tester, 100);
    await advance(tester, 500);

    expect(server.named('submitMock').single.$2['reason'], 'strict-exit');
    final pauses = server.named('controlMock').where(
          (c) => c.$2['action'] == 'pause',
        );
    expect(pauses, isEmpty);
  });

  testWidgets('leaving a paper that is not strict pauses it on the server',
      (tester) async {
    final server = _Server();
    await _open(tester, server: server);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await advance(tester, 100);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await advance(tester, 100);
    expect(
      server.named('controlMock').map((c) => c.$2['action']),
      contains('pause'),
    );
    expect(find.byType(PausePage), findsOneWidget);
  });

  testWidgets('a different account ends the screen without publishing',
      (tester) async {
    final server = _Server();
    var uid = 'uid_a';
    await _open(tester, server: server, actor: () => uid);

    await tester.tap(find.text('Choice A'));
    uid = 'uid_b';
    await advance(tester, 1000);
    await advance(tester, 500);

    expect(server.named('controlMock'), isEmpty);
    expect(find.text('Quiz tab'), findsOneWidget);
  });

  group('the title of the paper', () {
    const custom = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';

    Future<void> wide(WidgetTester tester, _Server server) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _open(tester, server: server, examId: server.examId);
    }

    testWidgets('a custom paper is named after the exam, like the Quiz card',
        (tester) async {
      await wide(
        tester,
        _Server()
          ..examId = custom
          ..examName = 'PUP CET',
      );
      expect(find.text('PUP CET simulation'), findsOneWidget);
      expect(find.textContaining('exam_custom'), findsNothing);
    });

    testWidgets('a custom paper with no name sent says Mock exam',
        (tester) async {
      await wide(tester, _Server()..examId = custom);
      expect(find.text('Mock exam'), findsOneWidget);
      expect(find.textContaining('exam_custom'), findsNothing);
    });

    for (final (id, title) in [
      ('exam_cse_pro', 'CSE Professional simulation'),
      ('exam_cse_sub', 'CSE Subprofessional simulation'),
      ('exam_upcat', 'Mock exam'),
    ]) {
      testWidgets('a listed paper keeps its title: $id', (tester) async {
        await wide(tester, _Server()..examId = id);
        expect(find.text(title), findsOneWidget);
      });
    }
  });

  test('web opens the server screen and the phone keeps its own', () {
    expect(
      buildMockRunRoute(
        examId: 'e',
        blueprintId: 'b',
        strictMode: false,
        web: true,
      ),
      isA<ServerMockRoute>(),
    );
    expect(
      buildMockRunRoute(
        examId: 'e',
        blueprintId: 'b',
        strictMode: false,
        web: false,
      ),
      isA<MockStartRoute>(),
    );
  });
}
