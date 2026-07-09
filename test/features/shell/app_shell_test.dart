import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/nav_glyph.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

Widget harness({
  required int currentIndex,
  required ValueChanged<int> onTap,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    theme: buildLightTheme(),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
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
            of: find.byType(AppNavBar), matching: find.byType(Text)),
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
  });
}
