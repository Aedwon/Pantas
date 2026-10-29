import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/roadmap/domain/mastery_thresholds.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

@immutable
final class QuestionHistory {
  QuestionHistory({
    required this.id,
    required this.answered,
    required List<bool> recent,
    this.lastWrongChoiceId,
  }) : recent = List.unmodifiable(
          recent.skip(
            math.max(0, recent.length - MasteryThresholds.recentWindow),
          ),
        );

  final QuestionId id;
  final int answered;

  /// Oldest to newest. Server history follows ingest order, so late retries
  /// arrive last. Finish-order history would require ordered server ingestion.
  final List<bool> recent;
  final String? lastWrongChoiceId;

  static const _equality = ListEquality<bool>();

  @override
  bool operator ==(Object other) =>
      other is QuestionHistory &&
      id == other.id &&
      answered == other.answered &&
      _equality.equals(recent, other.recent) &&
      lastWrongChoiceId == other.lastWrongChoiceId;

  @override
  int get hashCode =>
      Object.hash(id, answered, _equality.hash(recent), lastWrongChoiceId);
}

enum MasteryKind { unseen, learning, weak, solid }

@immutable
final class LessonMastery {
  const LessonMastery({
    required this.id,
    required this.kind,
    required this.answered,
    required this.recentAccuracy,
    required this.recall,
  });

  final LessonId id;
  final MasteryKind kind;
  final int answered;
  final double? recentAccuracy;
  final double? recall;

  @override
  bool operator ==(Object other) =>
      other is LessonMastery &&
      id == other.id &&
      kind == other.kind &&
      answered == other.answered &&
      recentAccuracy == other.recentAccuracy &&
      recall == other.recall;

  @override
  int get hashCode => Object.hash(id, kind, answered, recentAccuracy, recall);
}

abstract final class Mastery {
  static Map<LessonId, LessonMastery> compute({
    required List<RoadmapLesson> lessons,
    required List<RoadmapQuestion> questions,
    required List<QuestionHistory> history,
    required Map<QuestionId, double> recall,
  }) {
    final histories = {for (final row in history) row.id: row};
    final byLesson = <LessonId, List<RoadmapQuestion>>{};
    for (final question in questions) {
      final id = question.lessonId;
      if (id != null) (byLesson[id] ??= []).add(question);
    }
    final result = <LessonId, LessonMastery>{};
    for (final lesson in lessons) {
      var answered = 0;
      var recentCount = 0;
      var correct = 0;
      var recallSum = 0.0;
      var recallCount = 0;
      for (final question in byLesson[lesson.id] ?? const <RoadmapQuestion>[]) {
        final row = histories[question.id];
        if (row != null) {
          answered += row.answered;
          recentCount += row.recent.length;
          correct += row.recent.where((correct) => correct).length;
        }
        final value = recall[question.id];
        if (value != null) {
          recallSum += value;
          recallCount++;
        }
      }
      final accuracy = recentCount == 0 ? null : correct / recentCount;
      final meanRecall = recallCount == 0 ? null : recallSum / recallCount;
      final kind = lesson.readAt == null && answered == 0
          ? MasteryKind.unseen
          : answered < MasteryThresholds.minimumAnswers
              ? MasteryKind.learning
              : math.min(accuracy ?? 1, meanRecall ?? 1) <
                      MasteryThresholds.solid
                  ? MasteryKind.weak
                  : MasteryKind.solid;
      result[lesson.id] = LessonMastery(
        id: lesson.id,
        kind: kind,
        answered: answered,
        recentAccuracy: accuracy,
        recall: meanRecall,
      );
    }
    return Map.unmodifiable(result);
  }
}
