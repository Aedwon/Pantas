// T5 (U43): the boards draw no Close or Cancel under these phone sheets, so
// the code draws none ("Cancel and Close: match the boards; no Close where the
// board draws none"). Escape, a scrim tap and a drag still close a sheet.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

import '../../../helpers/ds_matrix.dart' show loadDsFonts;

/// File and the board that draws the sheet without a Close or Cancel.
const _sheets = {
  'lib/features/home/presentation/home_today_screen.dart':
      'HE_ManyLessons (Lessons, Reviews, New questions)',
  'lib/features/home/presentation/home_tab.dart': 'HP_NoDate (exam date)',
  'lib/features/home/presentation/performance_page.dart':
      'DT_FilterFlow (Subjects)',
  'lib/features/quiz/presentation/quiz_tab_screen.dart':
      'QZ_Tab, QZE_One (New questions, Reviews)',
  'lib/features/quiz/presentation/quiz_page.dart': 'QV_Sources (Passage)',
  'lib/features/quiz/presentation/practice_picker_screen.dart':
      'QZS_1 (How long?)',
  'lib/features/lesson/presentation/learn_tab_home.dart': 'BM_Open (Bookmarks)',
  'lib/features/lesson/presentation/lesson_page.dart': 'RD_Contents',
  'lib/core/ui/components/new_design/question_grid_sheet.dart':
      'QV_Grid, QV_GridMock (question grid)',
};

void main() {
  setUpAll(loadDsFonts);
  for (final entry in _sheets.entries) {
    test('${entry.key} draws no Close or Cancel (${entry.value})', () {
      final source = File(entry.key).readAsStringSync();
      expect(source, contains('PantasSheet('));
      expect(source, isNot(contains('closeLabel')));
    });
  }

  test('no screen file passes a closeLabel to a PantasSheet', () {
    final offenders = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final path = file.path;
      // The widget itself, the component gallery, and the wide side drawer
      // (its own closeLabel, a tooltip) are not screens.
      if (path.endsWith('pantas_sheet.dart') ||
          path.contains('/gallery/') ||
          path.endsWith('web_side_drawer.dart') ||
          path.endsWith('web_question.dart')) {
        continue;
      }
      if (RegExp('closeLabel:').hasMatch(file.readAsStringSync())) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty);
  });

  group('the Close action, when a board does draw one', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: PantasSheet(
                page: const SizedBox.expand(),
                label: 'Questions',
                open: true,
                closeLabel: 'Close',
                onDismiss: () {},
                child: const SizedBox(height: 200, child: Text('Saved items')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('is a 44 high text button at its natural width, centered',
        (tester) async {
      await pump(tester);
      // The drawn button, inside Material's 48 tap box.
      final button = tester.getRect(
        find
            .descendant(
              of: find.byType(TextButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(button.height, 44);
      expect(button.width, lessThan(120));
      expect(button.center.dx, closeTo(390 / 2, 4));
    });

    testWidgets('sits 34 above the bottom edge with no safe area',
        (tester) async {
      await pump(tester);
      final surface = tester.getRect(
        find.byKey(const ValueKey('pantas-sheet-surface')),
      );
      // The 48 tap box ends 34 above the edge, as the sheet bottom pads.
      expect(
        surface.bottom - tester.getRect(find.byType(TextButton)).bottom,
        34,
      );
    });
  });

  group('a sheet that ends on its own control (HE_ManyLessons)', () {
    Future<void> pump(WidgetTester tester, {double inset = 0}) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              padding: EdgeInsets.only(bottom: inset),
              viewPadding: EdgeInsets.only(bottom: inset),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: PantasSheet(
                page: const SizedBox.expand(),
                label: 'New questions',
                open: true,
                onDismiss: () {},
                child: TodayQuestionsSheet(
                  title: 'New questions',
                  done: 3,
                  total: 10,
                  rows: [
                    TodayQuestionRow(
                      title: 'Fractions',
                      subtitle: 'Mathematics',
                      done: 3,
                      total: 5,
                      onTap: () {},
                    ),
                  ],
                  startLabel: 'Start New Questions',
                  onStart: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('has no Close and ends on Start, 34 above the edge',
        (tester) async {
      await pump(tester);
      expect(find.text('Close'), findsNothing);
      final surface = tester.getRect(
        find.byKey(const ValueKey('pantas-sheet-surface')),
      );
      final start = tester.getRect(
        find.widgetWithText(TextButton, 'Start New Questions'),
      );
      expect(start.height, 52);
      expect(surface.bottom - start.bottom, 34);
    });

    testWidgets('clears a 34 high home indicator by 20', (tester) async {
      await pump(tester, inset: 34);
      final surface = tester.getRect(
        find.byKey(const ValueKey('pantas-sheet-surface')),
      );
      final start = tester.getRect(
        find.widgetWithText(TextButton, 'Start New Questions'),
      );
      expect(surface.bottom - start.bottom, 54);
    });
  });
}
