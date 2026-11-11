import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

/// What Home draws in place of, or around, the Today checklist.
enum HomeTodayKind {
  checklist,
  assessment,
  noContent,
  nothingDue,
  reviewOnly,
  dayOff,
  passed,
  examDay,
}

/// The line that closes a finished day when no advance is offered.
enum HomeDoneNote { reviewWeek, lastDay, plain }

class HomeTodayView {
  const HomeTodayView(this.kind, {this.doneNote, this.offersAdvance = false});
  final HomeTodayKind kind;
  final HomeDoneNote? doneNote;

  /// Day off only: advance is shown when it would add something, never
  /// drawn disabled.
  final bool offersAdvance;
}

/// Chooses the Today presentation from the stored plan alone. Pure, so the
/// native reader and the web reader share one rule (D-63, D-65).
HomeTodayView homeTodayViewFor({
  required RoadmapState state,
  required DayPlan plan,
  required bool originalDone,
  required bool canAdvance,
  required String examDate,
}) {
  switch (state) {
    case RoadmapState.noContent:
      return const HomeTodayView(HomeTodayKind.noContent);
    case RoadmapState.examPassedAwaitingAnswer:
      return const HomeTodayView(HomeTodayKind.passed);
    case RoadmapState.needsAssessment:
      return const HomeTodayView(HomeTodayKind.assessment);
    case RoadmapState.monthStartedAwaitingDay:
    case RoadmapState.planning:
    case RoadmapState.reviewOnly:
    case RoadmapState.allCovered:
      break;
  }
  final examDay = _examDay(examDate);
  final day = localDay(plan.day);
  if (examDay != null && examDay == day) {
    return const HomeTodayView(HomeTodayKind.examDay);
  }
  final hasWork = plan.lessonIds.isNotEmpty ||
      plan.reviewQuestionIds.isNotEmpty ||
      plan.newQuestionIds.isNotEmpty ||
      plan.isMockDay;
  if (!hasWork) {
    if (plan.isRestDay) {
      return HomeTodayView(HomeTodayKind.dayOff, offersAdvance: canAdvance);
    }
    return HomeTodayView(
      state == RoadmapState.reviewOnly
          ? HomeTodayKind.reviewOnly
          : HomeTodayKind.nothingDue,
    );
  }
  if (originalDone && !canAdvance) {
    final tomorrowIsExam =
        examDay != null && localDaysBetween(day, examDay) == 1;
    return HomeTodayView(
      HomeTodayKind.checklist,
      doneNote: tomorrowIsExam
          ? HomeDoneNote.lastDay
          : state == RoadmapState.reviewOnly
              ? HomeDoneNote.reviewWeek
              : HomeDoneNote.plain,
    );
  }
  return const HomeTodayView(HomeTodayKind.checklist);
}

/// The digest stores `2026-11-11:day`; a month-only date has no exam day.
DateTime? _examDay(String stored) {
  final parts = stored.split(':');
  if (parts.length != 2 || parts[1] != 'day') return null;
  final parsed = DateTime.tryParse(parts[0]);
  return parsed == null ? null : localDay(parsed);
}
