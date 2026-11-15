import 'dart:convert';

import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/choice_order.dart';
import 'package:pantas/core/storage/domain/question.dart';

String _underscore(String slug) => slug.replaceAll('-', '_');

/// The lesson a served question belongs to: its own `lesson` (split content
/// names the part), else the one derived from its set's topic and subtopic.
/// A lesson that has been retired resolves through `replacedBy[0]`, the same
/// rule as the exporter and the server. [replacements] maps each retired
/// lesson id to its first replacement.
///
/// [knownLessons] is the set of lesson ids the client's catalog lists. A
/// catalog cached before a split does not list the new parts. When the named
/// lesson is not in a non-empty [knownLessons], the question counts under the
/// lesson its file's topic and subtopic give (the old original), so a stale
/// client still finds its questions. The catalog refresh later moves them to
/// their parts.
String resolveQuestionLesson({
  required String? lesson,
  required String topicSlug,
  required String subtopicSlug,
  required Map<String, String> replacements,
  Set<String>? knownLessons,
}) {
  final derived = 'lesson-$topicSlug-$subtopicSlug';
  var id = _followReplacements(lesson ?? derived, replacements);
  if (lesson != null &&
      knownLessons != null &&
      knownLessons.isNotEmpty &&
      !knownLessons.contains(id)) {
    id = _followReplacements(derived, replacements);
  }
  return id;
}

String _followReplacements(String start, Map<String, String> replacements) {
  var id = start;
  final seen = <String>{};
  while (replacements.containsKey(id) && seen.add(id)) {
    id = replacements[id]!;
  }
  return id;
}

/// The key point number a question tests, when the served question names one.
int? questionKeyPoint(Map<String, Object?> question) {
  final value = question['keyPoint'];
  return value is num ? value.toInt() : null;
}

/// Maps a question set served by `getContent` to the app's [Question]s, with
/// the same ids and ordering the bundled content builder produces. Questions
/// whose figure is not drawn yet are skipped, as in the bundled content.
List<Question> questionsFromSet(
  Map<String, Object?> data, {
  Map<String, String> replacements = const {},
  Set<String>? knownLessons,
}) {
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
        lessonId: resolveQuestionLesson(
          lesson: question['lesson'] as String?,
          topicSlug: topicSlug,
          subtopicSlug: subtopicSlug,
          replacements: replacements,
          knownLessons: knownLessons,
        ),
        keyPoint: questionKeyPoint(question),
        shortLabel: question['shortLabel'] as String?,
        figureSpecJson: spec == null ? null : jsonEncode(spec),
      ),
    );
  }
  return out;
}
