import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_start_route.dart';
import 'package:pantas/features/mock_exam/presentation/pages/server_mock_route.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';

import '../../../helpers/in_memory_database.dart';

const _mockId = 'abcdefghij1';

class _Server {
  String examId = 'exam_cse_pro';
  bool strict = false;
  int remainingMs = 8000000;
  bool paused = false;
  bool resumed = false;
  List<Map<String, Object?>> answers = [];
  final calls = <(String, Map<String, Object?>)>[];
  Exception? failStart;
  Completer<void>? holdStart;

  Map<String, Object?> view() => {
        'mockId': _mockId,
        'examId': examId,
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
        return {...view(), 'resumed': resumed};
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
    initialLocation: '/mock',
    routes: [
      GoRoute(
        path: '/quiz',
        builder: (_, __) => const Scaffold(body: Text('Quiz tab')),
      ),
      GoRoute(
        path: '/mock',
        builder: (_, __) => ServerMockRoute(examId: examId, strictMode: strict),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(content),
        serverMockApiProvider.overrideWithValue(ServerMockApi(server.call)),
        serverMockActorProvider.overrideWithValue(() => fixture.actor()),
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
  return _Fixture(server, router, fixture.actor, clock);
}

/// Time passes in small steps so every async step in between can finish.
Future<void> advance(WidgetTester tester, int milliseconds) async {
  for (var spent = 0; spent < milliseconds; spent += 50) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
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

  testWidgets('submitting from the grid sends the paper and returns to Quiz',
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
    expect(find.text('Quiz tab'), findsOneWidget);
    expect(fixture.router.canPop(), isFalse);
  });

  testWidgets('a refusal from the server is shown with Retry', (tester) async {
    final server = _Server()
      ..failStart = const ServerMockException(
        code: 'failed-precondition',
        message: 'Free accounts can take one mock every 30 days.',
      );
    await _open(tester, server: server);

    expect(
      find.text('Free accounts can take one mock every 30 days.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try Again'));
    await advance(tester, 100);
    expect(find.text('Question q1?'), findsOneWidget);
    expect(server.named('startMock'), hasLength(2));
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
    expect(find.text('Quiz tab'), findsOneWidget);
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
