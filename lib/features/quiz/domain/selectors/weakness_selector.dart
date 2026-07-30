import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';

/// One question offered to the weakness reading, carrying **its topic's**
/// recent record rather than its own.
///
/// The two figures are the topic's because a question is rarely answered five
/// times, so a per-question reading of [WeaknessSelector.minAttempts] would
/// never fire and the count would print 0 forever. Settled 2 August.
///
/// This field was `subtopicId` and was never assigned anything but null.
/// Subtopics do not exist in this app: the levels are subject, topic, lesson.
class WeaknessCandidate {
  const WeaknessCandidate({
    required this.question,
    required this.topicId,
    required this.rollingAccuracy,
    required this.attemptCount,
  });

  final Question question;
  final TopicId topicId;

  /// The topic's share of correct answers in the recent window, 0 to 1.
  final double rollingAccuracy;

  /// How many questions in the topic were answered in the recent window.
  final int attemptCount;
}

abstract final class WeaknessSelector {
  static const double weaknessThreshold = 0.4;
  static const int minAttempts = 5;

  static List<Question> select(
    List<WeaknessCandidate> candidates, {
    int? limit,
  }) {
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
