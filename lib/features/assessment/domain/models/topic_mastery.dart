import 'package:pantas/core/storage/domain/topic.dart';

enum MasteryLevel { weak, moderate, strong }

class TopicMastery {
  const TopicMastery({
    required this.topic,
    required this.correct,
    required this.total,
  });

  final Topic topic;
  final int correct;
  final int total;

  double get accuracy => total == 0 ? 0 : correct / total;

  MasteryLevel get level {
    final pct = accuracy * 100;
    if (pct <= 40) return MasteryLevel.weak;
    if (pct <= 70) return MasteryLevel.moderate;
    return MasteryLevel.strong;
  }
}
