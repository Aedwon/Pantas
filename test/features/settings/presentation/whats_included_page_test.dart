import 'dart:convert';

import 'package:drift/drift.dart' hide Column, isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/pantas_tag.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/settings/domain/custom_tier_raise.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';

import '../../../helpers/custom_subject_tiers_fixture.dart';
import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'exam_1',
      code: 'EX1',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sub_1',
      examId: 'exam_1',
      name: 'Mathematics',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top_1',
      subjectId: 'sub_1',
      name: 'Algebra',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top_2',
      subjectId: 'sub_1',
      name: 'Geometry',
      ordering: 2,
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'les_1',
      topicId: 'top_1',
      title: 'Linear Equations',
      bodyJson: '[]',
      ordering: 1,
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'les_2',
      topicId: 'top_2',
      title: 'Angles',
    );
    for (final (topicId, lessonId) in [
      ('top_1', 'les_1'),
      ('top_2', 'les_2'),
    ]) {
      await seedContentQuestion(
        contentDb,
        questionId: 'question_$lessonId',
        topicId: topicId,
        examId: 'exam_1',
        lessonId: lessonId,
      );
    }

    await AppPreferencesRepository(db).setSelectedExamId('exam_1');
  });

  tearDown(() => db.close());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(
              Exam(
                id: 'exam_1',
                code: 'EX1',
                name: 'Civil Service Exam',
                shortName: 'CSE',
                language: 'en',
                isActive: true,
                subjects: [
                  Subject(
                    id: 'sub_1',
                    examId: 'exam_1',
                    name: 'Mathematics',
                    ordering: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const WhatsIncludedPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the last included topic stays selected', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Geometry'));
    await tester.pumpAndSettle();
    final exclusions = await db.select(db.trackScopeLocal).get();
    expect(exclusions.map((e) => e.topicId), ['top_1']);
    expect(find.text('At least one topic stays ticked.'), findsOneWidget);
  });

  testWidgets('the screen has the approved scope footer', (tester) async {
    await pumpPage(tester);

    expect(
      find.text(
        "Untick what you don't need. It gets removed from your plan, "
        "and your answers on it won't be deleted.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('everything is ticked for a listed exam with no exclusions',
      (tester) async {
    await pumpPage(tester);

    final picker = tester.widget<ScopePicker>(find.byType(ScopePicker));
    expect(picker.selectedIds, {'les_1', 'les_2'});
  });

  testWidgets('unticking a topic writes an exclusion', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    final exclusions = await db.select(db.trackScopeLocal).get();
    expect(exclusions.length, equals(1));
    expect(exclusions.first.examId, equals('exam_1'));
    expect(exclusions.first.topicId, equals('top_1'));
  });

  testWidgets('unticking one topic keeps the other topic selected',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    final picker = tester.widget<ScopePicker>(find.byType(ScopePicker));
    expect(picker.selectedIds, {'les_2'});
  });

  testWidgets('re-ticking removes the exclusion', (tester) async {
    await pumpPage(tester);

    // Untick
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    // Re-tick
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    final exclusions = await db.select(db.trackScopeLocal).get();
    expect(exclusions, isEmpty);
  });

  testWidgets('narrowing deletes no attempt', (tester) async {
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'attempt_1',
            examId: 'exam_1',
            startedAt: DateTime.now(),
            completedAt: Value(DateTime.now()),
            itemsJson: jsonEncode([]),
          ),
        );

    await pumpPage(tester);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    final attempts = await db.select(db.attemptsLocal).get();
    expect(attempts.length, equals(1));
  });

  testWidgets('there are no lesson rows', (tester) async {
    await pumpPage(tester);

    expect(find.text('Linear Equations'), findsNothing);
  });

  group('a custom exam', () {
    late String customId;
    late List<(String, Map<String, Object?>)> calls;

    setUp(() async {
      calls = [];
      // Only a topic that holds a question is listed. Trigonometry holds none,
      // and neither does the whole of Verbal Ability.
      await seedContentQuestion(
        contentDb,
        questionId: 'q_1',
        topicId: 'top_1',
        examId: 'exam_1',
      );
      await seedContentQuestion(
        contentDb,
        questionId: 'q_2',
        topicId: 'top_2',
        examId: 'exam_1',
      );
      await seedContentTopic(
        contentDb,
        topicId: 'top_3',
        subjectId: 'sub_1',
        name: 'Trigonometry',
        ordering: 3,
      );
      await seedContentSubject(
        contentDb,
        subjectId: 'sub_2',
        examId: 'exam_1',
        name: 'Verbal Ability',
        ordering: 2,
      );
      await seedContentTopic(
        contentDb,
        topicId: 'top_4',
        subjectId: 'sub_2',
        name: 'Analogies',
      );
      final repo = CustomTrackRepository(db, contentDb);
      customId = await repo.create(
        name: 'PUP CET',
        includedTopicIds: {'top_1', 'top_2', 'top_3', 'top_4'},
      );
      // The student unticked Geometry. Trigonometry was left out when the
      // exam was made, and the picker never shows it.
      await repo.setExcluded(
        examId: customId,
        topicIds: {'top_2', 'top_3'},
      );
      await AppPreferencesRepository(db).setSelectedExamId(customId);
    });

    Future<void> pumpCustomPage(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(contentDb),
            shippedCustomSubjectTiers(studentTopics: ['top_1', 'top_2']),
            authStateProvider.overrideWith(
              (ref) => Stream.value(const AuthState.anonymous(uid: 'u1')),
            ),
            studyApiProvider.overrideWithValue(
              StudyApi((name, data) async {
                calls.add((name, data));
                return <String, Object?>{};
              }),
            ),
            activeExamFocusProvider.overrideWith(
              (ref) async => ActiveExamFocus.selected(
                Exam(
                  id: customId,
                  code: customId,
                  name: 'PUP CET',
                  shortName: 'PUP CET',
                  language: 'en',
                  isActive: true,
                  isCustom: true,
                  subjects: [],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const WhatsIncludedPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
          .read(authStateProvider.future);
    }

    testWidgets('lists only the topics that hold a question', (tester) async {
      await pumpCustomPage(tester);

      expect(find.text('Algebra'), findsOneWidget);
      expect(find.text('Geometry'), findsOneWidget);
      expect(find.text('Trigonometry'), findsNothing);
      expect(find.text('Verbal Ability'), findsNothing);
      expect(find.text('Analogies'), findsNothing);
    });

    testWidgets('a topic the student excluded is listed, unticked',
        (tester) async {
      await pumpCustomPage(tester);

      final picker = tester.widget<ScopePicker>(find.byType(ScopePicker));
      expect(picker.selectedIds, {'les_1'});
    });

    testWidgets('saving publishes the exam block and keeps what stays hidden',
        (tester) async {
      await pumpCustomPage(tester);

      await tester.tap(find.text('Geometry'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        for (var i = 0; i < 100; i++) {
          if (calls.any((c) => c.$1 == 'setExamSettings')) break;
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });

      final sent = calls.firstWhere((c) => c.$1 == 'setExamSettings').$2;
      expect(sent['examId'], customId);
      expect(sent['expectedUid'], 'u1');
      expect(sent['customTrack'], {'name': 'PUP CET'});
      // Geometry is ticked again. Trigonometry has no questions and the
      // student never saw it, so it stays out.
      expect(sent['excludedTopicIds'], ['top_3']);
      expect(
        (await db.select(db.trackScopeLocal).get()).map((e) => e.topicId),
        ['top_3'],
      );
    });
  });

  group('a custom exam that can rise in tier', () {
    const gi = 'topic_upcat_philippine_constitution';
    const title = 'PUP CET becomes a Civil Service-level exam';
    const body = 'Your Student plan does not cover Civil Service-level exams, '
        'so unlimited mocks, days ahead in your plan and Pro study figures '
        'stop on PUP CET. Wrong-choice notes stay on questions that '
        'Student-level exams also use.';
    const studentLine =
        'Studying is free. For Pro, this is a Student-level exam.';
    const civilLine =
        'Studying is free. For Pro, this is a Civil Service-level exam.';
    late String customId;
    late List<(String, Map<String, Object?>)> calls;

    setUp(() async {
      calls = [];
      await seedContentQuestion(
        contentDb,
        questionId: 'q_1',
        topicId: 'top_1',
        examId: 'exam_1',
        lessonId: 'les_1',
      );
      await seedContentSubject(
        contentDb,
        subjectId: 'sub_gi',
        examId: 'exam_1',
        name: 'General Information',
        ordering: 2,
      );
      await seedContentTopic(
        contentDb,
        topicId: gi,
        subjectId: 'sub_gi',
        name: 'Constitution',
      );
      await seedContentLesson(
        contentDb,
        lessonId: 'les_gi',
        topicId: gi,
        title: 'Rights',
      );
      await seedContentQuestion(
        contentDb,
        questionId: 'q_gi',
        topicId: gi,
        examId: 'exam_1',
        lessonId: 'les_gi',
      );
      final repo = CustomTrackRepository(db, contentDb);
      customId = await repo.create(
        name: 'PUP CET',
        includedTopicIds: {'top_1', gi},
      );
      // A Student-level exam: General Information is unticked.
      await repo.setExcluded(
        examId: customId,
        topicIds: {gi},
      );
      await AppPreferencesRepository(db).setSelectedExamId(customId);
    });

    Future<void> pumpTier(
      WidgetTester tester, {
      required Entitlement entitlement,
      bool wide = true,
      List<String> studentTopics = const ['top_1', 'top_2'],
    }) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize =
          wide ? const Size(1440, 900) : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const WhatsIncludedPage(),
          ),
          GoRoute(
            path: '/settings/exam/upgrade',
            builder: (context, state) {
              final raise = state.extra! as CustomTierRaise;
              return Scaffold(
                body: Column(
                  children: [
                    Text(
                      'upgrade ${state.uri.queryParameters['target']} '
                      '${raise.examName} ${raise.tier.name}',
                    ),
                    TextButton(
                      onPressed: () => context.pop(true),
                      child: const Text('Save on Free'),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back out'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(contentDb),
            shippedCustomSubjectTiers(studentTopics: studentTopics),
            entitlementProvider
                .overrideWith((ref) => Stream.value(entitlement)),
            authStateProvider.overrideWith(
              (ref) => Stream.value(const AuthState.anonymous(uid: 'u1')),
            ),
            studyApiProvider.overrideWithValue(
              StudyApi((name, data) async {
                calls.add((name, data));
                return <String, Object?>{};
              }),
            ),
            activeExamFocusProvider.overrideWith(
              (ref) async => ActiveExamFocus.selected(
                Exam(
                  id: customId,
                  code: customId,
                  name: 'PUP CET',
                  shortName: 'PUP CET',
                  language: 'en',
                  isActive: true,
                  isCustom: true,
                  subjects: [],
                ),
              ),
            ),
          ],
          child: MaterialApp.router(
            theme: buildLightTheme(web: wide),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
          .read(authStateProvider.future);
    }

    Entitlement plan(PriceTier tier) => Entitlement(
          plan: EntitlementPlan.monthly,
          tier: tier,
          expiresAt: DateTime.utc(2099),
        );

    Future<Set<String>> excluded() async =>
        (await db.select(db.trackScopeLocal).get())
            .map((e) => e.topicId)
            .toSet();

    testWidgets('only General Information carries the level mark, with no tag',
        (tester) async {
      await pumpTier(tester, entitlement: const Entitlement.free());

      expect(
        find.text('GENERAL INFORMATION · Civil Service-level'),
        findsOneWidget,
      );
      expect(find.text('MATHEMATICS'), findsOneWidget);
      expect(
        find.textContaining('Student-level', findRichText: true),
        findsOneWidget,
      ); // the tier line only
      expect(find.byType(PantasTag), findsNothing);
    });

    testWidgets('the tier line follows the saved ticks', (tester) async {
      await pumpTier(tester, entitlement: const Entitlement.free());
      expect(find.text(studentLine), findsOneWidget);

      await tester.tap(find.text('Constitution'));
      await tester.pumpAndSettle();

      expect(find.text(civilLine), findsOneWidget);
      expect(find.text(studentLine), findsNothing);
    });

    for (final wide in [true, false]) {
      final layout = wide ? 'wide' : 'phone';

      testWidgets('$layout: Student Pro adding General Information asks first',
          (tester) async {
        await pumpTier(
          tester,
          entitlement: plan(PriceTier.student),
          wide: wide,
        );

        await tester.tap(find.text('Constitution'));
        await tester.pumpAndSettle();

        expect(find.byType(CenteredDialog), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        expect(find.text(body), findsOneWidget);
        expect(find.text('Undo Change'), findsOneWidget);
        expect(find.text('See Plans'), findsOneWidget);
        expect(await excluded(), {gi}, reason: 'nothing saved yet');
      });
    }

    testWidgets('Undo Change saves nothing and the ticks stay as they were',
        (tester) async {
      await pumpTier(tester, entitlement: plan(PriceTier.student));
      final before =
          tester.widget<ScopePicker>(find.byType(ScopePicker)).selectedIds;

      await tester.tap(find.text('Constitution'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo Change'));
      await tester.pumpAndSettle();

      expect(find.byType(CenteredDialog), findsNothing);
      expect(await excluded(), {gi});
      expect(calls.where((c) => c.$1 == 'setExamSettings'), isEmpty);
      final picker = tester.widget<ScopePicker>(find.byType(ScopePicker));
      expect(picker.selectedIds, before);
      expect(find.text(studentLine), findsOneWidget);
    });

    testWidgets('See Plans opens the upgrade screen at the new tier',
        (tester) async {
      await pumpTier(tester, entitlement: plan(PriceTier.student));

      await tester.tap(find.text('Constitution'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See Plans'));
      await tester.pumpAndSettle();

      expect(
        find.text('upgrade $customId PUP CET civilService'),
        findsOneWidget,
      );
      expect(await excluded(), {gi}, reason: 'nothing saved yet');
    });

    testWidgets('Save on Free there saves exactly the pending change',
        (tester) async {
      await pumpTier(tester, entitlement: plan(PriceTier.student));

      await tester.tap(find.text('Constitution'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See Plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save on Free'));
      await tester.pumpAndSettle();

      expect(find.byType(ScopePicker), findsOneWidget);
      expect(await excluded(), isEmpty);
      expect(find.text(civilLine), findsOneWidget);
    });

    testWidgets('backing out of the upgrade screen saves nothing',
        (tester) async {
      await pumpTier(tester, entitlement: plan(PriceTier.student));

      await tester.tap(find.text('Constitution'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('See Plans'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back out'));
      await tester.pumpAndSettle();

      expect(await excluded(), {gi});
      expect(calls.where((c) => c.$1 == 'setExamSettings'), isEmpty);
      expect(find.text(studentLine), findsOneWidget);
    });

    testWidgets('a plan that already misses the saved tier is not asked',
        (tester) async {
      // Saved: Civil Service-level (General Information kept). Geometry is
      // unknown to the table here, which prices at the top tier.
      await CustomTrackRepository(db, contentDb)
          .setExcluded(examId: customId, topicIds: {'top_2'});
      await pumpTier(
        tester,
        entitlement: plan(PriceTier.student),
        studentTopics: ['top_1'],
      );

      await tester.tap(find.text('Geometry'));
      await tester.pumpAndSettle();

      expect(find.byType(CenteredDialog), findsNothing);
      expect(await excluded(), isEmpty);
    });

    testWidgets('Free sees no dialog and the change saves', (tester) async {
      await pumpTier(tester, entitlement: const Entitlement.free());

      await tester.tap(find.text('Constitution'));
      await tester.pumpAndSettle();

      expect(find.byType(CenteredDialog), findsNothing);
      expect(await excluded(), isEmpty);
    });

    testWidgets('Civil Service Pro sees no dialog and the change saves',
        (tester) async {
      await pumpTier(tester, entitlement: plan(PriceTier.civilService));

      await tester.tap(find.text('Constitution'));
      await tester.pumpAndSettle();

      expect(find.byType(CenteredDialog), findsNothing);
      expect(await excluded(), isEmpty);
    });

    testWidgets('lowering the tier never asks', (tester) async {
      await pumpTier(tester, entitlement: plan(PriceTier.student));
      // Save the raise first, as a Free student would, then drop it again.
      await CustomTrackRepository(db, contentDb)
          .setExcluded(examId: customId, topicIds: {});
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        ..invalidate(trackScopeProvider(customId))
        ..invalidate(whatsIncludedDataProvider(customId));
      await tester.pumpAndSettle();
      expect(find.text(civilLine), findsOneWidget);

      await tester.tap(find.text('Constitution'));
      await tester.pumpAndSettle();

      expect(find.byType(CenteredDialog), findsNothing);
      expect(await excluded(), {gi});
    });
  });
}
