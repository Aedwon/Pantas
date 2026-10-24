import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_writes.dart';

void main() {
  test('reserving a new local mutation synchronously retires failed retries',
      () async {
    final sent = <int>[];
    var fail = true;
    final request = StudyRequest(
      uid: 'u',
      examId: 'e',
      isCurrent: () async => true,
      api: StudyApi((_, p) async {
        sent.add(p['value']! as int);
        if (fail) throw StateError('offline');
        return <String, Object?>{};
      }),
    );
    final writes = StudyWrites();
    await expectLater(writes.settings(request, {'value': 1}), throwsStateError);
    final intent = writes.beginSettings();
    fail = false;
    await writes.retrySettings();
    expect(sent, [1]);
    await intent.publish(request, {'value': 2});
    expect(sent, [1, 2]);
  });

  test('a waiting settings caller also follows a third superseding intent',
      () async {
    final secondEntered = Completer<void>();
    final thirdEntered = Completer<void>();
    final secondRelease = Completer<void>();
    final thirdRelease = Completer<void>();
    final request = StudyRequest(
      api: StudyApi((_, data) async {
        if (data['value'] == 2) {
          secondEntered.complete();
          await secondRelease.future;
        } else {
          thirdEntered.complete();
          await thirdRelease.future;
        }
        return <String, Object?>{};
      }),
      uid: 'owner',
      examId: 'e',
      isCurrent: () async => true,
    );
    final writes = StudyWrites();
    var firstFinished = false;
    final first = writes
        .settings(request, {'value': 1}).then((_) => firstFinished = true);
    final second = writes.settings(request, {'value': 2});
    await secondEntered.future;
    final third = writes.settings(request, {'value': 3});
    secondRelease.complete();
    await thirdEntered.future;
    await Future<void>.delayed(Duration.zero);
    final finishedBeforeLatest = firstFinished;
    thirdRelease.complete();
    await Future.wait([first, second, third]);
    expect(finishedBeforeLatest, isFalse);
  });

  test('a superseded settings caller waits for the replacement to finish',
      () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final sent = <int>[];
    final request = StudyRequest(
      api: StudyApi((_, data) async {
        sent.add(data['value']! as int);
        entered.complete();
        await release.future;
        return <String, Object?>{};
      }),
      uid: 'owner',
      examId: 'e',
      isCurrent: () async => true,
    );
    final writes = StudyWrites();
    var firstFinished = false;
    final first = writes
        .settings(request, {'value': 1}).then((_) => firstFinished = true);
    final second = writes.settings(request, {'value': 2});
    await entered.future;
    await Future<void>.delayed(Duration.zero);
    expect(firstFinished, isFalse);
    release.complete();
    await Future.wait([first, second]);
    expect(sent, [2]);
  });

  test('session payload preserves actual timing and never invents answer times',
      () {
    final start = DateTime.utc(2026, 10, 23, 15, 59);
    final end = start.add(const Duration(minutes: 2));
    final payload = studySessionPayload(
      Attempt(
        id: 'session_1',
        examId: 'e',
        startedAt: start,
        completedAt: end,
        origin: 'new_questions',
        items: const [
          AttemptItem(
            questionId: 'q',
            questionVersion: 3,
            chosenChoiceId: 'a',
            correctChoiceId: 'a',
            responseMs: 1400,
          ),
        ],
      ),
    );
    expect(payload['startedAt'], start.millisecondsSinceEpoch);
    expect(payload['finishedAt'], end.millisecondsSinceEpoch);
    expect(payload['durationMs'], 120000);
    expect(payload['origin'], 'new_questions');
    expect((payload['answers']! as List).single, {
      'questionId': 'q',
      'chosen': 'a',
      'correct': true,
      'responseMs': 1400,
      'questionVersion': 3,
    });
  });

  test('settings serialize and new intent supersedes an old failed retry',
      () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final sent = <int>[];
    var fail = true;
    final request = StudyRequest(
      api: StudyApi((name, payload) async {
        expect(payload['expectedUid'], 'owner');
        final value = payload['value']! as int;
        sent.add(value);
        if (value == 1) {
          entered.complete();
          await release.future;
        }
        if (fail) throw StateError('offline');
        return <String, Object?>{};
      }),
      uid: 'owner',
      examId: 'e',
      isCurrent: () async => true,
    );
    final writes = StudyWrites();
    final first = writes.settings(request, {'value': 1});
    final rejected = expectLater(first, throwsStateError);
    await entered.future;
    final second = writes.settings(request, {'value': 2});
    expect(sent, [1]);
    release.complete();
    await rejected;
    fail = false;
    await second;
    await writes.retrySettings();
    expect(sent, [1, 2]);
  });

  test('advance retries retain the original day revision and request ID',
      () async {
    final sent = <Map<String, Object?>>[];
    final request = StudyRequest(
      api: StudyApi((_, payload) async {
        sent.add(payload);
        if (sent.length == 1) throw StateError('offline');
        return <String, Object?>{};
      }),
      uid: 'owner',
      examId: 'e',
      isCurrent: () async => true,
    );
    final advance = StudyAdvance(
      request,
      requestId: 'request_1',
      expectedDay: '2026-10-24',
      expectedRevision: 'r1',
    );
    await expectLater(advance.send(), throwsStateError);
    await advance.send();
    expect(sent.first, sent.last);
    expect(sent.last['expectedRevision'], 'r1');
  });
}
