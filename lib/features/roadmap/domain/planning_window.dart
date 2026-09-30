import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/local_day.dart';
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
  });

  final RoadmapState state;
  final DateTime? examDay;
  final int daysLeft;
  final int quiet;
  final int workingDays;
  final DateTime? reviewOnlyFrom;

  @override
  bool operator ==(Object other) =>
      other is PlanningWindow &&
      state == other.state &&
      examDay == other.examDay &&
      daysLeft == other.daysLeft &&
      quiet == other.quiet &&
      workingDays == other.workingDays &&
      reviewOnlyFrom == other.reviewOnlyFrom;

  @override
  int get hashCode =>
      Object.hash(state, examDay, daysLeft, quiet, workingDays, reviewOnlyFrom);
}

abstract final class PlanningWindows {
  static PlanningWindow resolve({
    required DateTime today,
    required ExamDate? examDate,
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

    final quiet = math.min(7, daysLeft ~/ 4);
    return PlanningWindow(
      state: state,
      examDay: examDay,
      daysLeft: daysLeft,
      quiet: quiet,
      workingDays: daysLeft - quiet,
      reviewOnlyFrom:
          DateTime(examDay.year, examDay.month, examDay.day - quiet),
    );
  }

  static int perDay(int remaining, int workingDays) {
    if (workingDays <= 0) return 0;
    final whole = remaining ~/ workingDays;
    return whole + (remaining % workingDays == 0 ? 0 : 1);
  }
}
