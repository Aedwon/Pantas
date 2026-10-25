import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';
import 'package:pantas/features/home/presentation/topic_detail_page.dart';

TopicDetail detail({int answered = 9, int correct = 4}) => TopicDetail(
      topicId: 'geo',
      name: 'Geometry',
      subject: 'Mathematics',
      correct: correct,
      answered: answered,
      lessons: const [
        TopicLesson(
          id: 'l1',
          title: 'Lines and angles',
          read: true,
          today: false,
        ),
        TopicLesson(id: 'l2', title: 'Triangles', read: true, today: false),
        TopicLesson(id: 'l3', title: 'Circles', read: false, today: true),
        TopicLesson(id: 'l4', title: 'Polygons', read: false, today: false),
        TopicLesson(
          id: 'l5',
          title: 'Solid figures',
          read: false,
          today: false,
        ),
      ],
    );

Widget show(
  TopicDetail data, {
  bool large = false,
  bool dark = false,
  ValueChanged<String>? onLesson,
  VoidCallback? onPractice,
}) =>
    MaterialApp(
      theme: dark ? buildDarkTheme() : buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(390, 844),
          textScaler: TextScaler.linear(large ? 2 : 1),
          disableAnimations: true,
        ),
        child: TopicDetailPage(
          detail: data,
          onBack: () {},
          onLesson: onLesson ?? (_) {},
          onPractice: onPractice ?? () {},
        ),
      ),
    );

void main() {
  testWidgets('prints the measured figures and the lessons read',
      (tester) async {
    await tester.pumpWidget(show(detail()));
    await tester.pumpAndSettle();
    expect(find.text('Geometry'), findsOneWidget);
    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('44%'), findsOneWidget);
    expect(find.text('accuracy'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('answered'), findsOneWidget);
    expect(find.text('2 of 5'), findsOneWidget);
    expect(find.text('lessons read'), findsOneWidget);
  });

  testWidgets('no answers hides the accuracy and invents nothing',
      (tester) async {
    await tester.pumpWidget(show(detail(answered: 0, correct: 0)));
    await tester.pumpAndSettle();
    expect(find.text('accuracy'), findsNothing);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('Today tags only the planned lesson and rows open lessons',
      (tester) async {
    String? opened;
    await tester.pumpWidget(show(detail(), onLesson: (id) => opened = id));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    await tester.tap(find.text('Circles'));
    expect(opened, 'l3');
  });

  testWidgets('Practice This Topic carries the outside-the-plan note',
      (tester) async {
    var practiced = 0;
    await tester.pumpWidget(show(detail(), onPractice: () => practiced++));
    await tester.pumpAndSettle();
    expect(
      find.text("Practice is outside your plan. It doesn't change today."),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Practice This Topic'));
    await tester.tap(find.text('Practice This Topic'));
    expect(practiced, 1);
  });

  for (final dark in [false, true]) {
    testWidgets('fits at 200% text in ${dark ? "dark" : "light"} mode',
        (tester) async {
      await tester.pumpWidget(show(detail(), large: true, dark: dark));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
