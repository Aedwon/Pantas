import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/domain/picker/inline_lesson_picker.dart';
import 'package:pantas/features/quiz/domain/picker/pick_context.dart';
import 'package:pantas/features/quiz/domain/picker/retake_picker.dart';
import 'package:pantas/features/quiz/domain/picker/today_interleaved_picker.dart';
import 'package:pantas/features/quiz/domain/picker/today_topic_picker.dart';
import 'package:pantas/features/quiz/domain/selectors/subtopic_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TodayTopicPicker uses due weakness new composition with due cards', () {
    final picked = TodayTopicPicker().pick(
      PickContext(
        allQuestions: [_q('d1'), _q('d2'), _q('w1'), _q('n1')],
        dueQuestions: [_q('d1'), _q('d2')],
        weaknessQuestions: [_q('w1')],
        newQuestions: [_q('n1')],
        requestedLength: 4,
        topicId: 'topic',
      ),
    );

    expect(
      picked.map((question) => question.id),
      equals(['d1', 'd2', 'w1', 'n1']),
    );
  });

  test('TodayTopicPicker uses weakness and new composition with no due cards',
      () {
    final picked = TodayTopicPicker().pick(
      PickContext(
        allQuestions: [_q('w1'), _q('w2'), _q('n1')],
        weaknessQuestions: [_q('w1'), _q('w2')],
        newQuestions: [_q('n1')],
        requestedLength: 3,
        topicId: 'topic',
      ),
    );

    expect(picked.map((question) => question.id), equals(['w1', 'w2', 'n1']));
  });

  test('TodayInterleavedPicker avoids consecutive same-topic questions', () {
    final picked = TodayInterleavedPicker().pick(
      PickContext(
        allQuestions: [
          _q('a1', topicId: 'a'),
          _q('a2', topicId: 'a'),
          _q('b1', topicId: 'b'),
        ],
        dueQuestions: [
          _q('a1', topicId: 'a'),
          _q('a2', topicId: 'a'),
          _q('b1', topicId: 'b'),
        ],
        requestedLength: 3,
      ),
    );

    expect(picked[1].topicId, isNot(equals(picked[0].topicId)));
  });

  // DrillPicker no longer filters by subtopic. Both callers always passed a
  // null subtopic id, so the filter returned the pool in table order and the
  // row served the same ten questions forever. It now shuffles and excludes
  // what was answered this week: see drill_picker_test.dart.

  test('RetakePicker returns recent incorrect question ids in order', () {
    final picked = RetakePicker().pick(
      PickContext(
        allQuestions: [_q('q1'), _q('q2')],
        retakeQuestionIds: const ['q2', 'q1'],
        requestedLength: 50,
      ),
    );

    expect(picked.map((question) => question.id), equals(['q2', 'q1']));
  });

  test('InlineLessonPicker returns at most five questions from lesson subtopic',
      () {
    final picked = InlineLessonPicker().pick(
      PickContext(
        allQuestions: List.generate(6, (index) => _q('q$index')),
        subtopicCandidates: List.generate(
          6,
          (index) => SubtopicQuestion(
            question: _q('q$index'),
            subtopicId: 'synonyms',
          ),
        ),
        requestedLength: 5,
        subtopicId: 'synonyms',
      ),
    );

    expect(picked, hasLength(5));
  });
}

Question _q(String id, {String topicId = 'topic'}) => Question(
      id: id,
      version: 1,
      examIds: const ['exam'],
      topicId: topicId,
      language: 'en',
      stem: id,
      choices: const [
        Choice(id: 'a', label: 'A', text: 'A', isCorrect: true),
        Choice(id: 'b', label: 'B', text: 'B', isCorrect: false),
      ],
      explanation: 'Because.',
    );
