import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

class _RecordingTelemetry extends DisabledTelemetry {
  final errors = <Object>[];
  @override
  Future<void> recordError(Object error, StackTrace stack) async {
    errors.add(error);
  }
}

const entries = [
  ExamCatalogEntry(
    id: 'exam_pupcet',
    name: 'PUP College Entrance Test',
    shortName: 'PUPCET',
    priceTier: 'Student',
    group: 'College entrance',
    comingSoon: false,
    publishedSittings: [],
    hasContent: true,
  ),
  ExamCatalogEntry(
    id: 'exam_upcat',
    name: 'UP College Admission Test',
    shortName: 'UPCAT',
    priceTier: 'Student',
    group: 'College entrance',
    comingSoon: false,
    publishedSittings: [],
    hasContent: true,
  ),
  ExamCatalogEntry(
    id: 'exam_acet',
    name: 'Ateneo College Entrance Test',
    shortName: 'ACET',
    priceTier: 'Student',
    group: 'College entrance',
    comingSoon: false,
    publishedSittings: [],
    hasContent: true,
  ),
  ExamCatalogEntry(
    id: 'exam_pshs_nce',
    name: 'PSHS National Competitive Examination',
    shortName: 'PSHS-NCE',
    priceTier: 'PSHS-NCE',
    group: 'High school',
    comingSoon: true,
    publishedSittings: [],
    hasContent: true,
  ),
];

void main() {
  late AppDatabase db;
  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());
  Future<void> pump(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    double scale = 1,
    ExamPickerMode mode = ExamPickerMode.onboarding,
    Future<void> Function(String)? picked,
    Stream<List<ExamCatalogEntry>>? data,
    VoidCallback? back,
    List<Override> extra = const [],
    bool customExams = kCustomExamsOffered,
    Size viewport = const Size(390, 844),
  }) =>
      pumpAccessibilitySurface(
        tester,
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            examPickerCatalogProvider
                .overrideWith((ref) => data ?? Stream.value(entries)),
            activeExamFocusProvider.overrideWith(
              (ref) async => const ActiveExamFocus.needsSelection(),
            ),
            ...extra,
          ],
          child: ExamPickerScreen(
            mode: mode,
            onPicked: picked ?? (_) async {},
            onCustom: () {},
            onBack: back,
            customExams: customExams,
          ),
        ),
        brightness: brightness,
        textScale: scale,
        viewportSize: viewport,
        disableAnimations: true,
      );

  const message = 'Daily content limit reached. Try again tomorrow.';
  final noContent = [
    for (final entry in entries)
      ExamCatalogEntry(
        id: entry.id,
        name: entry.name,
        shortName: entry.shortName,
        priceTier: entry.priceTier,
        group: entry.group,
        comingSoon: entry.comingSoon,
        publishedSittings: const [],
        hasContent: false,
      ),
  ];
  for (final wide in [false, true]) {
    for (final mode in ExamPickerMode.values) {
      testWidgets('the daily limit with no cached catalog says so $wide $mode',
          (tester) async {
        debugWebPlatformOverride = wide;
        addTearDown(() => debugWebPlatformOverride = null);
        await pump(
          tester,
          mode: mode,
          data: Stream.value(noContent),
          extra: [contentLimitReachedProvider.overrideWith((ref) => true)],
        );
        await tester.pumpAndSettle();
        expect(find.text(message), findsOneWidget);
        expect(find.text('Coming soon'), findsNothing);
      });
      testWidgets(
          'without the limit, exams not on the device stay Coming soon'
          ' $wide $mode', (tester) async {
        debugWebPlatformOverride = wide;
        addTearDown(() => debugWebPlatformOverride = null);
        await pump(tester, mode: mode, data: Stream.value(noContent));
        await tester.pumpAndSettle();
        expect(find.text(message), findsNothing);
      });
      testWidgets(
          'a cached catalog still shows when the limit is reached'
          ' $wide $mode', (tester) async {
        debugWebPlatformOverride = wide;
        addTearDown(() => debugWebPlatformOverride = null);
        await pump(
          tester,
          mode: mode,
          extra: [contentLimitReachedProvider.overrideWith((ref) => true)],
        );
        await tester.pumpAndSettle();
        expect(find.text(message), findsNothing);
        expect(find.text('UPCAT'), findsWidgets);
      });
    }
  }

  for (final wide in [false, true]) {
    for (final cseOnly in [false, true]) {
      for (final mode in ExamPickerMode.values) {
        testWidgets('selectable exams and groups first $wide $cseOnly $mode',
            (tester) async {
          debugWebPlatformOverride = wide;
          addTearDown(() => debugWebPlatformOverride = null);
          const civil = ExamCatalogEntry(
            id: 'exam_cse_pro',
            name: 'CSE',
            shortName: 'CSE Professional',
            priceTier: 'Civil Service',
            group: 'Civil service',
            comingSoon: false,
            publishedSittings: [],
            hasContent: true,
          );
          final catalog = [
            entries[3],
            const ExamCatalogEntry(
              id: 'exam_future',
              name: 'Future',
              shortName: 'Future',
              priceTier: 'Student',
              group: 'College entrance',
              comingSoon: true,
              publishedSittings: [],
              hasContent: true,
            ),
            ...entries.take(3),
            civil,
          ];
          await pumpAccessibilitySurface(
            tester,
            ProviderScope(
              overrides: [
                appDatabaseProvider.overrideWithValue(db),
                examPickerCatalogProvider.overrideWith(
                  (ref) => Stream.value(catalog),
                ),
                activeExamFocusProvider.overrideWith(
                  (ref) async => const ActiveExamFocus.needsSelection(),
                ),
              ],
              child: ExamPickerScreen(
                mode: mode,
                cseOnly: cseOnly,
                onPicked: (_) async {},
                onBack: () {},
                onCustom: () {},
              ),
            ),
            viewportSize: Size(wide ? 1440 : 390, 900),
            disableAnimations: true,
          );
          await tester.pumpAndSettle();
          final ids = find
              .byWidgetPredicate(
                (widget) =>
                    widget.key is ValueKey<String> &&
                    (widget.key! as ValueKey<String>)
                        .value
                        .startsWith('exam-exam_'),
              )
              .evaluate()
              .map((e) => (e.widget.key! as ValueKey<String>).value)
              .toList();
          expect(
            ids,
            cseOnly
                ? [
                    'exam-exam_cse_pro',
                    'exam-exam_future',
                    'exam-exam_pupcet',
                    'exam-exam_upcat',
                    'exam-exam_acet',
                    'exam-exam_pshs_nce',
                  ]
                : [
                    'exam-exam_pupcet',
                    'exam-exam_upcat',
                    'exam-exam_acet',
                    'exam-exam_future',
                    'exam-exam_cse_pro',
                    'exam-exam_pshs_nce',
                  ],
          );
        });
      }
    }
  }

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('grouped picker, search and coming soon $brightness $scale',
          (tester) async {
        await pump(tester, brightness: brightness, scale: scale);
        await tester.pumpAndSettle();
        expect(find.text('Which exam are you taking?'), findsOneWidget);
        expect(
          tester
              .widget<Text>(
                find.text('You can change this later in Settings.'),
              )
              .style!
              .height,
          1.35,
        );
        expect(find.text("My exam isn't listed"), findsOneWidget);
        expect(find.text('COLLEGE ENTRANCE TESTS'), findsOneWidget);
        expect(
          find.text('Polytechnic University of the Philippines'),
          findsOneWidget,
        );
        final button = tester.widget<PantasButton>(
          find.widgetWithText(PantasButton, 'Continue'),
        );
        expect(button.onPressed, isNull);
        await tester.enterText(find.byType(TextField), 'UPCAT');
        await tester.pumpAndSettle();
        expect(find.widgetWithText(ListRow, 'UPCAT'), findsOneWidget);
        expect(find.text('ACET'), findsNothing);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('PSHS-NCE'));
        await tester.tap(find.text('PSHS-NCE'));
        await tester.pump();
        expect(
          tester
              .widget<PantasButton>(
                find.widgetWithText(PantasButton, 'Continue'),
              )
              .onPressed,
          isNull,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('settings search and coming soon $brightness $scale',
          (tester) async {
        await pump(
          tester,
          mode: ExamPickerMode.settings,
          brightness: brightness,
          scale: scale,
        );
        await tester.pumpAndSettle();
        expect(find.text('Exam'), findsOneWidget);
        expect(find.text('Continue'), findsNothing);
        expect(find.text('All'), findsNothing);
        await tester.enterText(find.byType(TextField), 'PSHS');
        await tester.pumpAndSettle();
        final row = find.widgetWithText(ListRow, 'PSHS-NCE');
        expect(row, findsOneWidget);
        final button = tester.widget<TextButton>(
          find.descendant(of: row, matching: find.byType(TextButton)),
        );
        expect(button.onPressed, isNull);
        // ListRow README: a row that is not available uses `text-disabled`,
        // never opacity (lines 57 and 70).
        final colors = tester.element(row).colors;
        expect(
          tester
              .widget<Text>(
                find.descendant(of: row, matching: find.text('PSHS-NCE')),
              )
              .style!
              .color,
          colors.textDisabled,
        );
        expect(
          find.descendant(of: row, matching: find.byType(Opacity)),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('loading is announced and its shapes wait 300 milliseconds',
      (tester) async {
    final controller = StreamController<List<ExamCatalogEntry>>.broadcast();
    await pump(tester, data: controller.stream);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 299));
    expect(find.byKey(const ValueKey('loading-shapes-opacity')), findsNothing);
    await tester.pump(const Duration(milliseconds: 1));
    expect(
      find.byKey(const ValueKey('loading-shapes-opacity')),
      findsOneWidget,
    );
    controller.add(entries);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Loading'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    final closing = controller.close();
    await tester.pump();
    await closing;
  });
  for (final mode in ExamPickerMode.values) {
    testWidgets('visible and system Back match in $mode', (tester) async {
      var backs = 0;
      await pump(tester, mode: mode, back: () => backs++);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(mode == ExamPickerMode.settings ? 'Your exam' : 'Back'),
      );
      expect(backs, 1);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(backs, 2);
    });
  }
  testWidgets('exam rows and filters activate with the keyboard',
      (tester) async {
    String? picked;
    await pump(
      tester,
      mode: ExamPickerMode.settings,
      picked: (id) async => picked = id,
    );
    await tester.pumpAndSettle();
    Focus.of(tester.element(find.text('UPCAT')), createDependency: false)
        .requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(picked, 'exam_upcat');
  });
  testWidgets('an empty catalog offers the approved custom exam action',
      (tester) async {
    await pump(tester, data: Stream.value(const []));
    await tester.pumpAndSettle();
    expect(find.text('No exams available right now.'), findsOneWidget);
    expect(find.text('Set Up My Own Exam'), findsOneWidget);
  });

  testWidgets('onboarding picks then saves on Continue', (tester) async {
    String? picked;
    await pump(tester, picked: (id) async => picked = id);
    await tester.pumpAndSettle();
    await tester.tap(find.text('UPCAT'));
    await tester.pump();
    expect(picked, isNull);
    expect(await AppPreferencesRepository(db).selectedExamId(), isNull);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(picked, 'exam_upcat');
    expect(await AppPreferencesRepository(db).selectedExamId(), 'exam_upcat');
    expect(
      await AppPreferencesRepository(db).hasCompletedOnboarding(),
      isFalse,
    );
  });
  for (final wide in [false, true]) {
    testWidgets('Back from the date step keeps the exam pick, wide $wide',
        (tester) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      await AppPreferencesRepository(db).setSelectedExamId('exam_upcat');
      String? picked;
      await pump(
        tester,
        picked: (id) async => picked = id,
        viewport: Size(wide ? 1440 : 390, 900),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(picked, 'exam_upcat');
    });

    testWidgets('a saved custom track is not shown as a pick, wide $wide',
        (tester) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      await AppPreferencesRepository(db).setSelectedExamId('exam_custom_1');
      String? picked;
      await pump(
        tester,
        picked: (id) async => picked = id,
        viewport: Size(wide ? 1440 : 390, 900),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(picked, isNull);
    });

    testWidgets('the chips follow the order of the list sections, wide $wide',
        (tester) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      const civil = ExamCatalogEntry(
        id: 'exam_cse_pro',
        name: 'CSE',
        shortName: 'CSE Professional',
        priceTier: 'Civil Service',
        group: 'Civil service',
        comingSoon: false,
        publishedSittings: [],
        hasContent: true,
      );
      await pump(
        tester,
        data: Stream.value([...entries, civil]),
        viewport: Size(wide ? 1440 : 390, 900),
      );
      await tester.pumpAndSettle();
      // Reading order: the wide chips wrap onto rows.
      double chip(String label) {
        final at = tester.getTopLeft(find.text(label).first);
        return at.dy.roundToDouble() * 10000 + at.dx;
      }

      // The list opens with the sections that have exams to pick: College
      // entrance and Civil service. Their chips come first, in that order.
      final order = ['All', 'College', 'Civil service', 'High school'];
      for (var i = 1; i < order.length; i++) {
        expect(
          chip(order[i]),
          greaterThan(chip(order[i - 1])),
          reason: '${order[i - 1]} before ${order[i]}',
        );
      }
    });
  }

  testWidgets(
      'settings returns the pick without writing onboarding preferences',
      (tester) async {
    String? picked;
    await pump(
      tester,
      mode: ExamPickerMode.settings,
      picked: (id) async => picked = id,
    );
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsNothing);
    await tester.tap(find.text('ACET'));
    await tester.pumpAndSettle();
    expect(picked, 'exam_acet');
    expect(await AppPreferencesRepository(db).selectedExamId(), isNull);
  });
  testWidgets('load failure is retryable and never renders diagnostics',
      (tester) async {
    await pump(tester, data: Stream.error(StateError('private details')));
    await tester.pumpAndSettle();
    expect(find.text('Could not load your exams.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(find.textContaining('private details'), findsNothing);
  });
  testWidgets('failed save keeps selection and retries the operation',
      (tester) async {
    var fail = true;
    var successful = 0;
    await pump(
      tester,
      mode: ExamPickerMode.settings,
      picked: (id) async {
        if (fail) {
          fail = false;
          throw StateError('private details');
        }
        if (id == 'exam_upcat') successful++;
      },
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('UPCAT'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(successful, 1);
  });
  group('custom exams on web', () {
    // Aedwon, Nov 4: hide "My exam isn't listed" on web for the beta. One
    // constant brings it back everywhere, so every surface reads it.
    test('the constant hides the row on web only', () {
      expect(kCustomExamsOffered, !kIsWeb || kCustomExamsOnWeb);
      expect(kCustomExamsOnWeb, isFalse);
    });
    for (final (name, wide) in [('phone', false), ('wide', true)]) {
      for (final mode in ExamPickerMode.values) {
        testWidgets('hidden: no own-exam row or action, $name $mode',
            (tester) async {
          debugWebPlatformOverride = true;
          addTearDown(() => debugWebPlatformOverride = null);
          final viewport = wide ? const Size(1440, 900) : const Size(390, 844);
          await pump(
            tester,
            mode: mode,
            customExams: false,
            viewport: viewport,
          );
          await tester.pumpAndSettle();
          expect(find.text("My exam isn't listed"), findsNothing);
          expect(
            find.text('Set up your own and pick what it covers'),
            findsNothing,
          );
          expect(find.text('UPCAT'), findsOneWidget);
        });
        testWidgets(
            'hidden: an empty catalog has no own-exam action, $name '
            '$mode', (tester) async {
          debugWebPlatformOverride = true;
          addTearDown(() => debugWebPlatformOverride = null);
          final viewport = wide ? const Size(1440, 900) : const Size(390, 844);
          await pump(
            tester,
            mode: mode,
            customExams: false,
            data: Stream.value(const []),
            viewport: viewport,
          );
          await tester.pumpAndSettle();
          expect(find.text('No exams available right now.'), findsOneWidget);
          expect(find.text('Check back soon.'), findsOneWidget);
          expect(find.text('Set Up My Own Exam'), findsNothing);
          expect(find.textContaining('set up your own exam'), findsNothing);
        });
        testWidgets('offered: the row and the action stay, $name $mode',
            (tester) async {
          debugWebPlatformOverride = true;
          addTearDown(() => debugWebPlatformOverride = null);
          final viewport = wide ? const Size(1440, 900) : const Size(390, 844);
          await pump(tester, mode: mode, viewport: viewport);
          await tester.pumpAndSettle();
          expect(find.text("My exam isn't listed"), findsOneWidget);
        });
      }
    }
  });

  group('searching for an exam that is not there', () {
    for (final (name, wide) in [('phone', false), ('wide', true)]) {
      for (final mode in ExamPickerMode.values) {
        testWidgets('says nothing matched, $name $mode', (tester) async {
          debugWebPlatformOverride = wide;
          addTearDown(() => debugWebPlatformOverride = null);
          await pump(
            tester,
            mode: mode,
            viewport: wide ? const Size(1440, 900) : const Size(390, 844),
          );
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField), 'ZZZZ');
          await tester.pumpAndSettle();
          expect(find.text('Nothing matched \u201CZZZZ\u201D'), findsOneWidget);
          expect(
            find.text('Try a shorter word, or part of one.'),
            findsOneWidget,
          );
          expect(find.text('UPCAT'), findsNothing);
          await tester.enterText(find.byType(TextField), 'upcat');
          await tester.pumpAndSettle();
          expect(find.textContaining('Nothing matched'), findsNothing);
          expect(find.text('UPCAT'), findsOneWidget);
        });
      }
    }
  });

  group('your exams', () {
    const mine = 'exam_custom_a';
    const other = 'exam_custom_b';
    const away = 'exam_custom_c';
    late ContentDatabase contentDb;
    setUp(() => contentDb = openTestContentDatabase());

    Future<void> seed(List<(String, String)> tracks) async {
      for (final (id, name) in tracks) {
        await db.into(db.customTrackMetaLocal).insert(
              CustomTrackMetaLocalCompanion.insert(examId: id, name: name),
            );
      }
    }

    Map<String, Object?> serverTrack(String id, String? name) => {
          'examId': id,
          'name': name,
          'excludedTopicIds': <String>['topic_x'],
          'excludedLessonIds': <String>[],
          'blueprint': null,
          'createdAt': 1,
          'updatedAt': 2,
        };

    /// Overrides for a browser that asks the server: the answer comes from
    /// [reply], and every call is counted in [calls].
    List<Override> web(
      List<String> calls, {
      Object? Function()? reply,
    }) =>
        [
          studyUsesServerProvider.overrideWithValue(true),
          authStateProvider.overrideWith(
            (ref) => Stream.value(const AuthState.anonymous(uid: 'u1')),
          ),
          studyApiProvider.overrideWithValue(
            StudyApi((name, data) async {
              calls.add(name);
              return reply?.call() ??
                  {'activeExamId': null, 'tracks': <Object?>[]};
            }),
          ),
          customTrackRepositoryProvider.overrideWithValue(
            CustomTrackRepository(db, contentDb),
          ),
        ];

    Finder row(String id) => find.byKey(ValueKey('exam-$id'));
    final add = find.byKey(const ValueKey('custom-exam-add'));

    bool after(WidgetTester tester, Finder later, Finder earlier) {
      final a = tester.getTopLeft(later);
      final b = tester.getTopLeft(earlier);
      return a.dy > b.dy || (a.dy == b.dy && a.dx > b.dx);
    }

    Size viewportFor({required bool wide}) =>
        wide ? const Size(1440, 900) : const Size(390, 844);

    for (final wide in [false, true]) {
      for (final mode in ExamPickerMode.values) {
        for (final brightness in Brightness.values) {
          final name = '${wide ? 'wide' : 'phone'} $mode $brightness';
          testWidgets('rows, small line and the add row last, $name',
              (tester) async {
            debugWebPlatformOverride = wide;
            addTearDown(() => debugWebPlatformOverride = null);
            await seed([(mine, 'PUP CET'), (other, 'Bar Exam')]);
            await pump(
              tester,
              mode: mode,
              brightness: brightness,
              viewport: viewportFor(wide: wide),
            );
            await tester.pumpAndSettle();
            expect(find.text('YOUR EXAMS'), findsOneWidget);
            expect(find.text('PUP CET'), findsOneWidget);
            expect(find.text('Bar Exam'), findsOneWidget);
            expect(find.text('Your own exam'), findsNWidgets(2));
            expect(find.text("My exam isn't listed"), findsOneWidget);
            // The board's old row, with its small line, is gone.
            expect(
              find.text('Set up your own and pick what it covers'),
              findsNothing,
            );
            // Newest first, the add row inside the group after the last exam,
            // and the listed exams below the group.
            expect(after(tester, row(mine), row(other)), isTrue);
            expect(after(tester, add, row(mine)), isTrue);
            expect(after(tester, find.text('UPCAT'), add), isTrue);
            // The add row: its label in the accent color and no small line.
            expect(
              find.descendant(of: add, matching: find.byType(Text)),
              findsOneWidget,
            );
            final accent = wide
                ? tester.element(add).webTokens.colors.accent
                : tester.element(add).colors.accent;
            expect(
              tester
                  .widget<Text>(
                    find.descendant(of: add, matching: find.byType(Text)),
                  )
                  .style
                  ?.color,
              accent,
            );
            if (!wide && mode == ExamPickerMode.settings) {
              // Phone Settings (SettingsPh, kind pick, v B): no plus, a
              // chevron at the right, the name 16 px in and the chevron 16 px
              // from the right edge, the divider above inset 16.
              expect(
                find.descendant(of: add, matching: find.byType(SvgPicture)),
                findsNothing,
              );
              final chevron = find.descendant(
                of: add,
                matching: find.byType(Icon),
              );
              expect(chevron, findsOneWidget);
              expect(
                tester.widget<Icon>(chevron).icon,
                PantasIcons.bold(PantasIcons.next),
              );
              final rect = tester.getRect(add);
              expect(
                tester.getTopLeft(find.text("My exam isn't listed")).dx -
                    rect.left,
                16,
              );
              expect(rect.right - tester.getBottomRight(chevron).dx, 16);
              final divider = find.byKey(
                const ValueKey('custom-exam-add-divider'),
              );
              expect(divider, findsOneWidget);
              expect(tester.widget<Divider>(divider).indent, 16);
            } else {
              // Onboarding and the wide Settings dialog: a plus, no chevron.
              expect(
                find.descendant(of: add, matching: find.byType(SvgPicture)),
                findsOneWidget,
              );
              expect(
                find.descendant(of: add, matching: find.byType(Icon)),
                findsNothing,
              );
            }
            expect(tester.takeException(), isNull);
          });
        }

        testWidgets(
            'with no exams of your own the group holds the add row alone, '
            '${wide ? 'wide' : 'phone'} $mode', (tester) async {
          debugWebPlatformOverride = wide;
          addTearDown(() => debugWebPlatformOverride = null);
          await pump(tester, mode: mode, viewport: viewportFor(wide: wide));
          await tester.pumpAndSettle();
          expect(find.text('YOUR EXAMS'), findsOneWidget);
          expect(add, findsOneWidget);
          expect(find.text("My exam isn't listed"), findsOneWidget);
          expect(find.text('Your own exam'), findsNothing);
          expect(find.text('UPCAT'), findsOneWidget);
          // First in its group, the add row has no divider above it.
          expect(
            find.byKey(const ValueKey('custom-exam-add-divider')),
            findsNothing,
          );
        });

        testWidgets(
            'searching narrows your exams and keeps the add row, '
            '${wide ? 'wide' : 'phone'} $mode', (tester) async {
          debugWebPlatformOverride = wide;
          addTearDown(() => debugWebPlatformOverride = null);
          await seed([(mine, 'PUP CET'), (other, 'Bar Exam')]);
          await pump(tester, mode: mode, viewport: viewportFor(wide: wide));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField), 'bar');
          await tester.pumpAndSettle();
          expect(find.text('Bar Exam'), findsOneWidget);
          expect(find.text('PUP CET'), findsNothing);
          expect(add, findsOneWidget);
          expect(find.textContaining('Nothing matched'), findsNothing);
          await tester.enterText(find.byType(TextField), 'zzzz');
          await tester.pumpAndSettle();
          expect(find.text('Bar Exam'), findsNothing);
          expect(add, findsOneWidget);
          expect(find.textContaining('Nothing matched'), findsOneWidget);
        });
      }

      testWidgets(
          'Settings marks the current exam and picks another at once, '
          '${wide ? 'wide' : 'phone'}', (tester) async {
        debugWebPlatformOverride = wide;
        addTearDown(() => debugWebPlatformOverride = null);
        await seed([(mine, 'PUP CET'), (other, 'Bar Exam')]);
        final picked = <String>[];
        await pump(
          tester,
          mode: ExamPickerMode.settings,
          viewport: viewportFor(wide: wide),
          picked: (id) async => picked.add(id),
          extra: [
            activeExamFocusProvider.overrideWith(
              (ref) async => ActiveExamFocus.selected(
                buildExam(id: mine, shortName: 'PUP CET'),
              ),
            ),
          ],
        );
        await tester.pumpAndSettle();
        bool marked(String id) => wide
            ? find
                .descendant(
                  of: row(id),
                  matching: find.byIcon(PantasIcons.check),
                )
                .evaluate()
                .isNotEmpty
            : tester.widget<ListRow>(row(id)).selected;
        expect(marked(mine), isTrue);
        expect(marked(other), isFalse);
        await tester.tap(row(mine));
        await tester.pumpAndSettle();
        expect(picked, isEmpty);
        await tester.tap(row(other));
        await tester.pumpAndSettle();
        expect(picked, [other]);
      });

      testWidgets(
          'onboarding picks an exam of your own, then saves it on Continue, '
          '${wide ? 'wide' : 'phone'}', (tester) async {
        debugWebPlatformOverride = wide;
        addTearDown(() => debugWebPlatformOverride = null);
        await seed([(mine, 'PUP CET')]);
        final picked = <String>[];
        await pump(
          tester,
          viewport: viewportFor(wide: wide),
          picked: (id) async => picked.add(id),
        );
        await tester.pumpAndSettle();
        await tester.tap(row(mine));
        await tester.pump();
        expect(picked, isEmpty);
        expect(
          wide
              ? tester.widget<SelectableTile>(row(mine)).selected
              : tester.widget<ListRow>(row(mine)).selected,
          isTrue,
        );
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(picked, [mine]);
        final prefs = AppPreferencesRepository(db);
        expect(await prefs.selectedExamId(), mine);
        expect(await prefs.hasCompletedOnboarding(), isFalse);
      });

      testWidgets(
          'onboarding shows the saved exam of your own chosen again, '
          '${wide ? 'wide' : 'phone'}', (tester) async {
        debugWebPlatformOverride = wide;
        addTearDown(() => debugWebPlatformOverride = null);
        await seed([(mine, 'PUP CET')]);
        await AppPreferencesRepository(db).setSelectedExamId(mine);
        await pump(tester, viewport: viewportFor(wide: wide));
        await tester.pumpAndSettle();
        expect(
          wide
              ? tester.widget<SelectableTile>(row(mine)).selected
              : tester.widget<ListRow>(row(mine)).selected,
          isTrue,
        );
      });

      for (final mode in ExamPickerMode.values) {
        final layout = '${wide ? 'wide' : 'phone'} $mode';
        testWidgets(
            'the browser lists the exams it lacks, local wins, a nameless '
            'one is left out, $layout', (tester) async {
          debugWebPlatformOverride = wide;
          addTearDown(() => debugWebPlatformOverride = null);
          await seed([(mine, 'Local name')]);
          final calls = <String>[];
          await pump(
            tester,
            mode: mode,
            viewport: viewportFor(wide: wide),
            extra: web(
              calls,
              reply: () => {
                'activeExamId': mine,
                'tracks': [
                  serverTrack(mine, 'Server name'),
                  serverTrack(other, 'From the server'),
                  serverTrack(away, null),
                  serverTrack('exam_custom_d', '   '),
                ],
              },
            ),
          );
          await tester.pumpAndSettle();
          expect(calls, ['getCustomTracks']);
          expect(find.text('Local name'), findsOneWidget);
          expect(find.text('From the server'), findsOneWidget);
          expect(find.text('Server name'), findsNothing);
          expect(find.text('Your own exam'), findsNWidgets(2));
          expect(row(away), findsNothing);
          expect(row('exam_custom_d'), findsNothing);
          expect(after(tester, add, row(other)), isTrue);
        });

        testWidgets(
            'picking an exam only the server holds brings it here first, '
            '$layout', (tester) async {
          debugWebPlatformOverride = wide;
          addTearDown(() => debugWebPlatformOverride = null);
          final order = <String>[];
          await pump(
            tester,
            mode: mode,
            viewport: viewportFor(wide: wide),
            picked: (id) async {
              final held = await db.select(db.customTrackMetaLocal).get();
              order.add('picked $id after ${held.map((r) => r.name)}');
            },
            extra: web(
              [],
              reply: () => {
                'activeExamId': null,
                'tracks': [serverTrack(other, 'From the server')],
              },
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(row(other));
          await tester.pumpAndSettle();
          if (mode == ExamPickerMode.onboarding) {
            expect(order, isEmpty);
            await tester.tap(find.text('Continue'));
            await tester.pumpAndSettle();
          }
          expect(order, ['picked $other after (From the server)']);
          // The track is now this browser's own, with its scope.
          final scope = await db.select(db.trackScopeLocal).get();
          expect(scope.map((r) => r.topicId), ['topic_x']);
          // And it is listed once, not twice.
          expect(find.text('From the server'), findsOneWidget);
        });

        testWidgets(
            'a failed read shows this device and the add row, and is '
            'reported with no name, $layout', (tester) async {
          debugWebPlatformOverride = wide;
          addTearDown(() => debugWebPlatformOverride = null);
          await seed([(mine, 'PUP CET')]);
          final telemetry = _RecordingTelemetry();
          await pump(
            tester,
            mode: mode,
            viewport: viewportFor(wide: wide),
            extra: [
              ...web([], reply: () => throw StateError('offline')),
              telemetryProvider.overrideWithValue(telemetry),
            ],
          );
          await tester.pumpAndSettle();
          expect(find.text('PUP CET'), findsOneWidget);
          expect(add, findsOneWidget);
          expect(find.text('UPCAT'), findsOneWidget);
          expect(telemetry.errors, hasLength(1));
          expect(telemetry.errors.single.toString(), isNot(contains('PUP')));
        });

        testWidgets('a phone never asks the server, $layout', (tester) async {
          debugWebPlatformOverride = wide;
          addTearDown(() => debugWebPlatformOverride = null);
          await seed([(mine, 'PUP CET')]);
          final calls = <String>[];
          await pump(
            tester,
            mode: mode,
            viewport: viewportFor(wide: wide),
            extra: [
              ...web(calls),
              studyUsesServerProvider.overrideWithValue(false),
            ],
          );
          await tester.pumpAndSettle();
          expect(calls, isEmpty);
          expect(find.text('PUP CET'), findsOneWidget);
        });

        testWidgets(
            'with the own-exam flag off nothing shows and nothing is read, '
            '$layout', (tester) async {
          debugWebPlatformOverride = wide;
          addTearDown(() => debugWebPlatformOverride = null);
          await seed([(mine, 'PUP CET')]);
          final calls = <String>[];
          await pump(
            tester,
            mode: mode,
            customExams: false,
            viewport: viewportFor(wide: wide),
            extra: web(
              calls,
              reply: () => {
                'activeExamId': null,
                'tracks': [serverTrack(other, 'From the server')],
              },
            ),
          );
          await tester.pumpAndSettle();
          expect(calls, isEmpty);
          expect(find.text('YOUR EXAMS'), findsNothing);
          expect(find.text('PUP CET'), findsNothing);
          expect(find.text('From the server'), findsNothing);
          expect(find.text('Your own exam'), findsNothing);
          expect(add, findsNothing);
          expect(find.text("My exam isn't listed"), findsNothing);
          expect(find.text('UPCAT'), findsOneWidget);
        });
      }
    }
  });
}
