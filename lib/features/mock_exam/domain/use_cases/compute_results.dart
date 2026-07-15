import 'package:cse_cet_reviewer/core/content/domain/mock_blueprint.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_results.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_sample.dart';

class ComputeMockResults {
  MockResults call({
    required MockSample sample,
    required Map<String, Question> questionsById,
    required Map<String, MockAnswer> answers,
    required int totalTimeSeconds,
    required bool wasStrict,
    ScoreBands? scoreBands,
  }) {
    var scoreRaw = 0;
    var scoreTotal = 0;
    var previousSectionMax = 0;
    final sections = <SectionResult>[];
    final topicStats = <String, _TopicStats>{};

    for (final section in sample.sections) {
      var sectionCorrect = 0;
      var sectionTotal = 0;
      var retiredCount = 0;
      var sectionMaxAtSec = previousSectionMax;

      for (final questionId in section.questionIds) {
        final question = questionsById[questionId];
        final answer = answers[questionId];
        if (answer != null && answer.atSec > sectionMaxAtSec) {
          sectionMaxAtSec = answer.atSec;
        }
        if (question == null) {
          retiredCount += 1;
          continue;
        }

        final correctIndex = question.choices.indexWhere(
          (choice) => choice.isCorrect,
        );
        final isCorrect =
            answer != null && answer.selectedIndex == correctIndex;

        sectionTotal += 1;
        scoreTotal += 1;
        if (isCorrect) {
          sectionCorrect += 1;
          scoreRaw += 1;
        }
        topicStats
            .putIfAbsent(question.topicId, () => _TopicStats(question.topicId))
            .add(isCorrect: isCorrect);
      }

      sections.add(
        SectionResult(
          sectionId: section.sectionId,
          name: section.name,
          correct: sectionCorrect,
          total: sectionTotal,
          retiredCount: retiredCount,
          timeSeconds: sectionMaxAtSec - previousSectionMax,
        ),
      );
      previousSectionMax = sectionMaxAtSec;
    }

    final percent = scoreTotal == 0 ? 0.0 : (scoreRaw / scoreTotal) * 100;
    return MockResults(
      scoreRaw: scoreRaw,
      scoreTotal: scoreTotal,
      percent: percent,
      band: bandFor(
        scoreRaw: scoreRaw,
        scoreTotal: scoreTotal,
        scoreBands: scoreBands,
      ),
      sections: List.unmodifiable(sections),
      topWeak: _topWeak(topicStats),
      totalTimeSeconds: totalTimeSeconds,
      wasStrict: wasStrict,
    );
  }

  /// The thresholds are the exam's own, and they are content.
  ///
  /// The 75 and 60 here are the fallback Spec 5 names for an exam that has
  /// published none. They are not a claim about any particular exam, and
  /// no screen may present them as one.
  ScoreBand bandFor({
    required int scoreRaw,
    required int scoreTotal,
    ScoreBands? scoreBands,
  }) {
    if (scoreTotal == 0) return ScoreBand.fail;
    final passAt = scoreBands?.passAtPercent ?? 75;
    final closeAt = scoreBands?.closeAtPercent ?? 60;
    final percent = (scoreRaw / scoreTotal) * 100;
    if (percent >= passAt) return ScoreBand.pass;
    if (percent >= closeAt) return ScoreBand.borderline;
    return ScoreBand.fail;
  }

  List<WeakTopic> _topWeak(Map<String, _TopicStats> topicStats) {
    final weak = [
      for (final stat in topicStats.values)
        if (stat.total >= 2)
          WeakTopic(
            topicId: stat.topicId,
            correct: stat.correct,
            total: stat.total,
          ),
    ]..sort((a, b) {
        final accuracy = a.accuracy.compareTo(b.accuracy);
        return accuracy == 0 ? a.topicId.compareTo(b.topicId) : accuracy;
      });
    return List.unmodifiable(weak.take(3));
  }
}

class _TopicStats {
  _TopicStats(this.topicId);

  final String topicId;
  int correct = 0;
  int total = 0;

  void add({required bool isCorrect}) {
    total += 1;
    if (isCorrect) correct += 1;
  }
}
