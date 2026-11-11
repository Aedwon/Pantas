import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/roadmap/domain/session_diagnosis.dart';

import 'follow_up_test.dart' show fixture;

void main() {
  test('Pro traces misses with positions and the chosen mistake note', () {
    final result = SessionDiagnosis.compute(
      inputs: fixture(),
      sessionAnswers: const [
        DiagnosisAnswer(
          questionId: 'lq',
          chosenChoiceId: 'lq_b',
          correct: true,
        ),
        DiagnosisAnswer(
          questionId: 'lq',
          chosenChoiceId: 'lq_a',
          correct: false,
        ),
        DiagnosisAnswer(
          questionId: 'pq',
          chosenChoiceId: 'pq_a',
          correct: false,
        ),
        DiagnosisAnswer(questionId: 'lq', chosenChoiceId: null, correct: false),
      ],
      mistakeNotes: const {'lq_a': 'Mistake note'},
      includeDetail: true,
    );
    expect(result.toJson(), {
      'tracedCount': 1,
      'traced': [
        {
          'prerequisite': 'p',
          'forLesson': 'l',
          'via': 'gapTag',
          'questions': [
            {'questionId': 'lq', 'position': 2, 'mistake': 'Mistake note'},
          ],
        },
      ],
      'withinLesson': [
        {
          'lesson': 'p',
          'questions': [
            {'questionId': 'pq', 'position': 3},
          ],
        },
      ],
    });
  });
  test('Free retains and serializes only the traced count', () {
    final result = SessionDiagnosis.compute(
      inputs: fixture(),
      sessionAnswers: const [
        DiagnosisAnswer(
          questionId: 'lq',
          chosenChoiceId: 'lq_a',
          correct: false,
        ),
      ],
      mistakeNotes: const {'lq_a': 'Secret note'},
      includeDetail: false,
    );
    expect(result.tracedCount, 1);
    expect(result.traced, isEmpty);
    expect(result.withinLesson, isEmpty);
    expect(jsonEncode(result.toJson()), '{"tracedCount":1}');
  });
}
