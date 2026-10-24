import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';

void main() {
  PerformanceRow row(String id, int right, int total) => PerformanceRow(
        id: id,
        title: id,
        subtext: 'Subject',
        correct: right,
        answered: total,
        secondsPerQuestion: null,
      );
  final data = PerformanceViewData(
    subjects: [row('Math', 8, 10)],
    topics: [row('Algebra', 1, 2), row('Geometry', 1, 4), row('Empty', 0, 0)],
    lessons: [],
    subjectCounts: {'Math': 2},
    lessonLevelAvailable: true,
    parentSubjectIds: {'Algebra': 'Math', 'Geometry': 'Math', 'Empty': 'Math'},
  );
  Widget show({bool pro = true, bool paused = false}) => MaterialApp(
        theme: buildLightTheme(),
        home: PerformancePage(
          data: data,
          pro: pro,
          paused: paused,
          onTopic: (_) {},
          onPractice: () {},
          onPro: () {},
          onBack: () {},
        ),
      );
  testWidgets(
      'Topics start weakest first, omit unanswered, cycle strongest then name',
      (tester) async {
    await tester.pumpWidget(show());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.text('Empty'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Geometry')).dy,
      lessThan(tester.getTopLeft(find.text('Algebra')).dy),
    );
    await tester.tap(find.bySemanticsLabel('Sort: Weakest first'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Algebra')).dy,
      lessThan(tester.getTopLeft(find.text('Geometry')).dy),
    );
    expect(find.text('Time'), findsNothing);
  });
  testWidgets(
      'Free gate keeps public subjects and shows the approved invitation',
      (tester) async {
    await tester.pumpWidget(show(pro: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.text('Go deeper with Pro'), findsOneWidget);
    expect(find.text('Unlock with Pro'), findsOneWidget);
    expect(find.text('Algebra'), findsNothing);
  });
  testWidgets('paused access shows paused line rather than selling Pro',
      (tester) async {
    await tester.pumpWidget(show(pro: false, paused: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.text('Connect once to keep using Pro.'), findsOneWidget);
    expect(find.text('Unlock with Pro'), findsNothing);
  });
  testWidgets('rows read parent, answered count and use the singular',
      (tester) async {
    await tester.pumpWidget(show());
    await tester.pumpAndSettle();
    expect(find.text('2 topics'), findsOneWidget);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.text('Subject · 4 answered'), findsOneWidget);
  });
  testWidgets('Free Subjects view is a plain list with no invitation',
      (tester) async {
    await tester.pumpWidget(show(pro: false));
    await tester.pumpAndSettle();
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('Go deeper with Pro'), findsNothing);
  });
  testWidgets('Free Topics replaces the list with one card and dims sort',
      (tester) async {
    await tester.pumpWidget(show(pro: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.text('Math'), findsNothing);
    expect(find.text('1 SUBJECTS'), findsNothing);
    expect(find.text('Go deeper with Pro'), findsOneWidget);
    final dim = tester.widget<Opacity>(
      find.ancestor(
        of: find.byType(SortCycleButton),
        matching: find.byType(Opacity),
      ),
    );
    expect(dim.opacity, closeTo(.35, .001));
  });
  testWidgets('Free tapping a subject slides to Topics with it picked',
      (tester) async {
    await tester.pumpWidget(show(pro: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Math'));
    await tester.pumpAndSettle();
    expect(find.text('Go deeper with Pro'), findsOneWidget);
  });
  testWidgets('Pro tapping a subject lists only its topics', (tester) async {
    await tester.pumpWidget(show());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Math'));
    await tester.pumpAndSettle();
    expect(find.text('MATH'), findsOneWidget);
    expect(find.text('Geometry'), findsOneWidget);
  });
}
