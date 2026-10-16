import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

const _sample = MockSample(
  expectedQuestionCount: 3,
  sections: [
    SampledMockSection(
      sectionId: 'one',
      name: 'Reading',
      questionIds: ['q1', 'q2'],
    ),
    SampledMockSection(sectionId: 'two', name: 'Math', questionIds: ['q3']),
  ],
);
const _parts = [
  MockPersistedPart(name: 'Reading', startIndex: 0, count: 2, minutes: 2),
  MockPersistedPart(name: 'Math', startIndex: 2, count: 1, minutes: 3),
];
const _codec = MockSessionSnapshotCodec();

MockSessionController _controller({bool strict = false}) =>
    MockSessionController.initial(
      attemptId: 'attempt',
      strictMode: strict,
      durationSeconds: 300,
      questionIds: ['q1', 'q2', 'q3'],
      parts: [
        const MockSessionPart(
          name: 'Reading',
          startIndex: 0,
          count: 2,
          minutes: 2,
        ),
        const MockSessionPart(
          name: 'Math',
          startIndex: 2,
          count: 1,
          minutes: 3,
        ),
      ],
    );

String _encoded({
  bool betweenParts = true,
  bool endedEarly = false,
  DateTime? backgroundedAt,
}) =>
    _codec.encodeSample(
      _sample,
      currentPartIndex: 1,
      partStartedAtSeconds: 120,
      partsTimedSeparately: true,
      parts: _parts,
      betweenParts: betweenParts,
      endedEarly: endedEarly,
      strictBackgroundedAt: backgroundedAt,
    );

void main() {
  test('elapsed part waits, freezes next clock, and starts exactly once', () {
    final controller = _controller()
      ..answerCurrent(0)
      ..tickTo(120);
    expect(controller.state, isA<MockSessionBetweenParts>());
    final waiting = controller.state as MockSessionBetweenParts;
    expect(waiting.endedEarly, isFalse);
    expect(waiting.snapshot.currentIndex, 2);
    expect(controller.currentPartIndex, 1);
    expect(controller.remainingInPart, const Duration(minutes: 3));
    expect(controller.canGoNext, isFalse);
    expect(controller.startNextPart(), isTrue);
    expect(controller.startNextPart(), isFalse);
    controller.tickTo(121);
    expect(controller.remainingInPart, const Duration(minutes: 2, seconds: 59));
  });
  test('waiting ignores timer ticks until explicit start', () {
    final controller = _controller()
      ..tickTo(120)
      ..tickTo(240);
    expect(controller.remainingInPart, const Duration(minutes: 3));
    expect(
      (controller.state as MockSessionBetweenParts).snapshot.elapsedSeconds,
      120,
    );
  });
  test('strict background expiry still forfeits between parts once', () {
    final controller = _controller(strict: true)
      ..tickTo(120)
      ..strictBackgroundExceeded()
      ..strictBackgroundExceeded();
    expect(controller.state, isA<MockSessionForfeited>());
  });
  test('early ending waits with the unused time lost', () {
    final controller = _controller()
      ..tickTo(20)
      ..endPartEarly();
    expect(controller.state, isA<MockSessionBetweenParts>());
    expect((controller.state as MockSessionBetweenParts).endedEarly, isTrue);
    expect(controller.remainingInPart, const Duration(minutes: 3));
    controller
      ..startNextPart()
      ..tickTo(200);
    expect(controller.state, isA<MockSessionSubmitted>());
  });
  test('snapshot round trip preserves transition and answered data', () {
    final restored = _codec.decode(
      sampledQuestionsJson: _encoded(endedEarly: true),
      answersJson: '{"q1":{"selectedIndex":0,"atSec":3}}',
      flagsJson: '["q2"]',
    );
    expect(restored.betweenParts, isTrue);
    expect(restored.endedEarly, isTrue);
    expect(restored.answers['q1']!.selectedIndex, 0);
    expect(restored.flags, {'q2'});
  });
  test('absent transition metadata preserves legacy running state', () {
    final raw = jsonDecode(_encoded(betweenParts: false)) as List<dynamic>;
    ((raw.first as Map<String, dynamic>)['_session'] as Map<String, dynamic>)
      ..remove('betweenParts')
      ..remove('endedEarly');
    final restored = _codec.decode(
      sampledQuestionsJson: jsonEncode(raw),
      answersJson: '{}',
      flagsJson: '[]',
    );
    expect(restored.betweenParts, isFalse);
    expect(restored.endedEarly, isFalse);
  });
  for (final mutation in <String, Object?>{
    'betweenParts': 'true',
    'endedEarly': 1,
    'currentPartIndex': 0,
    'partsTimedSeparately': false,
  }.entries) {
    test('rejects inconsistent transition ${mutation.key}', () {
      final raw = jsonDecode(_encoded()) as List<dynamic>;
      final session = (raw.first as Map<String, dynamic>)['_session']
          as Map<String, dynamic>;
      session[mutation.key] = mutation.value;
      expect(
        () => _codec.decode(
          sampledQuestionsJson: jsonEncode(raw),
          answersJson: '{}',
          flagsJson: '[]',
        ),
        throwsFormatException,
      );
    });
  }
  test('restored gate refuses a started next clock or wrong position', () {
    MockSessionController restored({int index = 2, int elapsed = 120}) =>
        MockSessionController.restored(
          attemptId: 'attempt',
          durationSeconds: 300,
          questionIds: ['q1', 'q2', 'q3'],
          currentIndex: index,
          elapsedSeconds: elapsed,
          answers: {},
          flags: {},
          strictMode: false,
          parts: _controller().parts,
          currentPartIndex: 1,
          partStartedAtSeconds: 120,
          betweenParts: true,
        );
    expect(() => restored(elapsed: 121), throwsArgumentError);
    expect(() => restored(index: 1), throwsArgumentError);
    expect(restored().state, isA<MockSessionBetweenParts>());
  });
  test('reopening a waiting paper cannot spend next-part time', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = MockAttemptRepo(db);
    final start = DateTime.utc(2026, 10, 16, 8);
    await repo.insertStart(
      MockAttemptStart(
        id: 'attempt',
        userId: 'local',
        examId: 'upcat',
        blueprintId: 'paper',
        blueprintName: 'UPCAT',
        durationMinutes: 5,
        strictMode: true,
        sampledQuestionsJson:
            _encoded(backgroundedAt: start.add(const Duration(minutes: 2))),
        startedAt: start,
      ),
    );
    await repo.flushProgress(
      attemptId: 'attempt',
      elapsedSeconds: 120,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{"q1":{"selectedIndex":0,"atSec":3}}',
      flagsJson: '[]',
      currentIndex: 2,
      flushedAt: start.add(const Duration(minutes: 2)),
    );
    final resumed = await ResumeMock(repo: repo)(
      attemptId: 'attempt',
      userId: 'local',
      now: start.add(const Duration(hours: 1)),
    );
    expect(resumed.attempt!.elapsedSeconds, 120);
    expect(resumed.attempt!.accumulatedPausedSeconds, 3480);
    final decoded = _codec.decode(
      sampledQuestionsJson: resumed.attempt!.sampledQuestionsJson,
      answersJson: resumed.attempt!.answersJson,
      flagsJson: resumed.attempt!.flagsJson,
    );
    expect(decoded.betweenParts, isTrue);
    expect(decoded.answers['q1']!.selectedIndex, 0);
    expect(decoded.strictBackgroundedAt, start.add(const Duration(minutes: 2)));
    final reopened = await ResumeMock(repo: repo)(
      attemptId: 'attempt',
      userId: 'local',
      now: start.add(const Duration(hours: 2)),
    );
    expect(reopened.attempt!.elapsedSeconds, 120);
    expect(reopened.attempt!.accumulatedPausedSeconds, 7080);
    await repo.flushProgress(
      attemptId: 'attempt',
      elapsedSeconds: 120,
      accumulatedPausedSeconds: 7080,
      pausedAtLastFlush: false,
      answersJson: reopened.attempt!.answersJson,
      flagsJson: '[]',
      currentIndex: 0,
      flushedAt: start.add(const Duration(hours: 2)),
    );
    await expectLater(
      ResumeMock(repo: repo)(
        attemptId: 'attempt',
        userId: 'local',
        now: start.add(const Duration(hours: 3)),
      ),
      throwsFormatException,
    );
    final broken = (await repo.findById('attempt'))!;
    expect(broken.currentIndex, 0);
    expect(broken.lastFlushedAt, start.add(const Duration(hours: 2)));
    expect(broken.answersJson, reopened.attempt!.answersJson);
  });
}
