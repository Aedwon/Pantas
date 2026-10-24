import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/home/application/home_day_extras.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

DaySnapshot snapshot(DateTime day, {bool mock = false}) => DaySnapshot(
      plan: DayPlan(
        day: day,
        lessonIds: const ['l'],
        reviewQuestionIds: const [],
        newQuestionIds: const [],
        isMockDay: mock,
        advancedIds: const {},
      ),
      digest: RoadmapDigest(
        examId: 'e',
        examDate: '2026-11-11:day',
        scopeTopicIds: const [],
        contentRevision: 'v',
        assessmentCompleted: true,
        recordedMockCount: 0,
      ),
      topicOrderHead: const [],
    );

RoadmapChange change(RoadmapChangeCause cause, DateTime at) => RoadmapChange(
      cause: cause,
      occurredAt: at,
      firstTopicsBefore: const [],
      firstTopicsAfter: const [],
    );

void main() {
  final today = DateTime(2026, 10, 28);

  test('a missed-work entry written today with a stored day yesterday',
      () async {
    final extras = await readHomeDayExtras(
      today: snapshot(today),
      examShortName: 'UPCAT',
      studyDays: StudyDays.all,
      recentChanges: () async => [
        change(RoadmapChangeCause.missedWork, DateTime(2026, 10, 28, 6)),
      ],
      priorSnapshot: () async => snapshot(DateTime(2026, 10, 27)),
      mockDurationMinutes: () async => null,
    );
    expect(extras.note, HomeDayNote.carried);
    expect(extras.mock, isNull);
  });

  test("a missed-work entry from an earlier day is not today's note", () async {
    final extras = await readHomeDayExtras(
      today: snapshot(today),
      examShortName: 'UPCAT',
      studyDays: StudyDays.all,
      recentChanges: () async => [
        change(RoadmapChangeCause.missedWork, DateTime(2026, 10, 27, 6)),
      ],
      priorSnapshot: () async => snapshot(DateTime(2026, 10, 27)),
      mockDurationMinutes: () async => null,
    );
    expect(extras.note, isNull);
  });

  test('mock day carries the blueprint duration and the moved line', () async {
    final extras = await readHomeDayExtras(
      today: snapshot(today, mock: true),
      examShortName: 'UPCAT',
      studyDays: StudyDays.all,
      recentChanges: () async => const [],
      priorSnapshot: () async => snapshot(DateTime(2026, 10, 27), mock: true),
      mockDurationMinutes: () async => 165,
    );
    expect(extras.note, HomeDayNote.mockMoved);
    expect(extras.mock?.subtitle, 'UPCAT simulation');
    expect(extras.mock?.duration, '2 hr 45 min');
  });

  test('no blueprint keeps the row but never invents a duration', () async {
    final extras = await readHomeDayExtras(
      today: snapshot(today, mock: true),
      examShortName: 'UPCAT',
      studyDays: StudyDays.all,
      recentChanges: () async => const [],
      priorSnapshot: () async => null,
      mockDurationMinutes: () async => null,
    );
    expect(extras.mock?.duration, isNull);
  });
}
