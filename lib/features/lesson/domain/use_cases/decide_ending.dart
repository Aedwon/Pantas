import 'package:cse_cet_reviewer/features/lesson/domain/models/lesson_ending.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/models/study_map.dart';

LessonEnding decideEnding({
  required StudyTopic topic,
  required StudySubject subject,
  required String examShortName,
  required String? studentName,
  required DateTime today,
  required StudyTopic? nextTopic,
  int? dailyLessonCount,
}) {
  if (dailyLessonCount != null && dailyLessonCount <= 0) {
    return const DayFinished();
  }

  final total = topic.totalCount;
  final read = topic.readCount;
  final isFinished = topic.isComplete;
  final examAndSubject = '$examShortName, ${subject.name}';
  final dateLine = _formatDateLine(today);

  if (isFinished) {
    final footing =
        total == 1 ? '1 lesson, all read' : '$total lessons, all read';
    return TopicFinished(
      studentName: studentName,
      topicName: topic.name,
      examAndSubject: examAndSubject,
      footing: footing,
      dateLine: dateLine,
      next: nextTopic,
    );
  } else {
    final footing = '$read of $total lessons read';
    final unread = topic.lessons.where((l) => !l.isRead).toList();
    return TopicStoppedShort(
      studentName: studentName,
      topicName: topic.name,
      examAndSubject: examAndSubject,
      footing: footing,
      dateLine: dateLine,
      unread: unread,
    );
  }
}

String _formatDateLine(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final day = date.day;
  final monthName = months[date.month - 1];
  final year = date.year;
  return '$day $monthName $year';
}
