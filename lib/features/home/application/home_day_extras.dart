import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/home/domain/home_mock_row.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

/// The facts around today's plan that Home prints: the calm line above
/// Today and the mock row's duration.
class HomeDayExtras {
  const HomeDayExtras({this.note, this.mock});
  final HomeDayNote? note;
  final HomeMockRow? mock;
}

/// Reads those facts from the stored change log, the previous stored plan and
/// the exam's mock blueprint. Sources are passed in so the native loader and
/// the later web reader share one rule.
Future<HomeDayExtras> readHomeDayExtras({
  required DaySnapshot today,
  required String examShortName,
  required StudyDays studyDays,
  required Future<List<RoadmapChange>> Function() recentChanges,
  required Future<DaySnapshot?> Function() priorSnapshot,
  required Future<int?> Function() mockDurationMinutes,
}) async {
  final day = localDay(today.plan.day);
  final prior = await priorSnapshot();
  final missed = (await recentChanges()).any(
    (change) =>
        change.cause == RoadmapChangeCause.missedWork &&
        localDay(change.occurredAt) == day,
  );
  final minutes = today.plan.isMockDay ? await mockDurationMinutes() : null;
  return HomeDayExtras(
    note: homeDayNoteFor(
      day: day,
      isMockDay: today.plan.isMockDay,
      priorDay: prior?.day,
      priorWasMockDay: prior?.plan.isMockDay ?? false,
      missedWorkToday: missed,
      studyDays: studyDays,
    ),
    mock: today.plan.isMockDay
        ? minutes == null
            ? HomeMockRow(subtitle: '$examShortName simulation')
            : HomeMockRow.fromBlueprint(
                examShortName: examShortName,
                durationMinutes: minutes,
              )
        : null,
  );
}
