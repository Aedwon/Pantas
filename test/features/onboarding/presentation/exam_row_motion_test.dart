import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';

import '../../../core/ui/motion/preview_curves.dart';
import '../../../helpers/in_memory_database.dart';

// Item 17, demo 4 on the Settings exam picker (wide web): the chosen row's tint
// fades in over 160 ms on the ease, and its label keeps one weight.
const _entries = [
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
];

void main() {
  late AppDatabase db;
  setUp(() {
    db = inMemoryDatabase();
    debugWebPlatformOverride = true;
  });
  tearDown(() {
    debugWebPlatformOverride = null;
    return db.close();
  });
  final theme = buildLightTheme(web: true);

  Future<Completer<void>> pumpPicker(
    WidgetTester tester, {
    bool reduced = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final saving = Completer<void>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(_entries)),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp(
          theme: theme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: Scaffold(
            body: ExamPickerScreen(
              mode: ExamPickerMode.settings,
              onPicked: (_) => saving.future,
              onCustom: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return saving;
  }

  Color fill(WidgetTester tester) => (tester
          .widget<DecoratedBox>(
            find
                .ancestor(
                  of: find.text('UPCAT'),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .decoration as BoxDecoration)
      .color!;

  FontWeight? weight(WidgetTester tester) =>
      tester.widget<Text>(find.text('UPCAT')).style?.fontWeight;

  testWidgets('choosing a row fades its tint in, 160 ms on the ease',
      (tester) async {
    final saving = await pumpPicker(tester);
    final off = fill(tester);
    expect(off.a, 0);
    await tester.tap(find.text('UPCAT'));
    await tester.pump();
    await tester.pump();
    var elapsed = 0;
    double alpha() => fill(tester).a;
    double full = 0;
    for (final ms in [40, 40, 40]) {
      await tester.pump(Duration(milliseconds: ms));
      elapsed += ms;
      expect(weight(tester), FontWeight.w400, reason: 'no bold at $elapsed');
      full = alpha();
      expect(full, greaterThan(0), reason: 'fading in at $elapsed');
    }
    await tester.pump(const Duration(milliseconds: 40));
    final end = alpha();
    expect(end, 1);
    // The middle frame sits on the ease between 0 and 1.
    expect(full, closeTo(previewEase(120 / 160), .02));
    saving.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion shows the final tint in one frame',
      (tester) async {
    final saving = await pumpPicker(tester, reduced: true);
    await tester.tap(find.text('UPCAT'));
    await tester.pump();
    await tester.pump();
    expect(fill(tester).a, 1);
    saving.complete();
    await tester.pumpAndSettle();
  });
}
