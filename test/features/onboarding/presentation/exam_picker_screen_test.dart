import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';

import '../../../helpers/accessibility.dart';
import '../../../helpers/in_memory_database.dart';

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
          ],
          child: ExamPickerScreen(
            mode: mode,
            onPicked: picked ?? (_) async {},
            onCustom: () {},
            onBack: back,
          ),
        ),
        brightness: brightness,
        textScale: scale,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );

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
        final ink = tester.widget<InkWell>(
          find.descendant(of: row, matching: find.byType(InkWell)),
        );
        expect(ink.onTap, isNull);
        expect(
          tester
              .widget<Opacity>(
                find.descendant(of: row, matching: find.byType(Opacity)),
              )
              .opacity,
          .45,
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
}
