import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/nav_glyph.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

import '../../helpers/in_memory_database.dart';

Widget harness({
  required int currentIndex,
  required ValueChanged<int> onTap,
  bool disableAnimations = false,
  TextScaler? textScaler,
}) {
  return MaterialApp(
    theme: buildLightTheme(),
    home: MediaQuery(
      data: MediaQueryData(
        disableAnimations: disableAnimations,
        textScaler: textScaler ?? TextScaler.noScaling,
      ),
      child: Scaffold(
        bottomNavigationBar: AppNavBar(
          currentIndex: currentIndex,
          onTap: onTap,
        ),
      ),
    ),
  );
}

double fillOf(WidgetTester tester, NavGlyphKind kind) {
  final glyph = tester.widget<NavGlyph>(
    find.byWidgetPredicate((w) => w is NavGlyph && w.kind == kind),
  );
  return glyph.fill;
}

void main() {
  group('App navigation shell integration', () {
    late AppDatabase db;

    setUp(() async {
      db = inMemoryDatabase();
      await db.into(db.exams).insert(
            ExamsCompanion.insert(
              id: 'cse',
              code: 'CSE',
              name: 'Civil Service Exam',
              shortName: 'CSE',
              language: 'en',
            ),
          );
      await AppPreferencesRepository(db).setPassedAgeGate(value: true);
      await AppPreferencesRepository(db).setSelectedExamId('cse');
    });

    tearDown(() => db.close());

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const App(flavor: Flavor.dev),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders four tabs: Home, Study, Quiz, Progress',
        (tester) async {
      await pumpApp(tester);

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Study'), findsWidgets);
      expect(find.text('Quiz'), findsWidgets);
      expect(find.text('Progress'), findsWidgets);
      expect(find.text('Settings'), findsNothing);
      expect(find.text('Learn'), findsNothing);
    });

    testWidgets('tapping Study tab navigates to Study screen', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Study').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Study'), findsWidgets);
    });

    testWidgets('tapping Quiz tab navigates to Quiz screen', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Quiz').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Quiz'), findsWidgets);
    });

    testWidgets('tapping Progress tab navigates to Progress screen',
        (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Progress').last);
      await tester.pumpAndSettle();

      expect(find.text('Progress'), findsWidgets);
    });
  });

  group('AppNavBar unit tests', () {
    testWidgets('renders four labelled glyphs', (tester) async {
      await tester.pumpWidget(harness(currentIndex: 0, onTap: (_) {}));
      expect(find.byType(NavGlyph), findsNWidgets(4));
      for (final label in ['Home', 'Study', 'Quiz', 'Progress']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets(
      'survives 320dp width at 200% text without layout overflow',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          harness(
            currentIndex: 0,
            onTap: (_) {},
            textScaler: const TextScaler.linear(2),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        for (final label in ['Home', 'Study', 'Quiz', 'Progress']) {
          expect(find.text(label), findsOneWidget);
          final target = find.ancestor(
            of: find.text(label),
            matching: find.byType(InkWell),
          );
          expect(target, findsOneWidget);
          final size = tester.getSize(target);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
        }
      },
    );

    testWidgets(
      'keeps Progress on one line at observed API 36 large-text geometry',
      (tester) async {
        tester.view.devicePixelRatio = 1.0;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);

        // Android 16's platform text scaler is nonlinear. A linear 2x scaler
        // overstates the observed scaling of these 11sp navigation labels:
        // on the API 36 device Home/Study/Quiz stayed on one line while only
        // Progress wrapped. 1.75 reproduces that label geometry in the widget
        // harness; the real device remains the final platform-level proof.
        await tester.pumpWidget(
          harness(
            currentIndex: 0,
            onTap: (_) {},
            textScaler: const TextScaler.linear(1.75),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text('Progress'),
        );
        final selectionBoxes = paragraph.getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: 8),
        );
        expect(
          selectionBoxes,
          hasLength(1),
          reason: 'Progress must not split mid-word at large text.',
        );
      },
    );

    testWidgets('the active glyph settles filled and the others stay empty',
        (tester) async {
      await tester.pumpWidget(harness(currentIndex: 0, onTap: (_) {}));
      await tester.pumpAndSettle();
      expect(fillOf(tester, NavGlyphKind.home), 1.0);
      expect(fillOf(tester, NavGlyphKind.study), 0.0);
      expect(fillOf(tester, NavGlyphKind.quiz), 0.0);
      expect(fillOf(tester, NavGlyphKind.progress), 0.0);
    });

    testWidgets('the outgoing tab drains instantly, the incoming one rises',
        (tester) async {
      await tester.pumpWidget(harness(currentIndex: 0, onTap: (_) {}));
      await tester.pumpAndSettle();

      await tester.pumpWidget(harness(currentIndex: 2, onTap: (_) {}));
      await tester.pump(const Duration(milliseconds: 200));

      // Outgoing: gone on the first frame, not fading.
      expect(fillOf(tester, NavGlyphKind.home), 0.0);
      // Incoming: partway up.
      final quiz = fillOf(tester, NavGlyphKind.quiz);
      expect(quiz, greaterThan(0.0));
      expect(quiz, lessThan(1.0));

      await tester.pumpAndSettle();
      expect(fillOf(tester, NavGlyphKind.quiz), 1.0);
    });

    testWidgets('reduce-motion swaps without animating', (tester) async {
      await tester.pumpWidget(
        harness(currentIndex: 0, onTap: (_) {}, disableAnimations: true),
      );
      await tester.pumpWidget(
        harness(currentIndex: 3, onTap: (_) {}, disableAnimations: true),
      );
      // One frame, already at the destination.
      await tester.pump();
      expect(fillOf(tester, NavGlyphKind.progress), 1.0);
      expect(fillOf(tester, NavGlyphKind.home), 0.0);
    });

    testWidgets('tapping reports the index', (tester) async {
      final taps = <int>[];
      await tester.pumpWidget(harness(currentIndex: 0, onTap: taps.add));
      await tester.tap(find.text('Progress'));
      expect(taps, [3]);
    });

    testWidgets('no board green anywhere in the bar', (tester) async {
      await tester.pumpWidget(harness(currentIndex: 1, onTap: (_) {}));
      await tester.pumpAndSettle();
      final board = AppColors.light.board;
      for (final glyph in tester.widgetList<NavGlyph>(find.byType(NavGlyph))) {
        expect(glyph.color, isNot(board));
      }
      for (final text in tester.widgetList<Text>(
        find.descendant(
          of: find.byType(AppNavBar),
          matching: find.byType(Text),
        ),
      )) {
        expect(text.style?.color, isNot(board));
      }
    });

    testWidgets('the active label is w700 and the rest are not',
        (tester) async {
      await tester.pumpWidget(harness(currentIndex: 1, onTap: (_) {}));
      expect(
        tester.widget<Text>(find.text('Study')).style?.fontWeight,
        FontWeight.w700,
      );
      expect(
        tester.widget<Text>(find.text('Home')).style?.fontWeight,
        isNot(FontWeight.w700),
      );
    });

    testWidgets('the current tab is selected in semantics', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(harness(currentIndex: 1, onTap: (_) {}));

      final study = tester.getSemantics(find.bySemanticsLabel('Study'));
      final home = tester.getSemantics(find.bySemanticsLabel('Home'));

      expect(study.flagsCollection.isSelected, Tristate.isTrue);
      expect(home.flagsCollection.isSelected, Tristate.isFalse);
      semantics.dispose();
    });
  });
}
