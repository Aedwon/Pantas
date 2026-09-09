import 'package:pantas/core/storage/domain/ids.dart';

/// Lightweight question metadata used for selection, counting, and scoping.
///
/// Deliberately excludes stems, explanations, choices, rationales, and passage
/// bodies so quiz planning does not hydrate question content before the final
/// selected ids are known.
class QuestionSelectionRow {
  const QuestionSelectionRow({
    required this.id,
    required this.version,
    required this.topicId,
    required this.lessonId,
    required this.passageId,
    required this.hasFigure,
  });

  final QuestionId id;
  final int version;
  final TopicId topicId;
  final LessonId? lessonId;
  final PassageId? passageId;
  final bool hasFigure;
}
