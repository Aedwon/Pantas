import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/components/sort_cycle_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
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
          onPro: () {},
          onBack: () {},
        ),
      );
  testWidgets('the wide lists draw no header row (PF_Subjects, PF_Topics)',
      (tester) async {
    addTearDown(() => debugWebPlatformOverride = null);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(1440, 900);
    debugWebPlatformOverride = true;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: PerformancePage(
          data: data,
          pro: true,
          paused: false,
          onTopic: (_) {},
          onPro: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Subjects: the name and its topic count, then the bar and the percent.
    expect(find.byKey(const ValueKey('performance-table')), findsOneWidget);
    for (final head in ['SUBJECT', 'ANSWERED', 'ACCURACY']) {
      expect(find.text(head), findsNothing);
    }
    expect(find.textContaining('Math'), findsWidgets);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    for (final head in ['TOPIC', 'ANSWERED', 'ACCURACY']) {
      expect(find.text(head), findsNothing);
    }
    // The answered count is a quiet "(N)" after the name, not a column
    // (Aedwon, Nov 26).
    expect(find.textContaining('(2)'), findsOneWidget);
  });

  testWidgets('a Free phone shows what the wide page shows', (tester) async {
    await tester.pumpWidget(show(pro: false));
    await tester.pumpAndSettle();
    // The Pro marks on the locked views and the card that opens Pro, on the
    // Subjects view too. DT_Free draws no line under the title (P13).
    expect(
      find.text("Accuracy across everything you've answered."),
      findsNothing,
    );
    expect(find.byType(ProMark), findsNWidgets(2));
    expect(find.text('Go deeper with Pro'), findsOneWidget);
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });

  testWidgets('a Pro phone has no Pro marks and no card', (tester) async {
    await tester.pumpWidget(show());
    await tester.pumpAndSettle();
    expect(find.byType(ProMark), findsNothing);
    expect(find.text('Go deeper with Pro'), findsNothing);
  });

  testWidgets(
      'Topics start weakest first, omit unanswered, cycle strongest then name',
      (tester) async {
    await tester.pumpWidget(show());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.text('Empty'), findsNothing);
    expect(
      tester.getTopLeft(find.textContaining('Geometry')).dy,
      lessThan(tester.getTopLeft(find.textContaining('Algebra')).dy),
    );
    await tester.tap(find.bySemanticsLabel('Sort: Weakest first'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.textContaining('Algebra')).dy,
      lessThan(tester.getTopLeft(find.textContaining('Geometry')).dy),
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
    expect(find.textContaining('Algebra'), findsNothing);
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
  testWidgets('rows read parent and a bracketed count, with the singular',
      (tester) async {
    await tester.pumpWidget(show());
    await tester.pumpAndSettle();
    expect(find.text('2 topics'), findsOneWidget);
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.text('Subject'), findsWidgets);
    expect(find.textContaining('(4)'), findsOneWidget);
  });
  testWidgets('Free Subjects view lists subjects and shows the invitation',
      (tester) async {
    // The phone shows what the wide page shows (lead ruling, Nov 9): the
    // Pro card under the list on every view for a Free account.
    await tester.pumpWidget(show(pro: false));
    await tester.pumpAndSettle();
    expect(find.textContaining('Math'), findsOneWidget);
    expect(find.text('Go deeper with Pro'), findsOneWidget);
  });
  testWidgets('Free Topics replaces the list with one card and dims sort',
      (tester) async {
    await tester.pumpWidget(show(pro: false));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Math'), findsNothing);
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
    await tester.tap(find.textContaining('Math'));
    await tester.pumpAndSettle();
    expect(find.text('Go deeper with Pro'), findsOneWidget);
  });
  testWidgets('Pro tapping a subject lists only its topics', (tester) async {
    await tester.pumpWidget(show());
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Math'));
    await tester.pumpAndSettle();
    expect(find.text('MATH'), findsOneWidget);
    expect(find.textContaining('Geometry'), findsOneWidget);
  });

  // Boards DT_Free, DT_TopicsA: the ring block starts 20 px under the title,
  // plus its own 4 px (P13).
  testWidgets('the ring sits 24 px under the title', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(show(pro: false));
    await tester.pumpAndSettle();
    final title = tester.getRect(find.text('Your performance'));
    final ring = tester.getRect(find.byType(HalfRingGauge));
    expect(ring.top - title.bottom, closeTo(24, .5));
  });
}
