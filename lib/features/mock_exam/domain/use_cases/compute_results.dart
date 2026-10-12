import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_sample.dart';

class ComputeMockResults {
  MockResults call({
    required MockSample sample,
    required Map<String, Question> questionsById,
    required Map<String, MockAnswer> answers,
    required int totalTimeSeconds,
    required bool wasStrict,
    required ScoreBands? scoreBands,
    String? examId,
  }) {
    var scoreRaw = 0;
    var scoreTotal = 0;
    var previousSectionMax = 0;
    final sections = <SectionResult>[];
    final topicStats = <String, _TopicStats>{};

    for (final section in sample.sections) {
      var sectionCorrect = 0;
      var sectionTotal = 0;
      var sectionWrong = 0;
      var sectionBlank = 0;
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
        } else if (answer == null || answer.selectedIndex < 0) {
          sectionBlank += 1;
        } else {
          sectionWrong += 1;
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
          wrong: sectionWrong,
          blank: sectionBlank,
          retiredCount: retiredCount,
          timeSeconds: sectionMaxAtSec - previousSectionMax,
        ),
      );
      previousSectionMax = sectionMaxAtSec;
    }

    final percent = mockScorePercent(examId: examId, sections: sections);
    return MockResults(
      scoreRaw: scoreRaw,
      scoreTotal: scoreTotal,
      percent: percent,
      band: bandFor(
        scoreRaw: scoreRaw,
        scoreTotal: scoreTotal,
        scoreBands: scoreBands,
        percent: percent,
      ),
      sections: List.unmodifiable(sections),
      topWeak: _topWeak(topicStats),
      totalTimeSeconds: totalTimeSeconds,
      wasStrict: wasStrict,
    );
  }

  /// Thresholds are content, per exam. The 75 and 60 that used to sit here
  /// were a stand-in the 17 May spec named as such. A blueprint that
  /// publishes no bands gets no band printed: an unpublished threshold is
  /// not a reason to invent one.
  ScoreBand? bandFor({
    required int scoreRaw,
    required int scoreTotal,
    required ScoreBands? scoreBands,
    double? percent,
  }) {
    if (scoreBands == null || scoreTotal == 0) return null;
    final value = percent ?? (scoreRaw / scoreTotal) * 100;
    if (value >= scoreBands.passAtPercent) return ScoreBand.pass;
    if (value >= scoreBands.closeAtPercent) return ScoreBand.close;
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
