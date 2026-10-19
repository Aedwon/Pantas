import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/question_set_mapper.dart';

void main() {
  const data = {
    'id': 'qs-x',
    'meta': {
      'subject': 'language-proficiency',
      'topic': 'language-application',
      'subtopic': 'paragraph-organization',
      'exams': ['upcat', 'cse-pro'],
    },
    'questions': [
      {
        'id': 'q-1',
        'stem': 'Which?\n',
        'explanation': 'Because.',
        'choices': [
          {'text': 'one', 'correct': true},
          {'text': 'two', 'rationale': 'note'},
        ],
      },
      {
        'id': 'q-2',
        'figure': 'pending',
        'stem': 's',
        'explanation': 'e',
        'choices': <Object>[],
      },
    ],
  };

  test('maps a served set to questions and skips figure-pending ones', () {
    final questions = questionsFromSet(data);
    expect(questions.map((q) => q.id), ['q-1']);
    final q = questions.single;
    expect(q.examIds, ['exam_upcat', 'exam_cse_pro']);
    expect(q.topicId, 'topic_upcat_language_application');
    expect(q.stem, 'Which?');
    expect(q.lessonId, 'lesson-language-application-paragraph-organization');
    expect(q.choices.map((c) => c.id).toSet(), {'q-1_a', 'q-1_b'});
    expect(q.choices.firstWhere((c) => c.id == 'q-1_b').rationale, 'note');
    expect(q.choices.firstWhere((c) => c.id == 'q-1_a').isCorrect, isTrue);
  });

  test('keeps a drawn figure spec as JSON', () {
    final questions = questionsFromSet({
      ...data,
      'questions': [
        {
          'id': 'q-3',
          'figure': 'x',
          'figureSpec': {'kind': 'bar'},
          'stem': 's',
          'explanation': 'e',
          'choices': [
            {'text': 'a', 'correct': true},
          ],
        },
      ],
    });
    expect(questions.single.figureSpecJson, '{"kind":"bar"}');
  });
}
