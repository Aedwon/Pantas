import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/follow_up.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

final class DiagnosisAnswer {
  const DiagnosisAnswer({
    required this.questionId,
    required this.chosenChoiceId,
    required this.correct,
  });
  final QuestionId questionId;
  final String? chosenChoiceId;
  final bool correct;
}

final class SessionDiagnosisResult {
  SessionDiagnosisResult({
    required this.tracedCount,
    required this.includeDetail,
    List<Map<String, Object?>> traced = const [],
    List<Map<String, Object?>> withinLesson = const [],
  })  : traced = List.unmodifiable(traced),
        withinLesson = List.unmodifiable(withinLesson);
  final int tracedCount;
  final bool includeDetail;
  final List<Map<String, Object?>> traced;
  final List<Map<String, Object?>> withinLesson;
  Map<String, Object?> toJson() => {
        'tracedCount': tracedCount,
        if (includeDetail) 'traced': traced,
        if (includeDetail) 'withinLesson': withinLesson,
      };
}

abstract final class SessionDiagnosis {
  static SessionDiagnosisResult compute({
    required RoadmapInputs inputs,
    required List<DiagnosisAnswer> sessionAnswers,
    required Map<String, String> mistakeNotes,
    required bool includeDetail,
  }) {
    final attribution = FollowUp(inputs);
    final lessons = {for (final q in inputs.questions) q.id: q.lessonId};
    final traced =
        <(LessonId, LessonId, AttributionVia), List<Map<String, Object?>>>{};
    final within = <LessonId, List<Map<String, Object?>>>{};
    var tracedCount = 0;
    for (var i = 0; i < sessionAnswers.length; i++) {
      final answer = sessionAnswers[i];
      final chosen = answer.chosenChoiceId;
      if (answer.correct || chosen == null || chosen.isEmpty) continue;
      final lesson = lessons[answer.questionId];
      if (lesson == null) continue;
      final trace = attribution.attribute(answer.questionId, chosen);
      if (trace != null) tracedCount++;
      // Free never constructs or retains question ids or mistake notes.
      if (!includeDetail) continue;
      final question = <String, Object?>{
        'questionId': answer.questionId,
        'position': i + 1,
        if (trace != null && mistakeNotes[chosen] != null)
          'mistake': mistakeNotes[chosen],
      };
      if (trace == null) {
        (within[lesson] ??= []).add(question);
      } else {
        (traced[(trace.prerequisite, trace.forLesson, trace.via)] ??= [])
            .add(question);
      }
    }
    return SessionDiagnosisResult(
      tracedCount: tracedCount,
      includeDetail: includeDetail,
      traced: [
        for (final entry in traced.entries)
          Map.unmodifiable({
            'prerequisite': entry.key.$1,
            'forLesson': entry.key.$2,
            'via': entry.key.$3.name,
            'questions': List<Map<String, Object?>>.unmodifiable(
              entry.value.map(Map<String, Object?>.unmodifiable),
            ),
          }),
      ],
      withinLesson: [
        for (final entry in within.entries)
          Map.unmodifiable({
            'lesson': entry.key,
            'questions': List<Map<String, Object?>>.unmodifiable(
              entry.value.map(Map<String, Object?>.unmodifiable),
            ),
          }),
      ],
    );
  }
}
