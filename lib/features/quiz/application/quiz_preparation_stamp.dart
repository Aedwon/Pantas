import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';

@immutable
class QuizPreparationStamp {
  const QuizPreparationStamp({
    required this.contentRevision,
    required this.accountLifetimeToken,
    required this.examId,
    required this.topicId,
    required this.scopeToken,
    required this.topicExclusionToken,
    required this.ordering,
    required this.sessionLength,
    required this.newCardCap,
    required this.historyRevision,
    required this.sessionStateRevision,
    required this.localDay,
    required this.nextDueExpiry,
  });

  final String contentRevision;
  final String accountLifetimeToken;
  final ExamId examId;
  final TopicId? topicId;
  final String scopeToken;
  final String topicExclusionToken;
  final SessionOrdering ordering;
  final int sessionLength;
  final int newCardCap;
  final String historyRevision;
  final String sessionStateRevision;
  final DateTime localDay;
  final DateTime? nextDueExpiry;

  bool isFreshAt(DateTime now) {
    if (now.year != localDay.year ||
        now.month != localDay.month ||
        now.day != localDay.day) {
      return false;
    }
    final dueBoundary = nextDueExpiry;
    return dueBoundary == null || now.isBefore(dueBoundary);
  }

  @override
  bool operator ==(Object other) {
    return other is QuizPreparationStamp &&
        other.contentRevision == contentRevision &&
        other.accountLifetimeToken == accountLifetimeToken &&
        other.examId == examId &&
        other.topicId == topicId &&
        other.scopeToken == scopeToken &&
        other.topicExclusionToken == topicExclusionToken &&
        other.ordering == ordering &&
        other.sessionLength == sessionLength &&
        other.newCardCap == newCardCap &&
        other.historyRevision == historyRevision &&
        other.sessionStateRevision == sessionStateRevision &&
        other.localDay == localDay &&
        other.nextDueExpiry == nextDueExpiry;
  }

  @override
  int get hashCode => Object.hash(
        contentRevision,
        accountLifetimeToken,
        examId,
        topicId,
        scopeToken,
        topicExclusionToken,
        ordering,
        sessionLength,
        newCardCap,
        historyRevision,
        sessionStateRevision,
        localDay,
        nextDueExpiry,
      );
}
