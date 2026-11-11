import 'package:meta/meta.dart';

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
/// per wrong answer; blanks do not change the earned points.
double mockScorePercent({
  required String? examId,
  required Iterable<SectionResult> sections,
}) {
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
