import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_layout_theme.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';
import 'package:pantas/features/home/presentation/topic_detail_page.dart';

void main() {
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
  const lesson = PerformanceRow(
    id: 'circles',
    title: 'Circles',
    subtext: 'Geometry',
    correct: 1,
    answered: 3,
    secondsPerQuestion: null,
  );
  const data = PerformanceViewData(
    subjects: [subject],
    topics: [topic],
    lessons: [lesson],
    subjectCounts: {'math': 1},
    lessonLevelAvailable: true,
    parentSubjectIds: {'geo': 'math', 'circles': 'math'},
  );
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);
  for (final dark in [false, true]) {
    Future<void> show(WidgetTester tester, {bool pro = true}) async {
      tester.view.resetPhysicalSize();
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme() : buildLightTheme(),
          home: WebLayoutTheme(
            web: true,
            child: PerformancePage(
              data: data,
              pro: pro,
              paused: false,
              onTopic: (_) {},
              onPro: () {},
              onBack: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('wide performance subjects expand in place, dark=$dark',
        (tester) async {
      await show(tester);
      expect(
        find.text("Accuracy across everything you've answered."),
        findsOneWidget,
      );
      expect(find.byType(WebSegmentedControl), findsOneWidget);
      expect(find.text('Geometry'), findsNothing);
      await tester.tap(find.text('Mathematics'));
      await tester.pumpAndSettle();
      expect(find.text('Geometry'), findsOneWidget);
      final topicRow = tester.widget<WebRow>(
        find.ancestor(of: find.text('Geometry'), matching: find.byType(WebRow)),
      );
      expect(topicRow.compact, isTrue);
      expect(find.text('Subjects'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide performance topics, filter, sort and lessons, dark=$dark',
        (tester) async {
      await show(tester);
      await tester.tap(find.text('Topics'));
      await tester.pumpAndSettle();
      expect(find.text('5 answered'), findsOneWidget);
      await tester.tap(find.text('All subjects'));
      await tester.pumpAndSettle();
      expect(find.text('Mathematics'), findsWidgets);
      await tester.tap(find.text('Mathematics').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weakest first'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A to Z'));
      await tester.pumpAndSettle();
      expect(find.textContaining('A TO Z'), findsOneWidget);
      await tester.tap(find.text('Lessons'));
      await tester.pumpAndSettle();
      expect(find.text('Circles'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide topic drawer stats and lesson actions, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? opened;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 440,
                child: TopicDetailPage(
                  detail: TopicDetail(
                    topicId: 'geo',
                    name: 'Geometry',
                    subject: 'Mathematics',
                    correct: 2,
                    answered: 5,
                    lessons: const [
                      TopicLesson(
                        id: 'lines',
                        title: 'Lines and angles',
                        read: true,
                        today: false,
                      ),
                      TopicLesson(
                        id: 'circles',
                        title: 'Circles',
                        read: false,
                        today: true,
                      ),
                    ],
                  ),
                  onBack: () {},
                  onLesson: (id) => opened = id,
                  onPractice: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('web-performance-topic')),
        findsOneWidget,
      );
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      final tokens = WebTokens(dark ? Brightness.dark : Brightness.light);
      final readTitle = tester.widget<Text>(find.text('Lines and angles'));
      expect(readTitle.style?.color, tokens.colors.secondaryLabel);
      final readCircle = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.label == 'Read',
          ),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        (readCircle.decoration as BoxDecoration).color,
        tokens.colors.accentFill,
      );
      final today = tester.widget<Text>(find.text('Today'));
      expect(today.style?.color, tokens.tintText);
      final tag = tester.widget<Container>(
        find
            .ancestor(of: find.text('Today'), matching: find.byType(Container))
            .first,
      );
      expect(
        (tag.decoration! as BoxDecoration).color,
        tokens.colors.accentTint,
      );
      await tester.tap(find.text('Circles'));
      expect(opened, 'circles');
      expect(tester.takeException(), isNull);
    });
    testWidgets('wide Free keeps subject list and invites Pro, dark=$dark',
        (tester) async {
      await show(tester, pro: false);
      expect(find.byType(ProTag), findsNWidgets(2));
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Go deeper with Pro'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      final icon = tester.getCenter(find.byIcon(Icons.lock_outline_rounded));
      final copy = tester.getCenter(find.text('Go deeper with Pro'));
      final button = tester.getCenter(find.text('Unlock with Pro'));
      expect(icon.dx, lessThan(copy.dx));
      expect(copy.dx, lessThan(button.dx));
      expect(icon.dy, button.dy);
      await tester.tap(find.text('Topics'));
      await tester.pumpAndSettle();
      expect(find.text('Geometry'), findsNothing);
      expect(find.text('Unlock with Pro'), findsOneWidget);
    });
  }
}
