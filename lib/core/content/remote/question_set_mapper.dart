import 'dart:convert';

import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/choice_order.dart';
import 'package:pantas/core/storage/domain/question.dart';

String _underscore(String slug) => slug.replaceAll('-', '_');

/// Maps a question set served by `getContent` to the app's [Question]s, with
/// the same ids and ordering the bundled content builder produces. Questions
/// whose figure is not drawn yet are skipped, as in the bundled content.
List<Question> questionsFromSet(Map<String, Object?> data) {
  final meta = (data['meta']! as Map).cast<String, Object?>();
  final topicSlug = '${meta['topic']}';
  final subtopicSlug = '${meta['subtopic']}';
  final examIds = [
    for (final code in (meta['exams'] as List? ?? const []))
      'exam_${_underscore('$code')}',
  ];
  final out = <Question>[];
  for (final raw in (data['questions'] as List? ?? const [])) {
    final question = (raw as Map).cast<String, Object?>();
    final figure = question['figure'];
    final spec = question['figureSpec'];
    if (figure != null && '$figure'.trim().isNotEmpty && spec == null) continue;
    final id = question['id']! as String;
    final choices = question['choices'] as List? ?? const [];
    const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
    out.add(
      Question(
        id: id,
        version: 1,
        examIds: examIds,
        topicId: 'topic_upcat_${_underscore(topicSlug)}',
        language: 'en',
        stem: '${question['stem']}'.trim(),
        choices: orderChoicesFor(id, [
          for (var i = 0; i < choices.length; i++)
            Choice(
              id: '${id}_${labels[i].toLowerCase()}',
              label: labels[i],
              text: '${(choices[i] as Map)['text']}'.trim(),
              isCorrect: (choices[i] as Map)['correct'] == true,
              rationale: (choices[i] as Map)['rationale'] == null
                  ? null
                  : '${(choices[i] as Map)['rationale']}'.trim(),
            ),
        ]),
        explanation: '${question['explanation']}'.trim(),
        lessonId: 'lesson-$topicSlug-$subtopicSlug',
        shortLabel: question['shortLabel'] as String?,
        figureSpecJson: spec == null ? null : jsonEncode(spec),
      ),
    );
  }
  return out;
}
