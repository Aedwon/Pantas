import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PaceReading {
  const PaceReading({
    required this.lessonsRead,
    required this.lessonsTotal,
    required this.daysLeft,
    required this.lessonsPerWeek,
    required this.daysPastExam,
    required this.rateToFinishInTime,
  });

  /// T1. Rows in lesson_progress_local against lessons, for this exam.
  final int lessonsRead;
  final int lessonsTotal;

  /// Null when the student gave no date, or gave only a month. A day count
  /// derived from a month is a figure made of a measurement and an
  /// assumption.
  final int? daysLeft;

  /// T1. The student's own rate over the last 28 days, rounded to a whole
  /// number for the sentence. Null below the sample floor.
  final int? lessonsPerWeek;

  /// How many days past the exam the current rate finishes. Null when it
  /// finishes in time, when there is no date, or when there is no rate.
  /// Positive only.
  final int? daysPastExam;

  /// The whole number of lessons a week that closes the gap. Null whenever
  /// [daysPastExam] is null.
  final int? rateToFinishInTime;

  @override
  String toString() {
    return 'PaceReading(lessonsRead: $lessonsRead, '
        'lessonsTotal: $lessonsTotal, daysLeft: $daysLeft, '
        'lessonsPerWeek: $lessonsPerWeek, daysPastExam: $daysPastExam, '
        'rateToFinishInTime: $rateToFinishInTime)';
  }
}

final paceProvider = FutureProvider<PaceReading?>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final contentDb = ref.watch(contentDatabaseProvider);
  final focus = await ref.watch(activeExamFocusProvider.future);
  final exam = focus.exam;
  if (exam == null) return null;

  // Total lessons for this exam
  final subjectRows = await (contentDb.select(contentDb.contentSubjects)
        ..where((s) => s.examId.equals(exam.id)))
      .get();
  final subjectIds = subjectRows.map((s) => s.id).toList();
  if (subjectIds.isEmpty) {
    return const PaceReading(
      lessonsRead: 0,
      lessonsTotal: 0,
      daysLeft: null,
      lessonsPerWeek: null,
      daysPastExam: null,
      rateToFinishInTime: null,
    );
  }

  final topicRows = await (contentDb.select(contentDb.contentTopics)
        ..where((t) => t.subjectId.isIn(subjectIds)))
      .get();
  final topicIds = topicRows.map((t) => t.id).toList();
  if (topicIds.isEmpty) {
    return const PaceReading(
      lessonsRead: 0,
      lessonsTotal: 0,
      daysLeft: null,
      lessonsPerWeek: null,
      daysPastExam: null,
      rateToFinishInTime: null,
    );
  }

  final lessonRows = await (contentDb.select(contentDb.contentLessons)
        ..where((l) => l.topicId.isIn(topicIds)))
      .get();
  final lessonsTotal = lessonRows.length;
  final lessonIds = lessonRows.map((l) => l.id).toSet();

  if (lessonIds.isEmpty) {
    return const PaceReading(
      lessonsRead: 0,
      lessonsTotal: 0,
      daysLeft: null,
      lessonsPerWeek: null,
      daysPastExam: null,
      rateToFinishInTime: null,
    );
  }

  final progressRows = await (db.select(db.lessonProgressLocal)
        ..where((p) => p.lessonId.isIn(lessonIds)))
      .get();
  final lessonsRead = progressRows.length;

  // Days left from exam date
  final userSettings = await ref.watch(userSettingsProvider.future);
  final examDate = userSettings.examDate;
  int? daysLeft;
  if (examDate != null && examDate.precision == ExamDatePrecision.day) {
    daysLeft = examDate.daysUntil(DateTime.now());
  }

  // Sample floor and rate calculation over last 28 days
  final now = DateTime.now();
  int? lessonsPerWeek;
  if (progressRows.isNotEmpty) {
    // Find the earliest read date among all read lessons
    final firstReadAt = progressRows
        .map((p) => p.readAt)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    if (now.difference(firstReadAt).inDays >= 7) {
      final twentyEightDaysAgo = now.subtract(const Duration(days: 28));
      final count28 = progressRows
          .where((p) => !p.readAt.isBefore(twentyEightDaysAgo))
          .length;
      lessonsPerWeek = (count28 / 4.0).round();
    }
  }

  // Arithmetic calculation for daysPastExam and rateToFinishInTime
  int? daysPastExam;
  int? rateToFinishInTime;

  if (lessonsPerWeek != null && lessonsPerWeek > 0 && daysLeft != null) {
    final remaining = lessonsTotal - lessonsRead;
    if (remaining > 0) {
      final weeksNeeded = remaining / lessonsPerWeek;
      final daysNeeded = weeksNeeded * 7.0;
      final overshoot = daysNeeded - daysLeft;
      if (overshoot > 0) {
        daysPastExam = overshoot.ceil();
        final weeksLeft = daysLeft / 7.0;
        rateToFinishInTime = (remaining / weeksLeft).ceil();
      }
    }
  }

  return PaceReading(
    lessonsRead: lessonsRead,
    lessonsTotal: lessonsTotal,
    daysLeft: daysLeft,
    lessonsPerWeek: lessonsPerWeek,
    daysPastExam: daysPastExam,
    rateToFinishInTime: rateToFinishInTime,
  );
});
