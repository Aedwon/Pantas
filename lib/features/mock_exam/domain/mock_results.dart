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
