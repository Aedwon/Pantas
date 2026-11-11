import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/attempts_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/beta_feedback/application/beta_day_reporter.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/in_memory_database.dart';

class _Api implements BetaFeedbackApi {
  final List<BetaDayKind> days = [];
  int rewardReads = 0;
  int failures = 0;

  @override
  Future<void> recordDay(BetaDayKind kind) async {
    if (failures > 0) {
      failures--;
      throw const BetaFeedbackException(BetaFeedbackFailure.other);
    }
    days.add(kind);
  }

  @override
  Future<BetaReward> reward() async {
    rewardReads++;
    return BetaReward(
      days: const [],
      betaDays: const [],
      surveyOpensAt: DateTime(2026, 11, 15),
      surveyClosesAt: DateTime(2026, 11, 23),
      surveySubmitted: false,
      eligible: false,
      activationDeadline: DateTime(2027, 12, 31),
    );
  }

  @override
  Future<BetaRewardActivation> activate() => throw UnimplementedError();
  @override
  Future<String> imageUrl(String path) => throw UnimplementedError();
  @override
  Future<SentFeedback> send({
    required String feedbackId,
    required String text,
    required List<PickedImage> images,
  }) =>
      throw UnimplementedError();
  @override
  Stream<List<SentFeedback>> sent() => throw UnimplementedError();
  @override
  Future<void> submitSurvey(SurveyAnswers answers) =>
      throw UnimplementedError();
}

RoadmapToday _today(
  DateTime day, {
  bool rest = false,
  bool done = false,
}) {
  final plan = DayPlan(
    day: day,
    lessonIds: const [],
    reviewQuestionIds: const [],
    newQuestionIds: const [],
    isMockDay: false,
    advancedIds: const {},
    isRestDay: rest,
  );
  return RoadmapToday(
    snapshot: DaySnapshot(
      plan: plan,
      digest: RoadmapDigest(
        examId: 'e1',
        examDate: '',
        scopeTopicIds: const [],
        contentRevision: 'r',
        assessmentCompleted: true,
        recordedMockCount: 0,
      ),
      topicOrderHead: const [],
    ),
    remaining: plan,
    originalDone: done,
  );
}

void main() {
  late AppDatabase db;
  late _Api api;
  late DateTime now;
  late bool tester;
  late String uid;
  late StateProvider<RoadmapToday> driver;
  late ProviderContainer container;
  var running = false;

  void stop() {
    if (running) container.dispose();
    running = false;
  }

  Future<void> settle() async {
    for (var i = 0; i < 6; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> start() async {
    running = true;
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        betaDayReporterEnabledProvider.overrideWithValue(true),
        betaFeedbackVisibleProvider.overrideWith((ref) => tester),
        betaFeedbackClockProvider.overrideWithValue(() => now),
        betaFeedbackApiProvider.overrideWithValue(api),
        currentUserProvider.overrideWith(
          (ref) async =>
              AuthUser(uid: uid, email: 'a@b.test', displayName: 'A'),
        ),
        activeExamFocusProvider.overrideWith(
          (ref) async => const ActiveExamFocus.selected(
            Exam(
              id: 'e1',
              code: 'e1',
              name: 'e1',
              shortName: 'e1',
              language: 'en',
              isActive: true,
              subjects: [],
            ),
          ),
        ),
        roadmapTodayProvider('e1').overrideWith((ref) async {
          return ref.watch(driver);
        }),
      ],
    )..listen(betaDayReporterProvider, (_, __) {});
    await settle();
  }

  Future<void> finishSession(String origin, {DateTime? at}) async {
    final when = at ?? now;
    await AttemptsRepository(db).save(
      Attempt(
        id: 'a${DateTime.now().microsecondsSinceEpoch}',
        examId: 'e1',
        startedAt: when.subtract(const Duration(minutes: 5)),
        completedAt: when,
        origin: origin,
        items: const [],
      ),
    );
    container
        .read(quizSessionPanelRevisionProvider.notifier)
        .publishCompletion();
    await settle();
  }

  setUp(() {
    db = inMemoryDatabase();
    api = _Api();
    now = DateTime(2026, 11, 10, 14);
    tester = true;
    uid = 'u1';
    driver =
        StateProvider<RoadmapToday>((ref) => _today(DateTime(2026, 11, 10)));
  });
  tearDown(() async {
    stop();
    await db.close();
  });

  group('a plan day', () {
    test('reports once when the whole plan is done', () async {
      await start();
      expect(api.days, isEmpty);
      container.read(driver.notifier).state =
          _today(DateTime(2026, 11, 10), done: true);
      await settle();
      expect(api.days, [BetaDayKind.plan]);
      container.read(driver.notifier).state =
          _today(DateTime(2026, 11, 10), done: true);
      await settle();
      expect(api.days, [BetaDayKind.plan]);
    });

    test('does not report while the plan is not done', () async {
      await start();
      container.read(driver.notifier).state = _today(DateTime(2026, 11, 10));
      await settle();
      expect(api.days, isEmpty);
    });

    test('reports at app open when the plan was already done', () async {
      driver = StateProvider<RoadmapToday>(
        (ref) => _today(DateTime(2026, 11, 10), done: true),
      );
      await start();
      expect(api.days, [BetaDayKind.plan]);
    });

    test('ignores a plan that belongs to an earlier day', () async {
      driver = StateProvider<RoadmapToday>(
        (ref) => _today(DateTime(2026, 11, 9), done: true),
      );
      await start();
      expect(api.days, isEmpty);
    });

    test('reports the plan again on the next date', () async {
      driver = StateProvider<RoadmapToday>(
        (ref) => _today(DateTime(2026, 11, 10), done: true),
      );
      await start();
      expect(api.days, hasLength(1));
      now = DateTime(2026, 11, 11, 9);
      container.read(driver.notifier).state =
          _today(DateTime(2026, 11, 11), done: true);
      await settle();
      expect(api.days, [BetaDayKind.plan, BetaDayKind.plan]);
    });

    test('remembers the date after a restart', () async {
      driver = StateProvider<RoadmapToday>(
        (ref) => _today(DateTime(2026, 11, 10), done: true),
      );
      await start();
      expect(api.days, hasLength(1));
      stop();
      await start();
      expect(api.days, hasLength(1));
    });

    test('keeps one date per account', () async {
      driver = StateProvider<RoadmapToday>(
        (ref) => _today(DateTime(2026, 11, 10), done: true),
      );
      await start();
      stop();
      uid = 'u2';
      await start();
      expect(api.days, hasLength(2));
    });

    test('refreshes the reward after a report', () async {
      await start();
      container.listen(betaRewardProvider, (_, __) {});
      await settle();
      expect(api.rewardReads, 1);
      container.read(driver.notifier).state =
          _today(DateTime(2026, 11, 10), done: true);
      await settle();
      expect(api.days, [BetaDayKind.plan]);
      expect(api.rewardReads, 2);
    });

    test('does not refresh the reward when the report fails', () async {
      api.failures = 1;
      await start();
      container.listen(betaRewardProvider, (_, __) {});
      await settle();
      container.read(driver.notifier).state =
          _today(DateTime(2026, 11, 10), done: true);
      await settle();
      expect(api.days, isEmpty);
      expect(api.rewardReads, 1);
    });
  });

  group('a rest day', () {
    setUp(() {
      driver = StateProvider<RoadmapToday>(
        // An empty plan is trivially done, which must not count.
        (ref) => _today(DateTime(2026, 11, 10), rest: true, done: true),
      );
    });

    test('does not report with no session', () async {
      await start();
      expect(api.days, isEmpty);
    });

    test('reports after a finished streak-eligible session', () async {
      await start();
      await finishSession('today_topic');
      expect(api.days, [BetaDayKind.restDay]);
    });

    test('counts interleaved and new-questions sessions', () async {
      for (final origin in ['today_interleaved', 'new_questions']) {
        api.days.clear();
        await db.delete(db.devicePrefs).go();
        await db.delete(db.attemptsLocal).go();
        await start();
        await finishSession(origin);
        expect(api.days, [BetaDayKind.restDay], reason: origin);
        stop();
      }
    });

    test('ignores origins that are not streak-eligible', () async {
      await start();
      for (final origin in [
        'drill',
        'flagged',
        'retake',
        'inline',
        'assessment',
        'mock',
      ]) {
        await finishSession(origin);
      }
      expect(api.days, isEmpty);
    });

    test('ignores a session from another day or one not finished', () async {
      await start();
      await finishSession(
        'today_topic',
        at: DateTime(2026, 11, 9, 23, 59),
      );
      await AttemptsRepository(db).save(
        Attempt(
          id: 'open',
          examId: 'e1',
          startedAt: now,
          items: const [],
        ),
      );
      container
          .read(quizSessionPanelRevisionProvider.notifier)
          .publishCompletion();
      await settle();
      expect(api.days, isEmpty);
    });

    test('reports at app open for a session finished earlier', () async {
      await AttemptsRepository(db).save(
        Attempt(
          id: 'earlier',
          examId: 'e1',
          startedAt: DateTime(2026, 11, 10, 8),
          completedAt: DateTime(2026, 11, 10, 8, 20),
          items: const [],
        ),
      );
      await start();
      expect(api.days, [BetaDayKind.restDay]);
    });

    test('reports once for the date', () async {
      await start();
      await finishSession('today_topic');
      await finishSession('new_questions');
      expect(api.days, [BetaDayKind.restDay]);
    });
  });

  group('who and when', () {
    test('a non-tester never reports', () async {
      tester = false;
      driver = StateProvider<RoadmapToday>(
        (ref) => _today(DateTime(2026, 11, 10), done: true),
      );
      await start();
      expect(api.days, isEmpty);
    });

    test('only Nov 8 to Nov 16 report', () async {
      final cases = {
        DateTime(2026, 11, 7, 23, 59): false,
        DateTime(2026, 11, 8): true,
        DateTime(2026, 11, 16, 23, 59): true,
        DateTime(2026, 11, 17): false,
      };
      for (final entry in cases.entries) {
        api.days.clear();
        await db.delete(db.devicePrefs).go();
        now = entry.key;
        driver = StateProvider<RoadmapToday>(
          (ref) => _today(DateTime(now.year, now.month, now.day), done: true),
        );
        await start();
        expect(
          api.days,
          entry.value ? hasLength(1) : isEmpty,
          reason: '${entry.key}',
        );
        stop();
      }
    });

    test('other platforms never report', () async {
      driver = StateProvider<RoadmapToday>(
        (ref) => _today(DateTime(2026, 11, 10), done: true),
      );
      running = true;
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          betaFeedbackVisibleProvider.overrideWith((ref) => true),
          betaFeedbackApiProvider.overrideWithValue(api),
          betaFeedbackClockProvider.overrideWithValue(() => now),
        ],
      )..listen(betaDayReporterProvider, (_, __) {});
      await settle();
      expect(api.days, isEmpty);
    });
  });

  group('failures', () {
    test('stay silent and are retried on the next change', () async {
      api.failures = 1;
      driver = StateProvider<RoadmapToday>(
        (ref) => _today(DateTime(2026, 11, 10), done: true),
      );
      await start();
      expect(api.days, isEmpty);
      expect(
        await AppPreferencesRepository(db).deviceValue('beta_day_reported_u1'),
        isNull,
      );
      container
          .read(quizSessionPanelRevisionProvider.notifier)
          .publishCompletion();
      await settle();
      expect(api.days, [BetaDayKind.plan]);
      expect(
        await AppPreferencesRepository(db).deviceValue('beta_day_reported_u1'),
        '2026-11-10',
      );
    });
  });
}
