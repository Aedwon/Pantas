import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/roadmap/domain/roadmap_inputs.dart';

abstract final class MockDay {
  static DateTime? place({
    required DateTime today,
    required DateTime? examDay,
    required DateTime? reviewOnlyFrom,
    required RoadmapMockFacts mock,
    required bool mockSubmittedInWindow,
    StudyDays studyDays = StudyDays.all,
  }) {
    if (!mock.examHasMock ||
        examDay == null ||
        reviewOnlyFrom == null ||
        mockSubmittedInWindow) {
      return null;
    }

    final day = localDay(today);
    final exam = localDay(examDay);
    if (localDaysBetween(day, exam) < 2) return null;

    final sixDaysBefore = DateTime(exam.year, exam.month, exam.day - 6);
    final windowStart = day.isAfter(sixDaysBefore) ? day : sixDaysBefore;
    final windowEnd = DateTime(exam.year, exam.month, exam.day - 1);
    var target = localDay(reviewOnlyFrom);
    if (target.isBefore(windowStart)) target = windowStart;
    if (target.isAfter(windowEnd)) target = windowEnd;

    DateTime? firstStudyDay(DateTime from) => studyDays.isStudyDay(from)
        ? (from.isAfter(windowEnd) ? null : from)
        : studyDays.nextAfter(from, before: exam);
    var placed = firstStudyDay(target);
    if (placed == null) {
      for (var earlier = DateTime(target.year, target.month, target.day - 1);
          !earlier.isBefore(windowStart);
          earlier = DateTime(earlier.year, earlier.month, earlier.day - 1)) {
        if (studyDays.isStudyDay(earlier)) {
          placed = earlier;
          break;
        }
      }
    }
    if (placed == null) return null;

    final lastSubmittedAt = mock.lastSubmittedAt;
    if (!mock.proIsActive && lastSubmittedAt != null) {
      final submittedDay = localDay(lastSubmittedAt);
      final nextAllowed = DateTime(
        submittedDay.year,
        submittedDay.month,
        submittedDay.day + 14,
      );
      if (placed.isBefore(nextAllowed)) {
        if (nextAllowed.isAfter(windowEnd)) return null;
        placed = firstStudyDay(nextAllowed);
      }
    }

    return placed;
  }
}
