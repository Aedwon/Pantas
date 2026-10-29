import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/lesson_links.dart';
import 'package:pantas/features/roadmap/domain/lesson_mastery.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

enum AttributionVia { gapTag, requiredWeak }

final class MissAttribution {
  const MissAttribution({
    required this.prerequisite,
    required this.forLesson,
    required this.via,
  });

  final LessonId prerequisite;
  final LessonId forLesson;
  final AttributionVia via;
}

/// Shared by history-based planning and the single-session diagnosis.
final class FollowUp {
  FollowUp(RoadmapInputs inputs)
      : graph = LessonGraph.build(
          inputs.lessonLinks,
          inputs.lessons.map((lesson) => lesson.id),
        ),
        mastery = Mastery.compute(
          lessons: inputs.lessons,
          questions: inputs.questions,
          history: inputs.history,
          recall: inputs.recall,
        ),
        _questions = {for (final q in inputs.questions) q.id: q},
        _gapTags = inputs.gapTags;

  final LessonGraphResult graph;
  final Map<LessonId, LessonMastery> mastery;
  final Map<QuestionId, RoadmapQuestion> _questions;
  final Map<String, LessonId> _gapTags;

  MissAttribution? attribute(QuestionId questionId, String chosenChoiceId) {
    final lesson = _questions[questionId]?.lessonId;
    if (lesson == null || !mastery.containsKey(lesson)) return null;
    final tagged = _gapTags[chosenChoiceId];
    if (tagged != null && tagged != lesson && _unmet(tagged)) {
      return MissAttribution(
        prerequisite: LessonGraph.firstUnmet(tagged, graph, mastery) ?? tagged,
        forLesson: lesson,
        via: AttributionVia.gapTag,
      );
    }
    final required = LessonGraph.firstUnmet(lesson, graph, mastery);
    if (required == null) return null;
    return MissAttribution(
      prerequisite: required,
      forLesson: lesson,
      via: AttributionVia.requiredWeak,
    );
  }

  bool _unmet(LessonId id) =>
      mastery[id]?.kind == MasteryKind.unseen ||
      mastery[id]?.kind == MasteryKind.weak;

  Map<LessonId, LessonId> fromHistory(RoadmapInputs inputs) {
    final fixes = <LessonId, LessonId>{};
    final rows = inputs.history.toList()..sort((a, b) => a.id.compareTo(b.id));
    for (final row in rows) {
      final chosen = row.lastWrongChoiceId;
      if (chosen == null ||
          chosen.isEmpty ||
          row.recent.isEmpty ||
          row.recent.last) {
        continue;
      }
      final trace = attribute(row.id, chosen);
      if (trace != null && row.answered > 0) {
        fixes.putIfAbsent(trace.prerequisite, () => trace.forLesson);
      }
    }
    return fixes;
  }
}
