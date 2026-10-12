import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_route.dart';

import '../../../helpers/in_memory_database.dart';

const _sample = MockSample(
  expectedQuestionCount: 5,
  sections: [
    SampledMockSection(
      sectionId: 's1',
      name: 'Part 1',
      questionIds: ['right', 'wrong', 'blank', 'noteOnly', 'retired'],
    ),
  ],
);
const _answers = {
  'right': MockAnswer(selectedIndex: 0, atSec: 10),
  'wrong': MockAnswer(selectedIndex: 1, atSec: 20),
  'noteOnly': MockAnswer(
    selectedIndex: -1,
    atSec: 0,
    blankReason: BlankReason.didNotKnow,
  ),
  'retired': MockAnswer(selectedIndex: 0, atSec: 30),
};

Question _question(String id) => Question(
      id: id,
      version: 1,
      examIds: const ['exam_upcat'],
      topicId: 'topic',
      language: 'en',
      stem: id,
      explanation: 'Because.',
      choices: [
        Choice(id: '${id}_a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: '${id}_b', label: 'B', text: 'B', isCorrect: false),
      ],
    );

MockResults _compute(String examId) => ComputeMockResults()(
      examId: examId,
      sample: _sample,
      questionsById: {
        for (final id in ['right', 'wrong', 'blank', 'noteOnly'])
          id: _question(id),
      },
      answers: _answers,
      totalTimeSeconds: 60,
      wasStrict: false,
      scoreBands: null,
    );

void main() {
  for (final examId in ['exam_upcat', 'exam_cse_pro', 'custom_track']) {
    test('$examId stores distinct counts and its own unrounded score', () {
      final results = _compute(examId);
      expect(results.scoreRaw, 1);
      expect(results.scoreTotal, 4);
      expect(results.sections.single.correct, 1);
      expect(results.sections.single.wrong, 1);
      expect(results.sections.single.blank, 2);
      expect(results.sections.single.retiredCount, 1);
      expect(results.percent, examId == 'exam_upcat' ? 18.75 : 25);
    });
  }

  test('empty surviving paper scores zero', () {
    final results = ComputeMockResults()(
      examId: 'exam_upcat',
      sample: _sample,
      questionsById: const {},
      answers: _answers,
      totalTimeSeconds: 60,
      wasStrict: false,
      scoreBands: null,
    );
    expect(results.percent, 0);
    expect(results.scoreTotal, 0);
    expect(results.sections.single.wrong, 0);
    expect(results.sections.single.blank, 0);
  });

  test('review reasons survive answer JSON without changing a selection', () {
    const codec = MockSessionSnapshotCodec();
    final encoded = codec.encodeAnswers(const {
      'right': MockAnswer(
        selectedIndex: 0,
        atSec: 10,
        missReason: MissReason.other,
        reasonNote: 'I read the wrong line.',
      ),
      'blank': MockAnswer(
        selectedIndex: -1,
        atSec: 0,
        blankReason: BlankReason.skippedToReturn,
        reasonNote: 'Come back later',
      ),
    });
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    expect(map['right'], {
      'selectedIndex': 0,
      'atSec': 10,
      'missReason': 'other',
      'reasonNote': 'I read the wrong line.',
    });
    expect(map['blank'], {
      'selectedIndex': -1,
      'atSec': 0,
      'blankReason': 'skippedToReturn',
      'reasonNote': 'Come back later',
    });
    final decoded = codec.decode(
      sampledQuestionsJson:
          '[{"sectionId":"s1","name":"Part 1","questionIds":["right", '
          '"blank"]}]',
      answersJson: encoded,
      flagsJson: '[]',
    );
    expect(decoded.answers['right']!.missReason, MissReason.other);
    expect(decoded.answers['right']!.reasonNote, 'I read the wrong line.');
    expect(decoded.answers['blank']!.blankReason, BlankReason.skippedToReturn);
  });

  test('submit and the one decoder preserve counts and percentage units',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = MockAttemptRepo(db);
    await _insert(repo, 'new');
    final attempt = await SubmitMock(repo: repo)(
      attemptId: 'new',
      results: _compute('exam_upcat'),
      submittedAt: DateTime.utc(2026, 10, 12),
    );
    final json =
        jsonDecode(attempt.sectionResultsJson!) as Map<String, dynamic>;
    expect(
      (json['sections'] as List<dynamic>).single,
      containsPair('wrong', 1),
    );
    expect(
      (json['sections'] as List<dynamic>).single,
      containsPair('blank', 2),
    );
    final decoded = decodeMockResults(attempt)!;
    expect(decoded.percent, 18.75);
    expect(decoded.sections.single.wrong, 1);
    expect(decoded.sections.single.blank, 2);
    expect(decoded.totalTimeSeconds, 60);
  });

  test('old null counts recover blanks and wrongs excluding retired answers',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = MockAttemptRepo(db);
    await _insert(repo, 'old');
    await repo.flushProgress(
      attemptId: 'old',
      elapsedSeconds: 60,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: const MockSessionSnapshotCodec().encodeAnswers(_answers),
      flagsJson: '[]',
      currentIndex: 0,
      flushedAt: DateTime.utc(2026, 10, 12),
    );
    await repo.submit(
      attemptId: 'old',
      status: MockAttemptStatus.completed,
      results: _compute('exam_upcat'),
      submittedAt: DateTime.utc(2026, 10, 12),
      sectionResultsJson:
          '{"sections":[{"sectionId":"s1","name":"Part 1","correct":1, '
          '"total":4,"wrong":null,"blank":null,"retiredCount":1, '
          '"timeSeconds":30}]}',
    );
    final attempt = (await repo.findById('old'))!;
    final decoded = decodeMockResults(
      attempt,
      activeQuestionIds: {'right', 'wrong', 'blank', 'noteOnly'},
    )!;
    expect(decoded.sections.single.wrong, 1);
    expect(decoded.sections.single.blank, 2);
    expect(decoded.percent, 18.75);
  });

  test('review saves one reason and retains answers, flags and terminal score',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = MockAttemptRepo(db);
    await _insert(repo, 'review');
    await repo.flushProgress(
      attemptId: 'review',
      elapsedSeconds: 60,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: const MockSessionSnapshotCodec().encodeAnswers(_answers),
      flagsJson: '["wrong"]',
      currentIndex: 2,
      flushedAt: DateTime.utc(2026, 10, 12),
    );
    await SubmitMock(repo: repo)(
      attemptId: 'review',
      results: _compute('exam_upcat'),
      submittedAt: DateTime.utc(2026, 10, 12),
    );
    await repo.saveReviewReason(
      attemptId: 'review',
      questionId: 'wrong',
      missReason: MissReason.misread,
      reasonNote: 'Wrong line',
      savedAt: DateTime.utc(2026, 10, 13),
    );
    await repo.saveReviewReason(
      attemptId: 'review',
      questionId: 'blank',
      blankReason: BlankReason.ranOutOfTime,
      savedAt: DateTime.utc(2026, 10, 13),
    );
    final attempt = (await repo.findById('review'))!;
    final answers = const MockSessionSnapshotCodec()
        .decode(
          sampledQuestionsJson: attempt.sampledQuestionsJson,
          answersJson: attempt.answersJson,
          flagsJson: attempt.flagsJson,
        )
        .answers;
    expect(answers['wrong']!.selectedIndex, 1);
    expect(answers['wrong']!.atSec, 20);
    expect(answers['wrong']!.missReason, MissReason.misread);
    expect(answers['wrong']!.reasonNote, 'Wrong line');
    expect(answers['blank']!.selectedIndex, -1);
    expect(answers['blank']!.blankReason, BlankReason.ranOutOfTime);
    expect(answers['right']!.selectedIndex, 0);
    expect(attempt.flagsJson, '["wrong"]');
    expect(attempt.scoreRaw, 1);
    expect(attempt.status, MockAttemptStatus.completed);
  });
}

Future<void> _insert(MockAttemptRepo repo, String id) => repo.insertStart(
      MockAttemptStart(
        id: id,
        userId: mockAttemptLocalUserId,
        examId: 'exam_upcat',
        blueprintId: 'bp',
        blueprintName: 'UPCAT',
        durationMinutes: 165,
        strictMode: false,
        sampledQuestionsJson: const MockSessionSnapshotCodec().encodeSample(
          _sample,
          currentPartIndex: 0,
          partStartedAtSeconds: 0,
          partsTimedSeparately: false,
          parts: const [
            MockPersistedPart(
              name: '',
              startIndex: 0,
              count: 5,
              minutes: null,
            ),
          ],
        ),
        startedAt: DateTime.utc(2026, 10, 12),
      ),
    );
