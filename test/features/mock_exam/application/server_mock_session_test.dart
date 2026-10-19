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

    test('a strict exit may send nothing', () async {
      server.strict = true;
      final strict = open();
      expect(await strict.submit(ServerMockEndReason.strictExit), isTrue);
      final sent = server.calls.last.$2;
      expect(sent['reason'], 'strict-exit');
      expect(sent['answers'], isEmpty);
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
}
