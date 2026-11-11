import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/application/server_mock_session.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';

const _mockId = 'abcdefghij1';

/// A server that holds the state a real one would and can stall a call.
class _Server {
  int limitMs = 9000000;
  int remainingMs = 8000000;
  bool paused = false;
  bool strict = false;
  List<Map<String, Object?>> answers = [];
  final calls = <(String, Map<String, Object?>)>[];
  final stalled = <Completer<void>>[];
  Exception? failNext;
  bool stallNext = false;

  Map<String, Object?> view() => {
        'mockId': _mockId,
        'examId': 'exam_cse_pro',
        'startedAt': 1790000000000,
        'strict': strict,
        'limitMs': limitMs,
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
    if (stallNext) {
      stallNext = false;
      final gate = Completer<void>();
      stalled.add(gate);
      await gate.future;
    }
    final failure = failNext;
    if (failure != null) {
      failNext = null;
      throw failure;
    }
    switch (name) {
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
            remainingMs = limitMs;
            paused = false;
        }
        return view();
      case 'submitMock':
        return {'mockId': _mockId, 'status': 'submitted'};
    }
    throw StateError('unexpected $name');
  }

  Iterable<Map<String, Object?>> get saves => calls
      .where((c) => c.$1 == 'controlMock' && c.$2['action'] == 'save')
      .map((c) => c.$2);
}

/// A server whose paper has three parts, timed one by one. A test moves the
/// server's own state to say what happened while the student was away, and
/// the session is expected to adopt it.
class _PartServer {
  _PartServer({this.strict = false});

  static const limits = [600000, 600000, 600000];
  static const names = ['Mathematics', 'Reasoning', 'Science'];
  static const ids = [
    ['q1', 'q2'],
    ['q3', 'q4'],
    ['q5', 'q6'],
  ];

  final bool strict;
  int index = 0;
  bool waiting = false;
  bool endedEarly = false;
  int remainingMs = 600000;
  int? startsInMs;
  bool paused = false;
  bool finished = false;
  List<Map<String, Object?>> answers = [];
  final calls = <(String, Map<String, Object?>)>[];
  int readFailures = 0;
  final stalled = <Completer<void>>[];
  bool stallNext = false;

  int partOf(String id) => ids.indexWhere((part) => part.contains(id));

  Map<String, Object?> view() => {
        'mockId': _mockId,
        'examId': 'exam_custom_6f1d0a52',
        'examName': 'PUP CET',
        'startedAt': 1790000000000,
        'strict': strict,
        'limitMs': 1800000,
        'remainingMs': remainingMs + 600000 * (2 - index),
        'paused': paused,
        'paper': {
          'expectedQuestionCount': 6,
          'sections': [
            for (final (i, name) in names.indexed)
              {
                'sectionId': 's$i',
                'name': name,
                'questions': [
                  for (final id in ids[i]) {'id': id, 'setId': ''},
                ],
              },
          ],
        },
        'answers': answers,
        'parts': {
          'index': index,
          'limitsMs': [...limits],
          'remainingMs': remainingMs,
          'waiting': waiting,
          'endedEarly': endedEarly,
          'startsInMs': startsInMs,
        },
      };

  /// The server closed the running part and the next one waits.
  void closePart({bool early = false}) {
    index += 1;
    waiting = true;
    endedEarly = early;
    remainingMs = limits[index];
    startsInMs = strict ? 60000 : null;
  }

  /// A strict break ran out and the server started the part by itself.
  void startByItself({int usedMs = 0}) {
    waiting = false;
    startsInMs = null;
    remainingMs = limits[index] - usedMs;
  }

  Future<Object?> call(String name, Map<String, Object?> data) async {
    calls.add((name, Map.of(data)));
    if (stallNext) {
      stallNext = false;
      final gate = Completer<void>();
      stalled.add(gate);
      await gate.future;
    }
    switch (name) {
      case 'getMockPaper':
        if (readFailures > 0) {
          readFailures -= 1;
          throw const ServerMockException(code: 'unavailable');
        }
        if (finished) {
          return {
            'open': false,
            'ended': {
              'mockId': _mockId,
              'endedBy': 'time-out',
              'submittedAt': 1790001800000,
              'score': {'correct': 1, 'answered': 2, 'wrong': 1, 'total': 6},
            },
          };
        }
        return {'open': true, ...view()};
      case 'controlMock':
        switch (data['action']) {
          case 'save':
            final sent = [
              for (final a in data['answers']! as List<Object?>)
                Map<String, Object?>.of(a! as Map<String, Object?>),
            ];
            answers = [
              ...answers,
            ];
            for (final a in sent) {
              if (waiting || partOf(a['questionId']! as String) != index) {
                continue;
              }
              answers = [
                for (final held in answers)
                  if (held['questionId'] != a['questionId']) held,
                a,
              ];
            }
          case 'pause':
            if (!waiting) paused = true;
          case 'resume':
            paused = false;
          case 'discard':
            answers = [];
            index = 0;
            waiting = false;
            endedEarly = false;
            remainingMs = limits[0];
            startsInMs = null;
            paused = false;
          case 'startPart':
            if (waiting) {
              waiting = false;
              startsInMs = null;
              remainingMs = limits[index];
            }
          case 'endPart':
            closePart(early: true);
        }
        return view();
      case 'submitMock':
        return {'mockId': _mockId, 'status': 'submitted'};
    }
    throw StateError('unexpected $name');
  }

  Iterable<String> get actions => calls
      .where((c) => c.$1 == 'controlMock')
      .map((c) => c.$2['action']! as String);

  Iterable<(String, Map<String, Object?>)> named(String name) =>
      calls.where((c) => c.$1 == name);
}

class _Clock {
  Duration now = Duration.zero;
  Duration call() => now;
}

class _Store implements ServerMockViewStore {
  final writes = <(String, String, int, Set<String>)>[];
  @override
  Future<void> write({
    required String uid,
    required String mockId,
    required int cursor,
    required Set<String> flags,
  }) async =>
      writes.add((uid, mockId, cursor, flags));
}

void main() {
  late _Server server;
  late _Clock clock;
  late String? actor;
  late _Store store;
  late ServerMockSession session;
  var notifications = 0;
  final disposedSessions = <ServerMockSession>{};

  ServerMockSession open({
    Map<String, Object?>? view,
    Map<String, int> restored = const {},
  }) {
    final opened = ServerMockSession(
      api: ServerMockApi(server.call),
      paper: ServerMockPaper.decode(view ?? server.view()),
      uid: 'uid_a',
      currentUid: () => actor,
      elapsed: clock.call,
      restoredIndexes: restored,
      viewStore: store,
      saveDelay: const Duration(milliseconds: 5),
    )..addListener(() => notifications++);
    addTearDown(() {
      if (!disposedSessions.contains(opened)) opened.dispose();
    });
    return opened;
  }

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 30));

  setUp(() {
    server = _Server();
    clock = _Clock();
    actor = 'uid_a';
    store = _Store();
    notifications = 0;
    session = open();
  });

  group('the clock', () {
    test('counts down from the server value without calling the server', () {
      expect(session.remaining, const Duration(milliseconds: 8000000));
      clock.now = const Duration(seconds: 90);
      expect(session.remaining, const Duration(milliseconds: 7910000));
      expect(server.calls, isEmpty);
    });

    test('never goes below zero and says when time is up', () {
      clock.now = const Duration(hours: 5);
      expect(session.remaining, Duration.zero);
      expect(session.timeIsUp, isTrue);
    });

    test('stands still while the server says it is paused', () {
      final paused = open(view: {...server.view(), 'paused': true});
      clock.now = const Duration(minutes: 10);
      expect(paused.remaining, const Duration(milliseconds: 8000000));
    });

    test('each response replaces the clock', () async {
      clock.now = const Duration(seconds: 60);
      server.remainingMs = 7000000;
      expect(await session.pause(), isTrue);
      expect(session.paused, isTrue);
      clock.now = const Duration(minutes: 30);
      expect(session.remaining, const Duration(milliseconds: 7000000));
    });
  });

  group('saving', () {
    test('answers are saved together, once, after a pause in answering',
        () async {
      session
        ..answer('q1', chosen: 'a', selectedIndex: 0, correct: true)
        ..answer('q2', chosen: 'b', selectedIndex: 1, correct: false);
      expect(server.calls, isEmpty);
      await settle();
      expect(server.saves, hasLength(1));
      final saved = server.saves.single['answers']! as List<Object?>;
      expect(saved, hasLength(2));
      expect((saved.first! as Map)['questionId'], 'q1');
      expect((saved.first! as Map)['chosen'], 'a');
    });

    test('an 87-character choice id is kept, saved and scored', () async {
      final long = 'q1_${'c' * 84}';
      expect(long.length, 87);
      session.answer('q1', chosen: long, selectedIndex: 2, correct: true);
      expect(session.answers['q1']!.chosen, long);
      expect(session.answers['q1']!.correct, isTrue);
      await settle();
      final saved = server.saves.single['answers']! as List<Object?>;
      expect((saved.single! as Map)['chosen'], long);
      expect((saved.single! as Map)['correct'], isTrue);
    });

    test('a choice id past the server limit of 130 is refused', () async {
      session.answer('q1', chosen: 'c' * 131, selectedIndex: 0, correct: true);
      expect(session.answers, isEmpty);
      session.answer('q1', chosen: 'c' * 130, selectedIndex: 0, correct: true);
      expect(session.answers['q1']!.chosen, 'c' * 130);
    });

    test('nothing is saved when nothing is answered', () async {
      await session.flush();
      expect(server.calls, isEmpty);
    });

    test('answered time follows the server clock, never the device clock',
        () async {
      clock.now = const Duration(seconds: 30);
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await settle();
      final saved = server.saves.single['answers']! as List<Object?>;
      expect(
        (saved.single! as Map)['answeredAt'],
        1790000000000 + 1000000 + 30000,
      );
    });

    test('a slow earlier save cannot replace or follow a newer one', () async {
      server.stallNext = true;
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await settle();
      expect(server.calls, hasLength(1));

      session.answer('q2', chosen: 'b', selectedIndex: 1, correct: false);
      await settle();
      // The second save waits for the first to be acknowledged.
      expect(server.calls, hasLength(1));
      expect(session.answers.keys, containsAll(['q1', 'q2']));

      server.stalled.single.complete();
      await settle();
      expect(server.saves, hasLength(2));
      expect(server.saves.last['answers']! as List<Object?>, hasLength(2));
      expect(session.answers['q2']!.chosen, 'b');
    });

    test('later answers supersede a save that has not started', () async {
      server.stallNext = true;
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await settle();
      session.answer('q2', chosen: 'b', selectedIndex: 1, correct: false);
      await settle();
      session.answer('q3', chosen: 'c', selectedIndex: 2, correct: false);
      await settle();
      server.stalled.single.complete();
      await settle();
      // First save, then one save with all three; the middle one was dropped.
      expect(server.saves, hasLength(2));
      expect(server.saves.last['answers']! as List<Object?>, hasLength(3));
    });

    test('the clock ticking never reaches the server', () async {
      for (var i = 0; i < 100; i++) {
        clock.now = Duration(seconds: i);
        expect(session.remaining, isNotNull);
      }
      await settle();
      expect(server.calls, isEmpty);
    });

    test('a refused save is kept for Retry with its first payload', () async {
      server.failNext = const ServerMockException(code: 'unavailable');
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await settle();
      expect(session.failure?.operation, ServerMockOperation.save);
      final first = server.saves.single['answers'];

      // The student carries on; the failed payload is still what Retry sends.
      expect(await session.retry(), isTrue);
      expect(server.saves, hasLength(2));
      expect(server.saves.last['answers'], first);
      expect(session.failure, isNull);
    });

    test('a newer successful save makes an older failure moot', () async {
      server.failNext = const ServerMockException(code: 'unavailable');
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await settle();
      expect(session.failure, isNotNull);

      session.answer('q2', chosen: 'b', selectedIndex: 1, correct: false);
      await settle();
      expect(session.failure, isNull);
      expect(server.saves, hasLength(2));
      expect(await session.retry(), isFalse);
      expect(server.saves, hasLength(2));
    });
  });

  group('pause, resume and discard', () {
    test('pause stops the display clock at once and the server confirms',
        () async {
      clock.now = const Duration(seconds: 20);
      final pausing = session.pause();
      clock.now = const Duration(minutes: 5);
      expect(session.remaining, const Duration(milliseconds: 7980000));
      expect(await pausing, isTrue);
      expect(session.paused, isTrue);
    });

    test('a refused pause brings the clock back', () async {
      server.failNext = const ServerMockException(code: 'unavailable');
      clock.now = const Duration(seconds: 20);
      expect(await session.pause(), isFalse);
      expect(session.paused, isFalse);
      clock.now = const Duration(seconds: 50);
      expect(session.remaining, const Duration(milliseconds: 7950000));
      expect(session.failure?.operation, ServerMockOperation.pause);

      expect(await session.retry(), isTrue);
      final pauses = server.calls.where((c) => c.$2['action'] == 'pause');
      expect(pauses, hasLength(2));
    });

    test('resume starts the server clock again', () async {
      await session.pause();
      server.remainingMs = 7000000;
      expect(await session.resume(), isTrue);
      expect(session.paused, isFalse);
      clock.now = const Duration(seconds: 10);
      expect(session.remaining, const Duration(milliseconds: 6990000));
    });

    test('a strict mock never asks for a pause, resume or discard', () async {
      server.strict = true;
      final strict = open();
      expect(await strict.pause(), isFalse);
      expect(await strict.discard(), isFalse);
      expect(server.calls, isEmpty);
    });

    test('discard keeps the same paper and drops every answer', () async {
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await session.flush();
      session.toggleFlag('q2');
      expect(await session.discard(), isTrue);
      expect(session.mockId, _mockId);
      expect(session.paper.questionIds, ['q1', 'q2', 'q3']);
      expect(session.answers, isEmpty);
      expect(session.flags, isEmpty);
      expect(session.cursor, 0);
    });

    test('no answer is taken while a pause is on', () async {
      await session.pause();
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      expect(session.answers, isEmpty);
    });
  });

  group('submitting', () {
    test('sends every pinned question, blanks included, and closes', () async {
      clock.now = const Duration(seconds: 100);
      session.answer('q2', chosen: 'b', selectedIndex: 1, correct: true);
      expect(await session.submit(ServerMockEndReason.student), isTrue);

      final submit = server.calls.last;
      expect(submit.$1, 'submitMock');
      expect(submit.$2['reason'], 'student');
      expect(submit.$2['durationMs'], 1000000 + 100000);
      final sent = submit.$2['answers']! as List<Object?>;
      expect(sent.map((a) => (a! as Map)['questionId']), ['q1', 'q2', 'q3']);
      expect((sent[0]! as Map)['chosen'], isNull);
      expect((sent[1]! as Map)['chosen'], 'b');
      expect(session.submitted, isTrue);
    });

    test('an unsaved answer is not lost, it travels with the submission',
        () async {
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await session.submit(ServerMockEndReason.student);
      expect(server.saves, isEmpty);
      final sent = server.calls.last.$2['answers']! as List<Object?>;
      expect((sent.first! as Map)['chosen'], 'a');
    });

    test('nothing is accepted after the submission is acknowledged', () async {
      await session.submit(ServerMockEndReason.student);
      final calls = server.calls.length;
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      expect(await session.pause(), isFalse);
      expect(await session.submit(ServerMockEndReason.student), isFalse);
      await settle();
      expect(server.calls, hasLength(calls));
    });

    test('a save still in flight cannot land after the submission', () async {
      server.stallNext = true;
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await settle();
      final submitting = session.submit(ServerMockEndReason.student);
      server.stalled.single.complete();
      expect(await submitting, isTrue);
      expect(server.calls.map((c) => c.$1), ['controlMock', 'submitMock']);
    });

    test('a strict exit preserves answered questions and real blanks',
        () async {
      server.strict = true;
      final strict = open()
        ..answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      expect(await strict.submit(ServerMockEndReason.strictExit), isTrue);
      final sent = server.calls.last.$2;
      expect(sent['reason'], 'strict-exit');
      final answers = sent['answers']! as List<Object?>;
      expect(answers, hasLength(3));
      expect((answers.first! as Map)['chosen'], 'a');
      expect((answers.first! as Map)['correct'], isTrue);
      expect((answers[1]! as Map)['chosen'], isNull);
    });

    test('submission freezes edits and does not enqueue another submission',
        () async {
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      server.stallNext = true;
      final submitting = session.submit(ServerMockEndReason.student);
      session.answer('q2', chosen: 'b', selectedIndex: 1, correct: true);
      expect(session.answers.containsKey('q2'), isFalse);
      final repeated = session.submit(ServerMockEndReason.student);
      server.stalled.single.complete();
      expect(await submitting, isTrue);
      expect(await repeated, isFalse);
      expect(server.calls.where((c) => c.$1 == 'submitMock'), hasLength(1));
    });

    test('a refused submission keeps its payload for Retry', () async {
      server.failNext = const ServerMockException(code: 'unavailable');
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      expect(await session.submit(ServerMockEndReason.student), isFalse);
      expect(session.submitted, isFalse);
      expect(session.failure?.operation, ServerMockOperation.submit);
      final first = server.calls.last.$2['answers'];

      session.answer('q2', chosen: 'b', selectedIndex: 1, correct: true);
      expect(await session.retry(), isTrue);
      expect(server.calls.last.$2['answers'], first);
      expect(session.submitted, isTrue);
    });

    test('an expired paper can still be submitted', () async {
      server.remainingMs = 0;
      final expired = open();
      expect(expired.timeIsUp, isTrue);
      expect(await expired.submit(ServerMockEndReason.student), isTrue);
    });
  });

  group('who owns it', () {
    test('an account change blocks local edits before the next server call',
        () async {
      actor = 'uid_b';
      session
        ..answer('q1', chosen: 'a', selectedIndex: 0, correct: true)
        ..goTo(2)
        ..toggleFlag('q1');
      expect(session.answers, isEmpty);
      expect(session.cursor, 0);
      expect(session.flags, isEmpty);
      expect(session.stale, isTrue);
      actor = 'uid_a';
      expect(session.stale, isTrue);
      await settle();
      expect(server.calls, isEmpty);
    });

    test('work queued under another account is never sent', () async {
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      actor = 'uid_b';
      await settle();
      expect(server.calls, isEmpty);
      expect(session.stale, isTrue);
      expect(await session.submit(ServerMockEndReason.student), isFalse);
      expect(server.calls, isEmpty);
    });

    test('a response that arrives after the account changed is not shown',
        () async {
      server.stallNext = true;
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await settle();
      actor = null;
      final before = notifications;
      server.stalled.single.complete();
      await settle();
      expect(session.stale, isTrue);
      expect(notifications, before);
    });

    test('the view cache is written for the original account only', () async {
      session
        ..goTo(2)
        ..toggleFlag('q1');
      await settle();
      expect(store.writes, isNotEmpty);
      final forThisMock =
          store.writes.every((w) => w.$1 == 'uid_a' && w.$2 == _mockId);
      expect(forThisMock, isTrue);
      final before = store.writes.length;
      actor = 'uid_b';
      session.goTo(1);
      await settle();
      expect(store.writes, hasLength(before));
    });

    test('disposing drops queued work and ignores a late response', () async {
      server.stallNext = true;
      session.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
      await settle();
      session.answer('q2', chosen: 'b', selectedIndex: 1, correct: false);
      await settle();
      session.dispose();
      disposedSessions.add(session);
      server.stalled.single.complete();
      await settle();
      expect(server.calls, hasLength(1));
      expect(store.writes.where((w) => w.$3 == 99), isEmpty);
    });
  });

  test('a same-id response cannot replace the pinned exam or questions',
      () async {
    for (final changedExam in [false, true]) {
      final original = server.view();
      final changed = server.view()..['paused'] = true;
      if (changedExam) {
        changed['examId'] = 'exam_cse_sub';
      } else {
        final paper = changed['paper']! as Map<String, Object?>;
        final sections = paper['sections']! as List<Object?>;
        final section = sections.first! as Map<String, Object?>;
        final questions = section['questions']! as List<Object?>;
        (questions.first! as Map<String, Object?>)['setId'] = 'different_set';
      }
      final guarded = ServerMockSession(
        api: ServerMockApi((_, __) async => changed),
        paper: ServerMockPaper.decode(original),
        uid: 'uid_a',
        currentUid: () => actor,
        elapsed: clock.call,
      );
      addTearDown(guarded.dispose);
      expect(await guarded.pause(), isFalse);
      expect(guarded.paper.examId, 'exam_cse_pro');
      expect(guarded.paper.sections.first.questions.first.setId, '');
      expect(guarded.failure?.error, isA<ServerMockFormatException>());
    }
  });

  group('restoring', () {
    test('answers come back from the server with their indexes', () {
      server.answers = [
        {
          'questionId': 'q2',
          'chosen': 'choice_b',
          'correct': true,
          'answeredAt': 1790000100000,
        },
      ];
      final restored = open(restored: {'q2': 1, 'q9': 3});
      expect(restored.answers['q2']!.chosen, 'choice_b');
      expect(restored.selectedIndexOf('q2'), 1);
      expect(restored.selectedIndexOf('q9'), isNull);
    });

    test('a saved place and flags are kept only when they fit the paper', () {
      final restored = ServerMockSession(
        api: ServerMockApi(server.call),
        paper: ServerMockPaper.decode(server.view()),
        uid: 'uid_a',
        currentUid: () => actor,
        elapsed: clock.call,
        cursor: 99,
        flags: {'q2', 'gone'},
      );
      addTearDown(restored.dispose);
      expect(restored.cursor, 2);
      expect(restored.flags, {'q2'});
    });

    test('going to a question outside the paper stays inside it', () {
      session.goTo(-4);
      expect(session.cursor, 0);
      session.goTo(50);
      expect(session.cursor, 2);
    });
  });

  group('by-part papers', () {
    late _PartServer parts;

    ServerMockSession openParts({
      int cursor = 0,
      Duration saveDelay = const Duration(milliseconds: 5),
      _PartServer? on,
    }) {
      final source = on ?? parts;
      final opened = ServerMockSession(
        api: ServerMockApi(source.call),
        paper: ServerMockPaper.decode(source.view()),
        uid: 'uid_a',
        currentUid: () => actor,
        elapsed: clock.call,
        cursor: cursor,
        viewStore: store,
        saveDelay: saveDelay,
      );
      addTearDown(opened.dispose);
      return opened;
    }

    Map<String, Object?> answerOf(String id, String chosen) => {
          'questionId': id,
          'chosen': chosen,
          'correct': chosen == 'right',
          'answeredAt': 1790000100000,
        };

    setUp(() => parts = _PartServer());

    group('what a one-block paper keeps', () {
      test('a paper without the block is one part, whatever the server holds',
          () async {
        expect(session.byPart, isFalse);
        expect(session.partTotal, 3);
        expect(session.partPosition, 1);
        expect(session.canGoPrevious, isFalse);
        expect(session.canGoNext, isTrue);
        expect(session.closedPartCount, 0);
        expect(session.waiting, isFalse);
        expect(session.breakRemaining, isNull);
        expect(await session.startPart(), isFalse);
        expect(await session.endPart(), isFalse);
        expect(server.calls, isEmpty);
        session.tick();
        clock.now = const Duration(hours: 5);
        session.tick();
        await settle();
        expect(server.calls, isEmpty);
        expect(session.timeIsUp, isTrue);
      });

      test('a save is still held for the delay with seconds left', () async {
        server.remainingMs = 2000;
        final slow = ServerMockSession(
          api: ServerMockApi(server.call),
          paper: ServerMockPaper.decode(server.view()),
          uid: 'uid_a',
          currentUid: () => actor,
          elapsed: clock.call,
          saveDelay: const Duration(seconds: 30),
        );
        addTearDown(slow.dispose);
        slow.answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
        await settle();
        expect(server.calls, isEmpty);
        await slow.flush();
        expect(server.saves, hasLength(1));
      });
    });

    group('the clock', () {
      test('it shows the part, not the paper, and counts from a reading', () {
        parts
          ..index = 1
          ..remainingMs = 450000;
        final running = openParts();
        expect(running.remaining, const Duration(milliseconds: 450000));
        clock.now = const Duration(seconds: 60);
        expect(running.remaining, const Duration(milliseconds: 390000));
        expect(running.partLimit, const Duration(minutes: 10));
        expect(parts.calls, isEmpty);
      });

      test('it stands still while waiting', () {
        parts
          ..index = 1
          ..waiting = true
          ..remainingMs = 600000;
        final waiting = openParts();
        clock.now = const Duration(minutes: 5);
        expect(waiting.remaining, const Duration(minutes: 10));
        expect(waiting.timeIsUp, isFalse);
        expect(waiting.breakRemaining, isNull);
      });

      test('it stands still while paused', () async {
        parts.remainingMs = 450000;
        final running = openParts();
        clock.now = const Duration(seconds: 30);
        expect(await running.pause(), isTrue);
        final held = running.remaining;
        clock.now = const Duration(minutes: 9);
        expect(running.remaining, held);
        expect(running.paused, isTrue);
      });

      test('a strict break counts down from the time until the part starts',
          () {
        final strict = _PartServer(strict: true)
          ..index = 1
          ..waiting = true
          ..remainingMs = 600000
          ..startsInMs = 42000;
        final waiting = openParts(on: strict);
        expect(waiting.breakRemaining, const Duration(seconds: 42));
        clock.now = const Duration(seconds: 2);
        expect(waiting.breakRemaining, const Duration(seconds: 40));
        expect(waiting.remaining, const Duration(minutes: 10));
        clock.now = const Duration(minutes: 5);
        expect(waiting.breakRemaining, Duration.zero);
      });

      test('the time the page shows is never the whole paper', () {
        parts
          ..index = 1
          ..remainingMs = 450000;
        final running = openParts();
        expect(running.remaining, isNot(running.paper.remaining));
        expect(running.used, const Duration(milliseconds: 150000));
      });
    });

    group('moving through the running part', () {
      test('the question list, counter and arrows follow the running part', () {
        parts
          ..index = 1
          ..remainingMs = 450000;
        final running = openParts(cursor: 3);
        expect(running.cursor, 3);
        expect(running.partNumber, 2);
        expect(running.partName, 'Reasoning');
        expect(running.partTotal, 2);
        expect(running.partPosition, 2);
        expect(running.closedPartCount, 1);
        expect(running.canGoPrevious, isTrue);
        expect(running.canGoNext, isFalse);
      });

      test('a place outside the running part opens on its first question', () {
        parts
          ..index = 1
          ..remainingMs = 450000;
        expect(openParts().cursor, 2);
        expect(openParts(cursor: 5).cursor, 2);
        expect(openParts().cursor, 2);
      });

      test('going to a question stays inside the running part', () {
        parts
          ..index = 1
          ..remainingMs = 450000;
        final running = openParts()..goTo(0);
        expect(running.cursor, 2);
        running.goTo(5);
        expect(running.cursor, 3);
        running.goTo(2);
        expect(running.cursor, 2);
        expect(running.canGoPrevious, isFalse);
      });

      test('a flag or an answer changes only the running part', () async {
        parts
          ..index = 1
          ..remainingMs = 450000;
        final running = openParts(cursor: 2)
          ..toggleFlag('q1')
          ..toggleFlag('q5')
          ..answer('q2', chosen: 'a', selectedIndex: 0, correct: true)
          ..answer('q6', chosen: 'a', selectedIndex: 0, correct: true);
        expect(running.flags, isEmpty);
        expect(running.answers, isEmpty);
        running
          ..toggleFlag('q3')
          ..answer('q4', chosen: 'a', selectedIndex: 0, correct: true);
        expect(running.flags, {'q3'});
        expect(running.answers.keys, ['q4']);
        await settle();
        expect(parts.answers.map((a) => a['questionId']), ['q4']);
      });

      test('nothing can be moved or answered while a part waits', () async {
        parts
          ..index = 1
          ..waiting = true
          ..remainingMs = 600000;
        final waiting = openParts()
          ..goTo(3)
          ..toggleFlag('q3')
          ..answer('q3', chosen: 'a', selectedIndex: 0, correct: true);
        expect(waiting.cursor, 2);
        expect(waiting.flags, isEmpty);
        expect(waiting.answers, isEmpty);
        expect(await waiting.pause(), isFalse);
        expect(parts.calls, isEmpty);
      });
    });

    group('starting and ending a part', () {
      test('startPart goes through the queue and the part runs', () async {
        parts
          ..index = 1
          ..waiting = true
          ..endedEarly = true
          ..remainingMs = 600000;
        final waiting = openParts();
        expect(waiting.waiting, isTrue);
        expect(waiting.endedEarly, isTrue);
        expect(await waiting.startPart(), isTrue);
        expect(parts.actions, ['startPart']);
        expect(waiting.waiting, isFalse);
        expect(waiting.cursor, 2);
        expect(waiting.startedByServer, isFalse);
      });

      test('a second tap while one is in flight sends nothing', () async {
        parts
          ..index = 1
          ..waiting = true
          ..remainingMs = 600000
          ..stallNext = true;
        final waiting = openParts();
        final first = waiting.startPart();
        await settle();
        expect(waiting.startingPart, isTrue);
        expect(await waiting.startPart(), isFalse);
        parts.stalled.single.complete();
        expect(await first, isTrue);
        expect(waiting.startingPart, isFalse);
        expect(parts.actions, ['startPart']);
      });

      test('a failed startPart keeps its retry and the screen waiting',
          () async {
        parts
          ..index = 1
          ..waiting = true
          ..remainingMs = 600000;
        var broken = true;
        final failing = ServerMockSession(
          api: ServerMockApi((name, data) async {
            if (broken) throw const ServerMockException(code: 'unavailable');
            return parts.call(name, data);
          }),
          paper: ServerMockPaper.decode(parts.view()),
          uid: 'uid_a',
          currentUid: () => actor,
          elapsed: clock.call,
        );
        addTearDown(failing.dispose);
        expect(await failing.startPart(), isFalse);
        expect(failing.failure?.operation, ServerMockOperation.startPart);
        expect(failing.waiting, isTrue);
        expect(failing.startingPart, isFalse);
        broken = false;
        expect(await failing.retry(), isTrue);
        expect(failing.waiting, isFalse);
        expect(failing.failure, isNull);
        expect(parts.actions, ['startPart']);
      });

      test('startPart does nothing when no part waits', () async {
        final running = openParts();
        expect(await running.startPart(), isFalse);
        expect(parts.calls, isEmpty);
      });

      test('endPart closes the part and the next one waits', () async {
        parts.remainingMs = 450000;
        final running = openParts();
        expect(await running.endPart(), isTrue);
        expect(parts.actions, ['endPart']);
        expect(running.waiting, isTrue);
        expect(running.endedEarly, isTrue);
        expect(running.partNumber, 2);
        expect(running.cursor, 2);
      });

      test('endPart sends the answer made a moment ago first', () async {
        final running = openParts(saveDelay: const Duration(seconds: 30))
          ..answer('q1', chosen: 'right', selectedIndex: 0, correct: true);
        expect(await running.endPart(), isTrue);
        expect(parts.actions, ['save', 'endPart']);
        expect(parts.answers.map((a) => a['questionId']), ['q1']);
      });

      test('a strict paper never ends a part', () async {
        final strict = _PartServer(strict: true);
        final running = openParts(on: strict);
        expect(await running.endPart(), isFalse);
        expect(strict.calls, isEmpty);
      });

      test('the last part is submitted, never ended', () async {
        parts
          ..index = 2
          ..remainingMs = 300000;
        final last = openParts();
        expect(last.isLastPart, isTrue);
        expect(await last.endPart(), isFalse);
        expect(parts.calls, isEmpty);
        expect(await last.submit(ServerMockEndReason.student), isTrue);
        expect(parts.named('submitMock'), hasLength(1));
      });

      test('a part that waits cannot be ended', () async {
        parts
          ..index = 1
          ..waiting = true
          ..remainingMs = 600000;
        final waiting = openParts();
        expect(await waiting.endPart(), isFalse);
        expect(parts.calls, isEmpty);
      });
    });

    group('a part changes', () {
      test('closed parts take the server answers and drop what it never got',
          () async {
        final running = openParts()
          ..answer('q1', chosen: 'right', selectedIndex: 0, correct: true);
        await settle();
        expect(parts.answers.map((a) => a['questionId']), ['q1']);
        // The server closes the part. The student answers once more, a
        // moment before the screen finds out.
        parts
          ..closePart()
          ..answers = [answerOf('q1', 'wrong')];
        running.answer('q2', chosen: 'right', selectedIndex: 1, correct: true);
        expect(running.answers['q2']!.chosen, 'right');
        await settle();
        expect(running.waiting, isTrue);
        expect(running.answers.keys, ['q1']);
        expect(running.answers['q1']!.chosen, 'wrong');
        expect(running.selectedIndexOf('q2'), isNull);
        expect(running.selectedIndexOf('q1'), isNull);
      });

      test('an answer the server also holds keeps its place on the screen',
          () async {
        final running = openParts()
          ..answer('q1', chosen: 'right', selectedIndex: 2, correct: true);
        await settle();
        parts.closePart();
        running.answer('q2', chosen: 'x', selectedIndex: 0, correct: false);
        await settle();
        expect(running.waiting, isTrue);
        expect(running.selectedIndexOf('q1'), 2);
        expect(running.answers['q1']!.chosen, 'right');
      });

      test('the cursor goes to the first question of the part that follows',
          () async {
        parts.remainingMs = 450000;
        final running = openParts()..goTo(1);
        expect(running.cursor, 1);
        expect(await running.endPart(), isTrue);
        expect(running.cursor, 2);
        expect(await running.startPart(), isTrue);
        expect(running.cursor, 2);
        running.goTo(3);
        expect(store.writes.last.$3, 3);
      });

      test('a late answer for the part left is gone after the change',
          () async {
        final running = openParts();
        parts
          ..closePart()
          ..answers = [];
        running.answer('q1', chosen: 'right', selectedIndex: 0, correct: true);
        await settle();
        expect(running.waiting, isTrue);
        expect(running.answers, isEmpty);
      });

      test('the running part keeps a newer local answer, as before', () async {
        parts
          ..index = 1
          ..remainingMs = 450000;
        final running = openParts(saveDelay: const Duration(seconds: 30))
          ..answer('q3', chosen: 'right', selectedIndex: 0, correct: true);
        await running.flush();
        running.answer('q4', chosen: 'x', selectedIndex: 1, correct: false);
        parts.stallNext = true;
        final pausing = running.pause();
        await settle();
        parts.stalled.single.complete();
        await pausing;
        expect(running.answers.keys, containsAll(['q3', 'q4']));
      });

      test('discard goes back to the first part and its first question',
          () async {
        parts
          ..index = 1
          ..remainingMs = 450000
          ..answers = [answerOf('q1', 'right')];
        final running = openParts(cursor: 3);
        expect(running.cursor, 3);
        expect(await running.discard(), isTrue);
        expect(running.cursor, 0);
        expect(running.partNumber, 1);
        expect(running.answers, isEmpty);
      });

      test('a response that drops the parts is refused', () async {
        final changed = parts.view()..remove('parts');
        final guarded = ServerMockSession(
          api: ServerMockApi((_, __) async => changed),
          paper: ServerMockPaper.decode(parts.view()),
          uid: 'uid_a',
          currentUid: () => actor,
          elapsed: clock.call,
        );
        addTearDown(guarded.dispose);
        expect(await guarded.pause(), isFalse);
        expect(guarded.byPart, isTrue);
        expect(guarded.failure?.error, isA<ServerMockFormatException>());
      });

      test('a response that changes a part limit is refused', () async {
        final changed = parts.view();
        ((changed['parts']! as Map)['limitsMs']! as List)
          ..[0] = 300000
          ..[1] = 900000;
        final guarded = ServerMockSession(
          api: ServerMockApi((_, __) async => changed),
          paper: ServerMockPaper.decode(parts.view()),
          uid: 'uid_a',
          currentUid: () => actor,
          elapsed: clock.call,
        );
        addTearDown(guarded.dispose);
        expect(await guarded.pause(), isFalse);
        expect(guarded.failure?.error, isA<ServerMockFormatException>());
      });
    });

    group('a strict part that started by itself', () {
      late _PartServer strict;

      setUp(() {
        strict = _PartServer(strict: true)
          ..index = 1
          ..waiting = true
          ..remainingMs = 600000
          ..startsInMs = 5000;
      });

      Future<ServerMockSession> startedByItself() async {
        final waiting = openParts(on: strict);
        clock.now = const Duration(seconds: 6);
        strict.startByItself(usedMs: 1000);
        waiting.tick();
        await settle();
        return waiting;
      }

      test('the read after the break shows the part and the note', () async {
        final started = await startedByItself();
        expect(strict.named('getMockPaper'), hasLength(1));
        expect(started.waiting, isFalse);
        expect(started.startedByServer, isTrue);
        expect(started.cursor, 2);
        expect(started.remaining, const Duration(milliseconds: 599000));
      });

      test('the note ends at the first answer', () async {
        final started = await startedByItself();
        started.answer('q3', chosen: 'a', selectedIndex: 0, correct: false);
        expect(started.startedByServer, isFalse);
      });

      test('the note ends after fifteen seconds', () async {
        final started = await startedByItself();
        clock.now += const Duration(seconds: 14);
        expect(started.startedByServer, isTrue);
        clock.now += const Duration(seconds: 1, milliseconds: 1);
        expect(started.startedByServer, isFalse);
      });

      test('a start the student asked for never shows it', () async {
        final waiting = openParts(on: strict);
        expect(await waiting.startPart(), isTrue);
        expect(waiting.waiting, isFalse);
        expect(waiting.startedByServer, isFalse);
      });

      test('a part started by itself while the student was away shows it',
          () async {
        parts = _PartServer(strict: true)..remainingMs = 600000;
        final running = openParts(on: parts);
        parts
          ..closePart()
          ..startByItself(usedMs: 2000);
        running.answer('q1', chosen: 'a', selectedIndex: 0, correct: false);
        await settle();
        expect(running.waiting, isFalse);
        expect(running.partNumber, 2);
        expect(running.startedByServer, isTrue);
      });

      test('a part that waits for the student never shows it', () async {
        final loose = _PartServer()..remainingMs = 600000;
        final running = openParts(on: loose);
        loose.closePart();
        running.answer('q1', chosen: 'a', selectedIndex: 0, correct: false);
        await settle();
        expect(running.waiting, isTrue);
        expect(running.startedByServer, isFalse);
      });
    });

    group('when a clock reaches zero', () {
      test('the part clock asks the server and never submits', () async {
        parts.remainingMs = 5000;
        final running = openParts();
        clock.now = const Duration(seconds: 5);
        expect(running.remaining, Duration.zero);
        running.tick();
        await settle();
        expect(parts.named('getMockPaper'), hasLength(1));
        expect(parts.named('submitMock'), isEmpty);
        expect(running.submitted, isFalse);
        expect(running.submissionRequested, isFalse);
      });

      test('the clock stays at zero until the server answers, with input off',
          () async {
        parts
          ..remainingMs = 5000
          ..stallNext = true;
        final running = openParts();
        clock.now = const Duration(seconds: 9);
        running.tick();
        await settle();
        running
          ..answer('q1', chosen: 'a', selectedIndex: 0, correct: true)
          ..goTo(1)
          ..toggleFlag('q1');
        expect(running.answers, isEmpty);
        expect(running.cursor, 0);
        expect(running.flags, isEmpty);
        expect(await running.endPart(), isFalse);
        expect(running.remaining, Duration.zero);
        // Asking again while it is out does not send another read.
        running
          ..tick()
          ..tick();
        parts.stalled.single.complete();
        await settle();
        expect(parts.named('getMockPaper'), hasLength(1));
      });

      test('the server closed the part: the next one waits', () async {
        parts.remainingMs = 5000;
        final running = openParts();
        clock.now = const Duration(seconds: 6);
        parts.closePart();
        running.tick();
        await settle();
        expect(running.waiting, isTrue);
        expect(running.partNumber, 2);
        expect(running.endedEarly, isFalse);
        expect(running.remaining, const Duration(minutes: 10));
        expect(running.failure, isNull);
      });

      test('the server still has time: the clock runs on from its answer',
          () async {
        parts.remainingMs = 5000;
        final running = openParts();
        clock.now = const Duration(seconds: 5);
        parts.remainingMs = 800;
        running.tick();
        await settle();
        expect(running.remaining, const Duration(milliseconds: 800));
        clock.now += const Duration(milliseconds: 300);
        expect(running.remaining, const Duration(milliseconds: 500));
        running.tick();
        await settle();
        expect(parts.named('getMockPaper'), hasLength(1));
      });

      test('a mock the server finished goes to the results', () async {
        parts
          ..index = 2
          ..remainingMs = 5000;
        final last = openParts();
        clock.now = const Duration(seconds: 6);
        parts.finished = true;
        last.tick();
        await settle();
        expect(last.submitted, isTrue);
        expect(last.endedByServer, isTrue);
        expect(parts.named('submitMock'), isEmpty);
      });

      test('a read that finds no open mock goes to the results too', () async {
        parts.remainingMs = 5000;
        final none = ServerMockSession(
          api: ServerMockApi((_, __) async => {'open': false}),
          paper: ServerMockPaper.decode(parts.view()),
          uid: 'uid_a',
          currentUid: () => actor,
          elapsed: clock.call,
        );
        addTearDown(none.dispose);
        clock.now = const Duration(seconds: 6);
        none.tick();
        await settle();
        expect(none.submitted, isTrue);
        expect(none.endedByServer, isTrue);
      });

      test('a strict break at zero asks the server too', () async {
        final strict = _PartServer(strict: true)
          ..index = 1
          ..waiting = true
          ..remainingMs = 600000
          ..startsInMs = 3000;
        final waiting = openParts(on: strict);
        clock.now = const Duration(seconds: 2);
        waiting.tick();
        await settle();
        expect(strict.calls, isEmpty);
        clock.now = const Duration(seconds: 3);
        strict.startByItself();
        waiting.tick();
        await settle();
        expect(strict.named('getMockPaper'), hasLength(1));
        expect(strict.named('submitMock'), isEmpty);
        expect(waiting.waiting, isFalse);
      });

      test('a part that waits for the student never asks', () async {
        parts
          ..index = 1
          ..waiting = true
          ..remainingMs = 600000;
        final waiting = openParts();
        clock.now = const Duration(hours: 4);
        waiting.tick();
        await settle();
        expect(parts.calls, isEmpty);
      });

      test('a paused part never asks', () async {
        parts.remainingMs = 5000;
        final running = openParts();
        expect(await running.pause(), isTrue);
        clock.now = const Duration(hours: 4);
        running.tick();
        await settle();
        expect(parts.named('getMockPaper'), isEmpty);
      });
    });

    group('a read that fails', () {
      test('it tries again later, never in a tight loop', () async {
        parts
          ..remainingMs = 5000
          ..readFailures = 3;
        final running = openParts();
        clock.now = const Duration(seconds: 6);
        running.tick();
        await settle();
        expect(parts.named('getMockPaper'), hasLength(1));
        expect(running.failure?.operation, ServerMockOperation.read);
        expect(running.remaining, Duration.zero);

        // Ticks in the same instant and half a second later send nothing.
        for (var i = 0; i < 200; i++) {
          running.tick();
        }
        clock.now += const Duration(milliseconds: 500);
        for (var i = 0; i < 200; i++) {
          running.tick();
        }
        await settle();
        expect(parts.named('getMockPaper'), hasLength(1));

        clock.now += const Duration(milliseconds: 600);
        running.tick();
        await settle();
        expect(parts.named('getMockPaper'), hasLength(2));
        expect(running.failure, isNotNull);

        // The wait grows, and it is bounded.
        var last = 2;
        var waited = Duration.zero;
        for (var round = 0; round < 6; round++) {
          var step = Duration.zero;
          while (parts.named('getMockPaper').length == last &&
              step.inSeconds < 60) {
            clock.now += const Duration(milliseconds: 250);
            step += const Duration(milliseconds: 250);
            running.tick();
            await settle();
          }
          waited = step > waited ? step : waited;
          last = parts.named('getMockPaper').length;
          if (running.failure == null) break;
        }
        expect(
          running.failure,
          isNull,
          reason: 'the third failure was the last',
        );
        expect(waited, lessThanOrEqualTo(const Duration(seconds: 12)));
        expect(waited, greaterThanOrEqualTo(const Duration(seconds: 1)));
        expect(running.remaining, isNot(Duration.zero));
      });

      test('Retry asks at once and clears the failure when it works', () async {
        parts
          ..remainingMs = 5000
          ..readFailures = 1;
        final running = openParts();
        clock.now = const Duration(seconds: 6);
        parts.closePart();
        running.tick();
        await settle();
        expect(running.failure?.operation, ServerMockOperation.read);
        expect(await running.retry(), isTrue);
        expect(parts.named('getMockPaper'), hasLength(2));
        expect(running.failure, isNull);
        expect(running.waiting, isTrue);
      });

      test('a failed read still lets a finished mock end', () async {
        parts
          ..index = 2
          ..remainingMs = 5000
          ..readFailures = 1;
        final last = openParts();
        clock.now = const Duration(seconds: 6);
        last.tick();
        await settle();
        parts.finished = true;
        clock.now += const Duration(seconds: 2);
        last.tick();
        await settle();
        expect(last.submitted, isTrue);
        expect(last.endedByServer, isTrue);
        expect(last.failure, isNull);
      });
    });

    group('a pending save near the end of a part', () {
      test('goes out at once with under three seconds left', () async {
        parts.remainingMs = 2500;
        openParts(saveDelay: const Duration(seconds: 30))
            .answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
        await settle();
        expect(parts.actions, ['save']);
      });

      test('waits for the delay with more time left', () async {
        parts.remainingMs = 20000;
        openParts(saveDelay: const Duration(seconds: 30))
            .answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
        await settle();
        expect(parts.calls, isEmpty);
      });

      test('goes out when the clock crosses three seconds, once', () async {
        parts.remainingMs = 6000;
        final running = openParts(
          saveDelay: const Duration(milliseconds: 150),
        )..answer('q1', chosen: 'a', selectedIndex: 0, correct: true);
        clock.now = const Duration(seconds: 2);
        running.tick();
        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(parts.calls, isEmpty);
        clock.now = const Duration(milliseconds: 3100);
        running
          ..tick()
          ..tick();
        // The delay that was running must not send the same answer again.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        expect(parts.actions, ['save']);
      });
    });

    test('the paper is submitted for every question, blanks included',
        () async {
      parts
        ..index = 1
        ..waiting = true
        ..remainingMs = 600000;
      final waiting = openParts();
      expect(await waiting.submit(ServerMockEndReason.student), isTrue);
      final sent = parts.named('submitMock').single.$2;
      expect((sent['answers']! as List).length, 6);
      expect(sent['durationMs'], inInclusiveRange(0, 86400000));
    });

    test('the view cache keeps the place inside the running part', () async {
      parts
        ..index = 1
        ..remainingMs = 450000;
      final running = openParts()..goTo(3);
      await settle();
      expect(store.writes.last.$3, 3);
      expect(running.cursor, 3);
    });
  });
}
