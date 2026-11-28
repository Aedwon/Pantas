import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/application/decode_mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

SectionResult _section(
  String name, {
  required int correct,
  required int wrong,
  required int blank,
}) =>
    SectionResult(
      sectionId: name,
      name: name,
      correct: correct,
      wrong: wrong,
      blank: blank,
      total: correct + wrong + blank,
      retiredCount: 0,
      timeSeconds: 0,
    );

// Items on the paper: Verbal 40 (20 right, 10 wrong, 10 blank), Analytical 20
// (10 right, 5 wrong, 5 blank), Numerical 30 (all right). General Information
// is not on the paper, so its 5 points of weight drop out, leaving 95.
final _worked = [
  _section('Verbal Ability', correct: 20, wrong: 10, blank: 10),
  _section('Analytical Ability', correct: 10, wrong: 5, blank: 5),
  _section('Numerical Ability', correct: 30, wrong: 0, blank: 0),
  _section('General Information', correct: 0, wrong: 0, blank: 0),
];

void main() {
  test('CSE Professional mock score is weighted, blanks count as wrong', () {
    // (30 * 20/40 + 35 * 10/20 + 30 * 30/30) / 95
    expect(
      mockScorePercent(examId: 'exam_cse_pro', sections: _worked),
      closeTo(62.5 / 95 * 100, 1e-9),
    );
  });

  test('other exams stay unweighted', () {
    // 60 correct of 90 items.
    for (final examId in ['exam_cse_sub', 'custom_track', null]) {
      expect(
        mockScorePercent(examId: examId, sections: _worked),
        closeTo(60 / 90 * 100, 1e-9),
        reason: '$examId',
      );
    }
    expect(
      mockScorePercent(examId: 'exam_upcat', sections: _worked),
      closeTo((60 - 15 / 4) / 90 * 100, 1e-9),
    );
  });

  test('a part left entirely blank counts as 0, it is not dropped', () {
    final sections = [
      _section('Verbal Ability', correct: 10, wrong: 0, blank: 0),
      _section('Analytical Ability', correct: 0, wrong: 0, blank: 10),
    ];
    // (30 * 1 + 35 * 0) / 65
    expect(
      mockScorePercent(examId: 'exam_cse_pro', sections: sections),
      closeTo(30 / 65 * 100, 1e-9),
    );
  });

  test('blanks inside a part lower it', () {
    final sections = [
      _section('Verbal Ability', correct: 10, wrong: 0, blank: 10),
    ];
    expect(
      mockScorePercent(examId: 'exam_cse_pro', sections: sections),
      closeTo(50, 1e-9),
    );
  });

  test('a section that is not one of the four parts is left out of the weights',
      () {
    final sections = [
      _section('Part 1', correct: 1, wrong: 3, blank: 0),
      _section('Verbal Ability', correct: 5, wrong: 5, blank: 0),
    ];
    expect(
      mockScorePercent(examId: 'exam_cse_pro', sections: sections),
      closeTo(50, 1e-9),
    );
  });

  test('no section maps to a part: the unweighted score stands', () {
    final sections = [_section('Part 1', correct: 1, wrong: 3, blank: 0)];
    expect(
      mockScorePercent(examId: 'exam_cse_pro', sections: sections),
      closeTo(25, 1e-9),
    );
  });

  test('a CSE Professional mock with no answers scores zero', () {
    final sections = [
      _section('Verbal Ability', correct: 0, wrong: 0, blank: 9),
    ];
    expect(mockScorePercent(examId: 'exam_cse_pro', sections: sections), 0);
  });

  test('results saved before this rule are read on the new scale', () {
    // The saved record holds counts only, not a percent, so its score is
    // worked out again each time it is read.
    final attempt = MockAttempt(
      id: 'old',
      userId: 'u',
      examId: 'exam_cse_pro',
      blueprintId: 'bp',
      blueprintName: 'CSE',
      durationMinutes: 190,
      status: MockAttemptStatus.completed,
      strictMode: false,
      sampledQuestionsJson: '[]',
      elapsedSeconds: 0,
      accumulatedPausedSeconds: 0,
      pausedAtLastFlush: false,
      answersJson: '{}',
      flagsJson: '[]',
      currentIndex: 0,
      startedAt: DateTime.utc(2026, 9),
      lastFlushedAt: DateTime.utc(2026, 9),
      updatedAt: DateTime.utc(2026, 9),
      scoreRaw: 60,
      scoreTotal: 90,
      totalTimeSeconds: 100,
      sectionResultsJson: jsonEncode({
        'sections': [
          for (final s in _worked)
            {
              'sectionId': s.sectionId,
              'name': s.name,
              'correct': s.correct,
              'total': s.total,
              'wrong': s.wrong,
              'blank': s.blank,
              'retiredCount': 0,
              'timeSeconds': 1,
            },
        ],
      }),
    );
    final decoded = decodeMockResults(attempt)!;
    expect(decoded.percent, closeTo(62.5 / 95 * 100, 1e-9));
    expect(decoded.scoreRaw, 60);
    expect(decoded.scoreTotal, 90);
  });

  test('sections saved without wrong and blank counts count by their total',
      () {
    const sections = [
      SectionResult(
        sectionId: 'a',
        name: 'Analytical Ability',
        correct: 15,
        total: 30,
        retiredCount: 0,
        timeSeconds: 0,
      ),
      SectionResult(
        sectionId: 'n',
        name: 'Numerical Ability',
        correct: 30,
        total: 30,
        retiredCount: 0,
        timeSeconds: 0,
      ),
    ];
    expect(
      mockScorePercent(examId: 'exam_cse_pro', sections: sections),
      closeTo((35 * .5 + 30) / 65 * 100, 1e-9),
    );
  });
}
