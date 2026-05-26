import 'package:meta/meta.dart';

enum ScoreBand { pass, borderline, fail }

@immutable
class MockAnswer {
  const MockAnswer({
    required this.selectedIndex,
    required this.atSec,
  });

  final int selectedIndex;
  final int atSec;

  @override
  bool operator ==(Object other) {
    return other is MockAnswer &&
        other.selectedIndex == selectedIndex &&
        other.atSec == atSec;
  }

  @override
  int get hashCode => Object.hash(selectedIndex, atSec);
}

class MockResults {
  const MockResults({
    required this.scoreRaw,
    required this.scoreTotal,
    required this.percent,
    required this.band,
    required this.sections,
    required this.topWeak,
    required this.totalTimeSeconds,
    required this.wasStrict,
  });

  final int scoreRaw;
  final int scoreTotal;
  final double percent;
  final ScoreBand band;
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
  });

  final String sectionId;
  final String name;
  final int correct;
  final int total;
  final int retiredCount;
  final int timeSeconds;

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
