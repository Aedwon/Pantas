import 'package:meta/meta.dart';
import 'package:pantas/core/metrics/overall_accuracy.dart';

/// The middle band is "close to passing". "Borderline" is banned by the
/// copy register, so the code and the copy use the same word.
enum ScoreBand { pass, close, fail }

enum MissReason { misread, slipped, unknown, other }

enum BlankReason { ranOutOfTime, skippedToReturn, didNotKnow, other }

@immutable
class MockAnswer {
  const MockAnswer({
    required this.selectedIndex,
    required this.atSec,
    this.missReason,
    this.blankReason,
    this.reasonNote,
  });

  final int selectedIndex;
  final int atSec;
  final MissReason? missReason;
  final BlankReason? blankReason;
  final String? reasonNote;

  @override
  bool operator ==(Object other) {
    return other is MockAnswer &&
        other.selectedIndex == selectedIndex &&
        other.atSec == atSec &&
        other.missReason == missReason &&
        other.blankReason == blankReason &&
        other.reasonNote == reasonNote;
  }

  @override
  int get hashCode =>
      Object.hash(selectedIndex, atSec, missReason, blankReason, reasonNote);
}

class MockResults {
  const MockResults({
    required this.scoreRaw,
    required this.scoreTotal,
    required this.percent,
    required this.sections,
    required this.topWeak,
    required this.totalTimeSeconds,
    required this.wasStrict,
    this.band,
  });

  final int scoreRaw;
  final int scoreTotal;
  final double percent;

  /// Null when the exam has published no thresholds. An unpublished
  /// threshold is not a reason to invent one, so the results screen draws
  /// the score and omits the band line rather than printing "Fail".
  final ScoreBand? band;
  final List<SectionResult> sections;
  final List<WeakTopic> topWeak;
  final int totalTimeSeconds;
  final bool wasStrict;
}

class SectionResult {
  const SectionResult({
    required this.sectionId,
    required this.name,
    required this.correct,
    required this.total,
    required this.retiredCount,
    required this.timeSeconds,
    this.wrong,
    this.blank,
  });

  final String sectionId;
  final String name;
  final int correct;
  final int total;
  final int retiredCount;
  final int timeSeconds;
  // Null identifies results written before these counts existed.
  final int? wrong;
  final int? blank;

  double get accuracy => total == 0 ? 0 : correct / total;
}

class WeakTopic {
  const WeakTopic({
    required this.topicId,
    required this.correct,
    required this.total,
  });

  final String topicId;
  final int correct;
  final int total;

  double get accuracy => total == 0 ? 0 : correct / total;
  String get drillRoute => '/quiz/drill?topicId=$topicId';
}

/// Percent units, never a rounded stored decimal. UPCAT deducts a quarter
/// per wrong answer; blanks do not change the earned points. CSE Professional
/// weights its parts as Home's overall accuracy does (Aedwon, 28 November):
/// each part's correct over answered, a part with no answers dropping out.
/// Counts are all a saved result holds, so an old result is read the same way.
double mockScorePercent({
  required String? examId,
  required Iterable<SectionResult> sections,
}) {
  final parts = <String, ({CseExamPart area, int correct, int answered})>{};
  for (final section in sections) {
    final part = cseWeightedPartNamed(examId, section.name);
    if (part == null) continue;
    final before = parts[part.key];
    parts[part.key] = (
      area: part,
      correct: (before?.correct ?? 0) + section.correct,
      // A result saved without wrong counts has only its total to go on.
      answered: (before?.answered ?? 0) +
          (section.wrong == null
              ? section.total
              : section.correct + section.wrong!),
    );
  }
  if (parts.isNotEmpty) {
    return (OverallAccuracy.weighted(parts.values).value ?? 0) * 100;
  }
  var correct = 0;
  var wrong = 0;
  var total = 0;
  for (final section in sections) {
    correct += section.correct;
    wrong += section.wrong ?? 0;
    total += section.total;
  }
  if (total == 0) return 0;
  final earned = examId == 'exam_upcat' ? correct - wrong / 4 : correct;
  return earned / total * 100;
}
