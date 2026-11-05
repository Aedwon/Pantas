import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_leave_guard.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/server_mock_route.dart';
import 'package:pantas/features/mock_exam/presentation/part_transition_page.dart';
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

  // ---- a paper timed part by part: three parts of two questions ----
  bool byPart = false;
  int partIndex = 0;
  bool partWaiting = false;
  bool partEndedEarly = false;
  int partRemainingMs = 600000;
  int? startsInMs;
  int readFailures = 0;

  /// Holds the answer to startPart until the test lets it go.
  Completer<void>? holdStartPart;

  static const partNames = ['Mathematics', 'Reasoning', 'Science'];
  static const partIds = [
    ['q1', 'q2'],
    ['q3', 'q4'],
    ['q5', 'q6'],
  ];

  /// The server closed the running part and the next one waits.
  void closePart({bool early = false}) {
    partIndex += 1;
    partWaiting = true;
    partEndedEarly = early;
    partRemainingMs = 600000;
    startsInMs = strict ? 60000 : null;
  }

  /// A strict break ran out and the server started the part by itself.
  void startByItself() {
    partWaiting = false;
    startsInMs = null;
  }

  Map<String, Object?> partsView() => {
        'mockId': _mockId,
        'examId': examId,
        if (examName != null) 'examName': examName,
        'startedAt': 1790000000000,
        'strict': strict,
        'limitMs': 1800000,
        'remainingMs': partRemainingMs + 600000 * (2 - partIndex),
        'paused': paused,
        'paper': {
          'expectedQuestionCount': 6,
          'sections': [
            for (final (i, name) in partNames.indexed)
              {
                'sectionId': 's$i',
                'name': name,
                'questions': [
                  for (final id in partIds[i]) {'id': id, 'setId': ''},
                ],
              },
          ],
        },
        'answers': answers,
        'parts': {
          'index': partIndex,
          'limitsMs': [600000, 600000, 600000],
          'remainingMs': partRemainingMs,
          'waiting': partWaiting,
          'endedEarly': partEndedEarly,
          'startsInMs': startsInMs,
        },
      };

  Map<String, Object?> view() => byPart ? partsView() : listedView();

  Map<String, Object?> listedView() => {
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
        if (readFailures > 0) {
          readFailures -= 1;
          throw const ServerMockException(code: 'unavailable');
        }
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
            final sent = [
              for (final a in data['answers']! as List<Object?>)
                Map<String, Object?>.of(a! as Map<String, Object?>),
            ];
            if (!byPart) {
              answers = sent;
              break;
            }
            // Only the running part takes answers. A closed part keeps what
            // it has, and a later part has none.
            for (final a in sent) {
              final part = partIds.indexWhere(
                (ids) => ids.contains(a['questionId']),
              );
              if (partWaiting || part != partIndex) continue;
              answers = [
                for (final held in answers)
                  if (held['questionId'] != a['questionId']) held,
                a,
              ];
            }
          case 'startPart':
            await holdStartPart?.future;
            if (partWaiting) {
              partWaiting = false;
              startsInMs = null;
              partRemainingMs = 600000;
            }
          case 'endPart':
            closePart(early: true);
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
  List<String> questionIds = const ['q1', 'q2', 'q3'],
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
  for (final id in questionIds) {
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

  group('a paper timed part by part', () {
    const custom = 'exam_custom_6f1d0a52-3c1b-4c0e-8a52-0f6a3d2c9b11';
    const six = ['q1', 'q2', 'q3', 'q4', 'q5', 'q6'];

    void screen(WidgetTester tester, {required bool wide}) {
      debugWebPlatformOverride = wide ? true : null;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    _Server byPart({
      int index = 0,
      int remainingMs = 600000,
      bool strict = false,
      bool waiting = false,
      bool early = false,
      int? startsInMs,
    }) =>
        _Server()
          ..examId = custom
          ..examName = 'PUP CET'
          ..strict = strict
          ..byPart = true
          ..partIndex = index
          ..partRemainingMs = remainingMs
          ..partWaiting = waiting
          ..partEndedEarly = early
          ..startsInMs = startsInMs;

    Future<_Fixture> open(
      WidgetTester tester,
      _Server server, {
      bool resume = false,
    }) =>
        _open(
          tester,
          server: server,
          examId: custom,
          strict: server.strict,
          questionIds: six,
          resume: resume,
        );

    Future<void> next(WidgetTester tester, {required bool wide}) async {
      await tester.tap(
        wide
            ? find.byType(WebBarArrow).last
            : find.byKey(const ValueKey('mock-next')),
      );
      await advance(tester, 500);
    }

    Future<void> previous(WidgetTester tester, {required bool wide}) async {
      await tester.tap(
        wide
            ? find.byType(WebBarArrow).first
            : find.byKey(const ValueKey('mock-prev')),
      );
      await advance(tester, 500);
    }

    /// Time passes on the display clock and on the screen together.
    Future<void> elapse(
      WidgetTester tester,
      _Fixture fixture,
      Duration time,
    ) async {
      for (var spent = 0; spent < time.inMilliseconds; spent += 50) {
        fixture.clock.now += const Duration(milliseconds: 50);
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    for (final wide in [true, false]) {
      final name = wide ? 'wide' : 'phone';

      group('on the $name paper', () {
        testWidgets('the running part is the whole paper: clock, count, grid',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(index: 1, remainingMs: 450000);
          await open(tester, server);

          expect(find.text('07:30'), findsOneWidget);
          expect(find.text('17:30'), findsNothing);
          expect(find.text('Question q3?'), findsOneWidget);
          expect(find.text('1 of 2'), findsOneWidget);
          if (wide) {
            expect(find.text('left in Part 2'), findsOneWidget);
            // The panel and the question both name the part.
            expect(find.text('PART 2 · REASONING'), findsNWidgets(2));
            expect(find.text('0 of 2'), findsOneWidget);
            expect(find.text('PART 3 · SCIENCE'), findsOneWidget);
            expect(find.text('Opens when this part starts.'), findsOneWidget);
            // A closed part is not shown.
            expect(find.textContaining('PART 1'), findsNothing);
            expect(find.textContaining('Part 1'), findsNothing);
            expect(find.text('WHOLE PAPER'), findsNothing);
          } else {
            // The part is under the clock, not above the question.
            expect(find.text('Part 2 · Reasoning'), findsOneWidget);
            expect(find.text('PART 2 · REASONING'), findsNothing);
            await tester.tap(find.byKey(const ValueKey('mock-grid')));
            await advance(tester, 500);
            expect(find.text('Part 1 is closed'), findsOneWidget);
            expect(find.text('PART 3 · SCIENCE'), findsOneWidget);
            expect(find.text('Opens when this part starts.'), findsOneWidget);
          }
          expect(server.calls.map((c) => c.$1), ['startMock']);
        });

        testWidgets('moving stays inside the running part', (tester) async {
          screen(tester, wide: wide);
          final server = byPart(index: 1, remainingMs: 450000);
          await open(tester, server);
          await previous(tester, wide: wide);
          expect(find.text('Question q3?'), findsOneWidget);
          await next(tester, wide: wide);
          expect(find.text('Question q4?'), findsOneWidget);
          expect(find.text('2 of 2'), findsOneWidget);
          expect(server.calls.map((c) => c.$1), ['startMock']);
        });

        testWidgets('a paper without the block stays one block',
            (tester) async {
          screen(tester, wide: wide);
          final server = _Server();
          await _open(tester, server: server);
          expect(find.textContaining('left in Part'), findsNothing);
          expect(
            find.textContaining('Opens when this part starts'),
            findsNothing,
          );
          if (wide) expect(find.text('WHOLE PAPER'), findsOneWidget);
          expect(find.text('1 of 3'), findsOneWidget);
        });

        testWidgets('between parts, the screen waits for the student',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(index: 1, waiting: true)
            ..answers = [
              {
                'questionId': 'q1',
                'chosen': 'q1_a',
                'correct': true,
                'answeredAt': 1790000100000,
              },
            ];
          final fixture = await open(tester, server);
          await advance(tester, 300);

          expect(find.byType(PartTransitionPage), findsOneWidget);
          expect(find.text('Time is up.'), findsOneWidget);
          expect(find.text('Part 1 · Mathematics'), findsWidgets);
          expect(
            find.text(wide ? 'Part 3 · Science' : 'Science'),
            findsOneWidget,
          );
          expect(find.text('Start Part 2'), findsOneWidget);
          if (wide) {
            expect(find.text('1 answered · 1 blank'), findsOneWidget);
            expect(
              find.text('The clock starts when you click.'),
              findsOneWidget,
            );
          } else {
            expect(find.text('1 answered'), findsOneWidget);
            expect(find.text('1 blank'), findsOneWidget);
            expect(
              find.text('The clock starts when you tap.'),
              findsOneWidget,
            );
          }
          // The clock is stopped while it waits.
          fixture.clock.now += const Duration(minutes: 30);
          await advance(tester, 500);
          expect(server.calls.map((c) => c.$1), ['startMock']);

          await tester.tap(find.text('Start Part 2'));
          await advance(tester, 500);
          expect(server.named('controlMock').single.$2['action'], 'startPart');
          expect(find.byType(PartTransitionPage), findsNothing);
          expect(find.text('Question q3?'), findsOneWidget);
          expect(find.text('10:00'), findsOneWidget);
        });

        testWidgets('a part the student closed says so', (tester) async {
          screen(tester, wide: wide);
          await open(tester, byPart(index: 1, waiting: true, early: true));
          await advance(tester, 300);
          expect(find.text('Part 1 ended.'), findsOneWidget);
          expect(find.text('Time is up.'), findsNothing);
        });

        testWidgets('a second tap while the start is on its way sends nothing',
            (tester) async {
          screen(tester, wide: wide);
          final hold = Completer<void>();
          final server = byPart(index: 1, waiting: true)..holdStartPart = hold;
          await open(tester, server);
          await advance(tester, 300);
          await tester.tap(find.text('Start Part 2'));
          await advance(tester, 100);
          await tester.tap(find.text('Start Part 2'), warnIfMissed: false);
          if (wide) {
            await tester.sendKeyEvent(LogicalKeyboardKey.enter);
          }
          await advance(tester, 100);
          expect(server.named('controlMock'), hasLength(1));
          hold.complete();
          await advance(tester, 500);
          expect(server.named('controlMock'), hasLength(1));
          expect(find.text('Question q3?'), findsOneWidget);
        });

        testWidgets('a strict break shows its clock and no hint',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(
            index: 1,
            waiting: true,
            strict: true,
            startsInMs: 42000,
          );
          await open(tester, server);
          await advance(tester, 300);

          expect(find.byType(PartTransitionPage), findsOneWidget);
          expect(find.text('0:42'), findsOneWidget);
          expect(find.text('until Part 2 starts'), findsOneWidget);
          expect(find.textContaining('The clock starts when'), findsNothing);
          expect(find.text('Start Part 2'), findsOneWidget);
          if (wide) {
            expect(find.text('PUP CET simulation'), findsOneWidget);
            expect(find.text('Part 1 of 3 · Mathematics'), findsOneWidget);
          }
        });

        testWidgets('the break runs out: the part started and the note shows',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(
            index: 1,
            waiting: true,
            strict: true,
            startsInMs: 3000,
          );
          final fixture = await open(tester, server);
          await advance(tester, 300);

          // The server starts the part on its own clock.
          server
            ..startByItself()
            ..partRemainingMs = 599000;
          await elapse(tester, fixture, const Duration(milliseconds: 3500));
          await advance(tester, 300);

          expect(server.named('getMockPaper'), hasLength(1));
          expect(server.named('submitMock'), isEmpty);
          expect(find.byType(PartTransitionPage), findsNothing);
          expect(find.text('Part 2 started'), findsOneWidget);
          expect(find.text('Question q3?'), findsOneWidget);
          if (wide) {
            expect(find.text('Part 2 of 3 · Reasoning'), findsOneWidget);
            // The other parts, done or still to open, as a list.
            expect(find.text('Part 1 · Mathematics'), findsOneWidget);
            expect(find.text('Part 3 · Science'), findsOneWidget);
            expect(find.text('Opens when this part starts.'), findsOneWidget);
            expect(find.text('Pause'), findsNothing);
            expect(find.text('left in Part 2'), findsNothing);
          } else {
            expect(find.text('PART 2 · REASONING'), findsOneWidget);
          }

          // The first answer ends it.
          await tester.tap(find.text('Choice A'));
          await advance(tester, 100);
          expect(find.text('Part 2 started'), findsNothing);
          if (wide) {
            expect(find.text('left in Part 2'), findsOneWidget);
            expect(find.text('Part 2 of 3 · Reasoning'), findsNothing);
          } else {
            expect(find.text('Part 2 · Reasoning'), findsOneWidget);
            expect(find.text('PART 2 · REASONING'), findsNothing);
          }
        });

        testWidgets('the note ends after fifteen seconds', (tester) async {
          screen(tester, wide: wide);
          final server = byPart(
            index: 1,
            waiting: true,
            strict: true,
            startsInMs: 1000,
          );
          final fixture = await open(tester, server);
          server
            ..startByItself()
            ..partRemainingMs = 599000;
          await elapse(tester, fixture, const Duration(seconds: 2));
          await advance(tester, 300);
          expect(find.text('Part 2 started'), findsOneWidget);
          await elapse(tester, fixture, const Duration(seconds: 14));
          expect(find.text('Part 2 started'), findsOneWidget);
          await elapse(tester, fixture, const Duration(seconds: 2));
          expect(find.text('Part 2 started'), findsNothing);
        });

        testWidgets('a start the student asked for never shows the note',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(
            index: 1,
            waiting: true,
            strict: true,
            startsInMs: 40000,
          );
          await open(tester, server);
          await advance(tester, 300);
          await tester.tap(find.text('Start Part 2'));
          await advance(tester, 500);
          expect(find.text('Question q3?'), findsOneWidget);
          expect(find.text('Part 2 started'), findsNothing);
        });

        testWidgets('pause shows the part clock', (tester) async {
          screen(tester, wide: wide);
          final server = byPart(index: 1, remainingMs: 450000);
          await open(tester, server);
          if (wide) {
            await tester.tap(find.text('Pause'));
          } else {
            await tester.tap(find.byKey(const ValueKey('mock-pause')));
          }
          await advance(tester, 3500);
          expect(find.byType(PausePage), findsOneWidget);
          expect(find.text('07:30'), findsWidgets);
          expect(find.text('left in this part'), findsOneWidget);
          expect(find.text('17:30'), findsNothing);
        });

        testWidgets('ending a part sends endPart after the answers',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(remainingMs: 450000);
          await open(tester, server);
          await tester.tap(find.text('Choice A'));
          await next(tester, wide: wide);
          await next(tester, wide: wide);
          expect(find.text('End Part 1 now?'), findsOneWidget);
          await tester.tap(find.text('End Part 1'));
          await advance(tester, 500);

          expect(
            server.named('controlMock').map((c) => c.$2['action']),
            ['save', 'endPart'],
          );
          expect(find.byType(PartTransitionPage), findsOneWidget);
          expect(find.text('Part 1 ended.'), findsOneWidget);
          expect(
            find.text(wide ? '1 answered · 1 blank' : '1 blank'),
            findsOneWidget,
          );
        });

        testWidgets('a strict paper never ends a part', (tester) async {
          screen(tester, wide: wide);
          final server = byPart(strict: true, remainingMs: 450000);
          await open(tester, server);
          await next(tester, wide: wide);
          await next(tester, wide: wide);
          expect(find.textContaining('End Part'), findsNothing);
          expect(server.named('controlMock'), isEmpty);
          expect(
            find.text('Part 1 runs to the end of its time. Strict mode is on.'),
            findsOneWidget,
          );
        });

        testWidgets('the last part is submitted, not ended', (tester) async {
          screen(tester, wide: wide);
          final server = byPart(index: 2, remainingMs: 300000);
          await open(tester, server);
          await next(tester, wide: wide);
          await next(tester, wide: wide);
          expect(find.text('End Part 3 now?'), findsOneWidget);
          await tester.tap(find.text('End Part 3'));
          await advance(tester, 700);

          expect(server.named('submitMock').single.$2['reason'], 'student');
          expect(
            server.named('controlMock').map((c) => c.$2['action']),
            isNot(contains('endPart')),
          );
          final input = GoRouterState.of(
            tester.element(find.text('Server results $_mockId')),
          ).extra! as MockFinaleInput;
          // The finale draws the real parts.
          expect(
            input.parts.map((part) => part.name),
            ['Mathematics', 'Reasoning', 'Science'],
          );
          expect(input.currentPartIndex, 2);
          expect(input.currentQuestionIndex, 1);
          expect(
            input.parts.map((part) => part.questions.length),
            [2, 2, 2],
          );
        });

        testWidgets('a clock at zero asks the server and does not submit',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(remainingMs: 600);
          final fixture = await open(tester, server);
          await tester.tap(find.text('Choice A'));
          await advance(tester, 100);
          // The answer went out at once, since the part was about to close.
          expect(
            server.named('controlMock').map((c) => c.$2['action']),
            ['save'],
          );
          // The server closes the part on time while the screen counts down.
          server.closePart();
          await elapse(tester, fixture, const Duration(seconds: 2));
          await advance(tester, 500);

          expect(server.named('getMockPaper'), hasLength(1));
          expect(server.named('submitMock'), isEmpty);
          expect(find.byType(PartTransitionPage), findsOneWidget);
          expect(find.text('Time is up.'), findsOneWidget);
          expect(
            find.text(wide ? '1 answered · 1 blank' : '1 answered'),
            findsOneWidget,
          );
        });

        testWidgets('a read that fails is tried again, never in a loop',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(remainingMs: 600)..readFailures = 2;
          final fixture = await open(tester, server);
          server.closePart();
          await elapse(tester, fixture, const Duration(seconds: 1));
          expect(server.named('getMockPaper'), hasLength(1));
          expect(find.text('Could not save your progress.'), findsOneWidget);
          expect(find.text('Try Again'), findsOneWidget);
          // The clock stays at zero.
          expect(find.text('00:00'), findsOneWidget);
          await elapse(tester, fixture, const Duration(milliseconds: 500));
          expect(server.named('getMockPaper'), hasLength(1));
          await elapse(tester, fixture, const Duration(milliseconds: 1500));
          expect(server.named('getMockPaper'), hasLength(2));
          await elapse(tester, fixture, const Duration(seconds: 3));
          await advance(tester, 300);
          expect(server.named('getMockPaper'), hasLength(3));
          expect(find.text('Could not save your progress.'), findsNothing);
          expect(find.byType(PartTransitionPage), findsOneWidget);
          expect(server.named('submitMock'), isEmpty);
        });

        testWidgets('Try Again asks the server at once', (tester) async {
          screen(tester, wide: wide);
          final server = byPart(remainingMs: 600)..readFailures = 1;
          final fixture = await open(tester, server);
          server.closePart();
          await elapse(tester, fixture, const Duration(seconds: 1));
          expect(find.text('Try Again'), findsOneWidget);
          await tester.tap(find.text('Try Again'));
          await advance(tester, 300);
          expect(server.named('getMockPaper'), hasLength(2));
          expect(find.byType(PartTransitionPage), findsOneWidget);
        });

        testWidgets('a mock the server finished goes to its results',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(index: 2, remainingMs: 600);
          final fixture = await open(tester, server);
          server.completed = true;
          await elapse(tester, fixture, const Duration(seconds: 2));
          await advance(tester, 700);

          expect(server.named('getMockPaper'), hasLength(1));
          expect(server.named('submitMock'), isEmpty);
          final input = GoRouterState.of(
            tester.element(find.text('Server results $_mockId')),
          ).extra! as MockFinaleInput;
          expect(input.reason, MockSubmitReason.timeUp);
          expect(input.parts, hasLength(3));
        });

        testWidgets('a reload lands on the state the server holds',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(index: 2, waiting: true, early: true)
            ..resumed = true;
          await open(tester, server, resume: true);
          await advance(tester, 300);
          expect(server.named('getMockPaper'), hasLength(1));
          expect(find.byType(PartTransitionPage), findsOneWidget);
          expect(find.text('Part 2 ended.'), findsOneWidget);
          expect(find.text('Start Part 3'), findsOneWidget);
        });

        testWidgets('strict mode still hands in a paper left on a break',
            (tester) async {
          screen(tester, wide: wide);
          final server = byPart(
            index: 1,
            waiting: true,
            strict: true,
            startsInMs: 60000,
          );
          await open(tester, server);
          await advance(tester, 300);
          tester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.paused);
          await advance(tester, 11000);
          tester.binding
              .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
          await advance(tester, 700);
          expect(server.named('submitMock').single.$2['reason'], 'strict-exit');
          expect(
            server.named('submitMock').single.$2['answers']! as List<Object?>,
            hasLength(6),
          );
        });
      });
    }
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
