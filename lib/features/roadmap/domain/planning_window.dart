import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

@immutable
final class PlanningWindow {
  const PlanningWindow({
    required this.state,
    required this.examDay,
    required this.daysLeft,
    required this.quiet,
    required this.workingDays,
    required this.reviewOnlyFrom,
    this.studyDaysBeforeExam = 0,
  });

  final RoadmapState state;
  final DateTime? examDay;
  final int daysLeft;
  final int quiet;
  final int workingDays;
  final int studyDaysBeforeExam;
  final DateTime? reviewOnlyFrom;

  @override
  bool operator ==(Object other) =>
      other is PlanningWindow &&
      state == other.state &&
      examDay == other.examDay &&
      daysLeft == other.daysLeft &&
      quiet == other.quiet &&
      workingDays == other.workingDays &&
      studyDaysBeforeExam == other.studyDaysBeforeExam &&
      reviewOnlyFrom == other.reviewOnlyFrom;

  @override
  int get hashCode => Object.hash(
        state,
        examDay,
        daysLeft,
        quiet,
        workingDays,
        studyDaysBeforeExam,
        reviewOnlyFrom,
      );
}

abstract final class PlanningWindows {
  /// [anchoredReviewOnlyFrom] is the review-only start fixed when the plan
  /// for this exam date was first built. Recomputing the quiet stretch every
  /// day shrinks it as the exam nears (at 12 days left it is 3, at 4 it is
  /// 1), so a student who follows the plan exactly would get new material
  /// until the day before the exam. Keeping the first date holds the stretch.
  static PlanningWindow resolve({
    required DateTime today,
    required ExamDate? examDate,
    DateTime? anchoredReviewOnlyFrom,
    StudyDays studyDays = StudyDays.all,
    bool treatTodayAsStudyDay = false,
  }) {
    if (examDate == null) {
      return const PlanningWindow(
        state: RoadmapState.planning,
        examDay: null,
        daysLeft: 0,
        quiet: 0,
        workingDays: 0,
        reviewOnlyFrom: null,
      );
    }

    final day = localDay(today);
    DateTime examDay;
    var state = RoadmapState.planning;
    if (examDate.precision == ExamDatePrecision.day) {
      examDay = examDate.day!;
    } else if (day.isBefore(examDate.monthStart)) {
      examDay = examDate.monthStart;
    } else {
      examDay = DateTime(examDate.year, examDate.month + 1, 0);
      state = RoadmapState.monthStartedAwaitingDay;
    }

    final daysLeft = localDaysBetween(day, examDay);
    if (daysLeft <= 0) {
      return PlanningWindow(
        state: daysLeft < 0
            ? RoadmapState.examPassedAwaitingAnswer
            : RoadmapState.reviewOnly,
        examDay: examDay,
        daysLeft: daysLeft,
        quiet: 0,
        workingDays: 0,
        reviewOnlyFrom: examDay,
      );
    }

    final anchor = anchoredReviewOnlyFrom == null
        ? null
        : localDay(anchoredReviewOnlyFrom);
    int studyDaysBefore(DateTime end) =>
        studyDays.countInRange(day, end) +
        (treatTodayAsStudyDay && !studyDays.isStudyDay(day) && day.isBefore(end)
            ? 1
            : 0);
    final studyDaysBeforeExam = studyDaysBefore(examDay);
    if (anchor != null && !anchor.isAfter(examDay)) {
      final workingDays = studyDaysBefore(anchor);
      return PlanningWindow(
        state: !day.isBefore(anchor) && state == RoadmapState.planning
            ? RoadmapState.reviewOnly
            : state,
        examDay: examDay,
        daysLeft: daysLeft,
        quiet: localDaysBetween(anchor, examDay),
        workingDays: workingDays,
        studyDaysBeforeExam: studyDaysBeforeExam,
        reviewOnlyFrom: anchor,
      );
    }

    final quiet = math.min(7, daysLeft ~/ 4);
    final reviewOnlyFrom =
        DateTime(examDay.year, examDay.month, examDay.day - quiet);
    return PlanningWindow(
      state: state,
      examDay: examDay,
      daysLeft: daysLeft,
      quiet: quiet,
      workingDays: studyDaysBefore(reviewOnlyFrom),
      studyDaysBeforeExam: studyDaysBeforeExam,
      reviewOnlyFrom: reviewOnlyFrom,
    );
  }

  static int perDay(int remaining, int workingDays) {
    if (workingDays <= 0) return 0;
    final whole = remaining ~/ workingDays;
    return whole + (remaining % workingDays == 0 ? 0 : 1);
  }
}
