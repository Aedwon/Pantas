import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';

class WeaknessCandidate {
  const WeaknessCandidate({
    required this.question,
    required this.subtopicId,
    required this.rollingAccuracy,
    required this.attemptCount,
  });

  final Question question;
  final SubtopicId subtopicId;
  final double rollingAccuracy;
  final int attemptCount;
}

abstract final class WeaknessSelector {
  static const double weaknessThreshold = 0.4;
  static const int minAttempts = 5;

  static List<Question> select(List<WeaknessCandidate> candidates,
      {int? limit}) {
    final ranked = candidates
        .where((candidate) => candidate.attemptCount >= minAttempts)
        .where(
          (candidate) => 1 - candidate.rollingAccuracy >= weaknessThreshold,
        )
        .toList()
      ..sort((a, b) {
        final weaknessOrder = a.rollingAccuracy.compareTo(b.rollingAccuracy);
        if (weaknessOrder != 0) return weaknessOrder;
        return a.question.id.compareTo(b.question.id);
      });
    final selected = [for (final candidate in ranked) candidate.question];
    return limit == null ? selected : selected.take(limit).toList();
  }
}
