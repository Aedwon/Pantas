import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/data_table.dart';
import 'package:pantas/core/ui/components/score_breakdown_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_layout_theme.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';

import '../../../helpers/ds_matrix.dart';

/// The wide Performance rows are the system DataTable and the phone rows are
/// the StatRow. Values, order and the keys that open a row do not change.
void main() {
  tearDown(() => debugWebPlatformOverride = null);
  const subject = PerformanceRow(
    id: 'math',
    title: 'Mathematics',
    subtext: null,
    correct: 6,
    answered: 10,
    secondsPerQuestion: null,
  );
  const topic = PerformanceRow(
    id: 'geo',
    title: 'Geometry',
    subtext: 'Mathematics',
    correct: 2,
    answered: 5,
    secondsPerQuestion: null,
  );
  const data = PerformanceViewData(
    subjects: [subject],
    topics: [topic],
    lessons: [],
    subjectCounts: {'math': 1},
    lessonLevelAvailable: false,
    parentSubjectIds: {'geo': 'math'},
  );

  Widget page({
    required bool web,
    required DsCell cell,
    List<String>? opened,
  }) =>
      MediaQuery(
        data: MediaQueryData(
          size: Size(cell.width, 1000),
          textScaler: TextScaler.linear(cell.scale),
          disableAnimations: true,
        ),
        child: MaterialApp(
          theme:
              cell.dark ? buildDarkTheme(web: web) : buildLightTheme(web: web),
          home: WebLayoutTheme(
            web: web,
            child: PerformancePage(
              data: data,
              pro: true,
              paused: false,
              onTopic: (id) => opened?.add(id),
              onPro: () {},
              onBack: () {},
            ),
          ),
        ),
      );

  for (final cell in dsShellCells.where((c) => c.width >= 1100)) {
    testWidgets('wide rows are a DataTable with the same values ($cell)',
        (tester) async {
      tester.view
        ..physicalSize = Size(cell.width, 1000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      debugWebPlatformOverride = true;
      await tester.pumpWidget(page(web: true, cell: cell));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(PantasDataTable), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('1 topic'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('SUBJECT'), findsOneWidget);
      expect(find.text('0%'), findsNothing);
    });
  }

  testWidgets('Enter on a row opens its topics and Enter on a topic opens it',
      (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugWebPlatformOverride = true;
    final opened = <String>[];
    await tester.pumpWidget(
      page(web: true, cell: dsShellCells.last, opened: opened),
    );
    await tester.pumpAndSettle();
    expect(find.text('Geometry'), findsNothing);
    // Focus the subject row and press Enter.
    Focus.of(tester.element(find.text('Mathematics'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Geometry'), findsOneWidget);
    Focus.of(tester.element(find.text('Geometry'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(opened, ['geo']);
  });

  for (final cell in dsCells.where((c) => c.width == 390)) {
    testWidgets('phone rows are StatRows with name, subtitle and value ($cell)',
        (tester) async {
      tester.view
        ..physicalSize = Size(cell.width, 1000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      debugWebPlatformOverride = false;
      await tester.pumpWidget(page(web: false, cell: cell));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ScoreBreakdownRow), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('1 topic'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });
  }
}
