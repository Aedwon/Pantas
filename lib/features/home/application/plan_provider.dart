import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/local_day.dart';
import 'package:pantas/features/home/application/plan_data.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/plan_history_reader.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/quiz/application/quiz_launch_guard.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';
import 'package:pantas/features/roadmap/domain/week_preview.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

class PlanView {
  const PlanView({
    required this.done,
    required this.total,
    required this.nodes,
    required this.history,
    this.subtitle,
    this.next,
    this.state = RoadmapState.planning,
  });
  final RoadmapState state;
  final int done;
  final int total;
  final List<PlanNode> nodes;
  final List<PlanHistoryEntry> history;
  final String? subtitle;
  final Map<String, Object?>? next;
}

class PlanDayView {
  const PlanDayView({
    required this.date,
    required this.plan,
    required this.remaining,
    required this.lessons,
    required this.kind,
    this.readLessonIds = const {},
  });
  final DateTime date;
  final DayPlan? plan;
  final DayPlan? remaining;
  final List<HomeTodayLesson> lessons;
  final String kind;
  final Set<String> readLessonIds;
}

/// Each publication is bound to the original request, including hydration.
final planViewProvider =
    FutureProvider.autoDispose.family<PlanView, int>((ref, limit) async {
  ref.watch(roadmapRevisionProvider);
  await ref.watch(studyCoreEpochProvider.future);
  await ref.watch(authStateProvider.future);
  final exam = (await ref.watch(activeExamFocusProvider.future)).exam;
  if (exam == null) throw StateError('Plan exam unavailable');
  var alive = true;
  ref.onDispose(() => alive = false);
  final guard =
      await captureQuizLaunchGuard(ref, examId: exam.id, isAlive: () => alive);
  final server = ref.watch(studyUsesServerProvider);
  final pro = ref.watch(currentStudyCoverageProvider);
  final now = localDay(ref.read(nowProvider)().toLocal());
  final settings = await ref.watch(userSettingsProvider.future);
  final days = settings.examDate?.daysUntil(now);
  final subtitle = days != null && days >= 0
      ? '$days ${days == 1 ? 'day' : 'days'} until ${exam.shortName}'
      : null;
  final nodes = <PlanNode>[];
  final history = <PlanHistoryEntry>[];
  Map<String, Object?>? next;
  late RoadmapState state;
  late DayPlan today;
  late DayPlan remaining;
  DateTime? examDay;
  DateTime? reviewDay;
  DateTime? mockDay;
  final weeks = <WeekPreview>[];
  final changes = <RoadmapChange>[];
  if (server) {
    final current = await ref.watch(serverStudyRoadmapProvider(exam.id).future);
    state = current.state;
    today = current.today;
    remaining = current.remaining;
    if (pro && current.proCovered) {
      final reader =
          await ref.watch(studySnapshotReaderProvider(exam.id).future);
      final raw =
          await reader.request.read('getRoadmap', payload: {'historyLimit': 5});
      final value = StudyRoadmap.decode(raw, examId: exam.id);
      final upcoming = value.comingUp;
      if (upcoming != null) {
        examDay = _date(upcoming['examDay']);
        reviewDay = _date(upcoming['reviewOnlyFrom']);
        mockDay = _date(upcoming['mockDay']);
        for (final row in studyRows(upcoming['weeksAhead'])) {
          weeks.add(
            WeekPreview(
              weekStart: studyDay(row['weekStart']),
              topicIds: (row['topicIds']! as List).cast<String>(),
            ),
          );
        }
      }
      final stored = await readPlanHistory(reader.request, wanted: limit);
      for (final row in studyRows(stored['changes'])) {
        final cause =
            RoadmapChangeCause.values.byName(studyString(row['cause']));
        changes.add(
          RoadmapChange(
            cause: cause,
            occurredAt: DateTime.parse(studyString(row['occurredAt'])),
            firstTopicsBefore: const [],
            firstTopicsAfter: const [],
            advancedCompleted: row['advancedCompleted'] as int?,
          ),
        );
      }
      if (stored['next'] != null) next = studyMap(stored['next']);
    }
  } else {
    final current = await ref.watch(roadmapTodayProvider(exam.id).future);
    state = current.state;
    today = current.snapshot.plan;
    remaining = current.remaining;
    if (pro) {
      final inputs = await ref.read(roadmapInputsReaderProvider).inputs(
            exam.id,
            now,
            anchoredReviewOnlyFrom: current.snapshot.reviewOnlyFrom,
          );
      final roadmap = ref.read(roadmapBuilderProvider)(inputs);
      examDay = roadmap.examDay;
      reviewDay = roadmap.reviewOnlyFrom;
      mockDay = roadmap.mockDay;
      weeks.addAll(roadmap.weeksAhead);
      changes.addAll(
        await ref
            .read(roadmapChangeLogRepositoryProvider)
            .recent(exam.id, limit: limit + 1),
      );
      if (changes.length > limit) next = const {};
    }
  }
  if (!pro) examDay = settings.examDate?.day;
  final content = ref.read(contentDatabaseProvider);
  final topicIds = weeks.expand((w) => w.topicIds).toSet();
  final topics = await (content.select(content.contentTopics)
        ..where((t) => t.id.isIn(topicIds)))
      .get();
  final names = {for (final t in topics) t.id: t.name};
  for (final week in weeks) {
    if (!week.topicIds.every(names.containsKey)) {
      throw StateError('Plan topic unavailable');
    }
    nodes.add(
      PlanNode(
        kind: PlanNodeKind.week,
        title: planWeekTitle(week.weekStart),
        subtitle: week.topicIds.map((id) => names[id]!).join(', '),
        target: dayKey(week.weekStart),
        date: planWeekLabel(now, week.weekStart),
      ),
    );
  }
  String date(DateTime d) => DateFormat('EEE, MMM d', 'en_US').format(d);
  if (reviewDay != null) {
    nodes.add(
      PlanNode(
        kind: PlanNodeKind.review,
        title: 'New material stops',
        subtitle: 'Reviews and the mock only from here.',
        date: date(reviewDay),
        reviewOnly: true,
      ),
    );
  }
  if (mockDay != null) {
    nodes.add(
      PlanNode(
        kind: PlanNodeKind.mock,
        title: 'Mock exam',
        subtitle: '${exam.shortName} simulation',
        date: date(mockDay),
        reviewOnly: true,
      ),
    );
  }
  if (examDay != null) {
    nodes.add(
      PlanNode(
        kind: PlanNodeKind.exam,
        title: exam.shortName,
        subtitle: 'Exam day',
        date: date(examDay),
        reviewOnly: true,
      ),
    );
  }
  for (var i = 0; i < changes.length && i < limit; i++) {
    final c = changes[i];
    // Old exam-change rows lack the historic target. Do not use today's exam.
    final text = planHistoryText(c, examName: exam.shortName);
    if (text == null) continue;
    final age = now.difference(localDay(c.occurredAt)).inDays;
    history.add(
      PlanHistoryEntry(
        id: '${c.occurredAt.toIso8601String()}-$i',
        date: age == 0
            ? 'Today'
            : age == 1
                ? 'Yesterday'
                : DateFormat('MMM d', 'en_US').format(c.occurredAt),
        text: text,
      ),
    );
  }
  if (!await guard()) throw StateError('Plan owner changed');
  final progress = planChecklistProgress(today, remaining);
  return PlanView(
    state: state,
    done: progress.done,
    total: progress.total,
    nodes: nodes,
    history: history,
    subtitle: subtitle,
    next: next,
  );
});

DateTime? _date(Object? value) => value == null ? null : studyDay(value);

final planDayViewProvider =
    FutureProvider.autoDispose.family<PlanDayView, String>((ref, key) async {
  ref.watch(roadmapRevisionProvider);
  await ref.watch(studyCoreEpochProvider.future);
  await ref.watch(authStateProvider.future);
  final date = studyDay(key);
  final exam = (await ref.watch(activeExamFocusProvider.future)).exam;
  if (exam == null) throw StateError('Plan exam unavailable');
  var alive = true;
  ref.onDispose(() => alive = false);
  final guard =
      await captureQuizLaunchGuard(ref, examId: exam.id, isAlive: () => alive);
  final now = localDay(ref.read(nowProvider)().toLocal());
  final future = date.isAfter(now);
  final covered = !future ||
      (ref.watch(studyUsesServerProvider)
          ? (await ref.watch(serverStudyInsightsProvider(exam.id).future))
              .proCovered
          : await ref.watch(proForActiveExamProvider.future));
  if (!covered) {
    return PlanDayView(
      date: date,
      plan: null,
      remaining: null,
      lessons: const [],
      kind: 'locked',
    );
  }
  DayPlan? plan;
  DayPlan? remaining;
  final readLessonIds = <String>{};
  var kind = future
      ? 'future'
      : date == now
          ? 'today'
          : 'past';
  if (ref.watch(studyUsesServerProvider)) {
    // Watching this authoritative read also invalidates future data at expiry.
    final access = await ref.watch(serverStudyRoadmapProvider(exam.id).future);
    if (future && !access.proCovered) {
      return PlanDayView(
        date: date,
        plan: null,
        remaining: null,
        lessons: const [],
        kind: 'locked',
      );
    }
    final reader = await ref.watch(studySnapshotReaderProvider(exam.id).future);
    final raw =
        await reader.request.read('getRoadmapDay', payload: {'date': key});
    StudyEnvelope(raw, exam.id);
    kind = studyString(raw['kind']);
    if (future && access.proCovered) {
      final insights =
          await ref.watch(serverStudyInsightsProvider(exam.id).future);
      if (insights.proCovered) {
        for (final topic in insights.topicDetails) {
          for (final lesson in studyRows(topic['lessons'])) {
            if (lesson['read'] == true) {
              readLessonIds.add(studyString(lesson['id']));
            }
          }
        }
      }
    }
    if (raw['plan'] != null) plan = decodeStudyDayPlan(raw['plan']);
    if (raw['remaining'] != null) {
      remaining = decodeStudyDayPlan(raw['remaining']);
    }
  } else if (date == now) {
    final current = await ref.watch(roadmapTodayProvider(exam.id).future);
    plan = current.snapshot.plan;
    remaining = current.remaining;
  } else if (future) {
    final current = await ref.watch(roadmapTodayProvider(exam.id).future);
    final inputs = await ref.read(roadmapInputsReaderProvider).inputs(
          exam.id,
          now,
          anchoredReviewOnlyFrom: current.snapshot.reviewOnlyFrom,
        );
    final ids = WeekPreviews.plannedLessonsForDay(
      today: now,
      date: date,
      reviewOnlyFrom: current.snapshot.reviewOnlyFrom,
      lessonTopicOrder: current.snapshot.topicOrder,
      lessons: inputs.lessons,
      lessonLinks: inputs.lessonLinks,
      scheduledToday: current.snapshot.plan.lessonIds.toSet(),
      studyDays: inputs.studyDays,
    );
    plan = DayPlan(
      day: date,
      lessonIds: ids,
      reviewQuestionIds: const [],
      newQuestionIds: const [],
      isMockDay: false,
      advancedIds: const {},
      isRestDay: !inputs.studyDays.isStudyDay(date),
    );
  } else {
    final stored =
        await ref.read(roadmapDayRepositoryProvider).read(exam.id, date);
    if (stored != null) {
      plan = stored.plan;
      final db = ref.read(appDatabaseProvider);
      final reads = await db.select(db.lessonProgressLocal).get();
      final attempts = await db.select(db.attemptsLocal).get();
      final completed = <Attempt>[];
      for (final row in attempts) {
        final attempt = await ref.read(attemptsRepositoryProvider).byId(row.id);
        if (attempt != null) completed.add(attempt);
      }
      remaining = DaySnapshots.remaining(
        stored,
        completedPlanFacts(
          date,
          {for (final r in reads) r.lessonId: r.readAt},
          completed,
        ),
      );
    } else {
      kind = 'unknown';
    }
  }
  final lessons = <HomeTodayLesson>[];
  if (plan != null) {
    final db = ref.read(contentDatabaseProvider);
    final rows = await (db.select(db.contentLessons)
          ..where((l) => l.id.isIn(plan!.lessonIds)))
        .get();
    final topics = await db.select(db.contentTopics).get();
    final subjects = await db.select(db.contentSubjects).get();
    final names = {
      for (final t in topics)
        t.id: subjects.where((s) => s.id == t.subjectId).firstOrNull?.name,
    };
    if (!ref.read(studyUsesServerProvider)) {
      final studentDb = ref.read(appDatabaseProvider);
      final reads = await studentDb.select(studentDb.lessonProgressLocal).get();
      readLessonIds.addAll(reads.map((r) => r.lessonId));
    }
    for (final id in plan.lessonIds) {
      final row = rows.where((l) => l.id == id).firstOrNull;
      if (row == null || names[row.topicId] == null) {
        throw StateError('Plan lesson unavailable');
      }
      // Future web read flags must come from the authoritative endpoint.
      final read = remaining != null
          ? !remaining.lessonIds.contains(id)
          : readLessonIds.contains(id);
      lessons.add(
        HomeTodayLesson(
          id: id,
          title: row.title,
          subject: names[row.topicId]!,
          minutes: 0,
          read: read,
        ),
      );
    }
  }
  if (!await guard()) throw StateError('Plan owner changed');
  return PlanDayView(
    date: date,
    plan: plan,
    remaining: remaining,
    lessons: lessons,
    readLessonIds: readLessonIds,
    kind: kind,
  );
});

/// Keep the visited day's actual membership while a read reshapes future plans.
/// The new read flags still come from the current authoritative observation.
PlanDayView retainOpenedPlanDay(PlanDayView opened, PlanDayView fresh) {
  if (opened.kind != 'future' ||
      fresh.kind != 'future' ||
      opened.date != fresh.date) {
    return fresh;
  }
  return PlanDayView(
    date: opened.date,
    plan: opened.plan,
    remaining: fresh.remaining,
    kind: fresh.kind,
    readLessonIds: fresh.readLessonIds,
    lessons: [
      for (final l in opened.lessons)
        HomeTodayLesson(
          id: l.id,
          title: l.title,
          subject: l.subject,
          minutes: l.minutes,
          read: fresh.readLessonIds.contains(l.id),
          fraction: l.fraction,
          advanced: l.advanced,
        ),
    ],
  );
}
