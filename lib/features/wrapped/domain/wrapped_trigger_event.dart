import 'package:meta/meta.dart';

@immutable
class WrappedTriggerEvent {
  const WrappedTriggerEvent({
    required this.artifactId,
    required this.examId,
    required this.userId,
    required this.firedAt,
    this.children = const [],
  });

  final String artifactId;
  final String examId;
  final String userId;
  final DateTime firedAt;
  final List<WrappedTriggerEvent> children;

  bool get isBatchable =>
      artifactId.startsWith('streak_milestone_') ||
      artifactId.startsWith('mastery_crossing_');

  @override
  bool operator ==(Object other) {
    return other is WrappedTriggerEvent &&
        other.artifactId == artifactId &&
        other.examId == examId &&
        other.userId == userId &&
        other.firedAt == firedAt &&
        _sameChildren(other.children, children);
  }

  @override
  int get hashCode => Object.hash(
        artifactId,
        examId,
        userId,
        firedAt,
        Object.hashAll(children),
      );
}

bool _sameChildren(
  List<WrappedTriggerEvent> a,
  List<WrappedTriggerEvent> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i += 1) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
