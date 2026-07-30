import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';
import 'package:pantas/features/home/application/up_next_provider.dart';
import 'package:pantas/features/home/presentation/widgets/up_next_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget harness({required UpNextDay day}) {
    return ProviderScope(
      overrides: [
        upNextProvider.overrideWith((ref) async => day),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: [AppColors.light, AppTextStyles.create()],
        ),
        home: const Scaffold(
          body: UpNextPanel(),
        ),
      ),
    );
  }

  const threeLessonsAcrossThreeSubjects = UpNextDay(
    lessons: [
      UpNextLesson(
        lessonId: 'alg-01',
        title: 'Balancing simple equations',
        topicId: 'algebra',
        subjectName: 'Algebra',
        estimatedMinutes: 9,
      ),
      UpNextLesson(
        lessonId: 'geo-01',
        title: 'Angles on a straight line',
        topicId: 'geometry',
        subjectName: 'Geometry',
        estimatedMinutes: 11,
      ),
      UpNextLesson(
        lessonId: 'chem-01',
        title: 'Naming ionic compounds',
        topicId: 'chemistry',
        subjectName: 'Chemistry',
        estimatedMinutes: 8,
      ),
    ],
    allReadInWeakTopics: false,
  );

  const twoSubjects = UpNextDay(
    lessons: [
      UpNextLesson(
        lessonId: 'alg-01',
        title: 'Balancing simple equations',
        topicId: 'algebra',
        subjectName: 'Algebra',
        estimatedMinutes: 9,
      ),
      UpNextLesson(
        lessonId: 'chem-01',
        title: 'Naming ionic compounds',
        topicId: 'chemistry',
        subjectName: 'Chemistry',
        estimatedMinutes: 8,
      ),
    ],
    allReadInWeakTopics: false,
  );

  const oneSubject = UpNextDay(
    lessons: [
      UpNextLesson(
        lessonId: 'alg-01',
        title: 'Balancing simple equations',
        topicId: 'algebra',
        subjectName: 'Algebra',
        estimatedMinutes: 9,
      ),
    ],
    allReadInWeakTopics: false,
  );

  const oneMinuteTotal = UpNextDay(
    lessons: [
      UpNextLesson(
        lessonId: 'alg-01',
        title: 'Balancing simple equations',
        topicId: 'algebra',
        subjectName: 'Algebra',
        estimatedMinutes: 1,
      ),
    ],
    allReadInWeakTopics: false,
  );

  testWidgets('names the distinct subjects and the total time', (tester) async {
    await tester.pumpWidget(harness(day: threeLessonsAcrossThreeSubjects));
    await tester.pumpAndSettle();

    expect(
      find.text('Algebra, Geometry and Chemistry today. About 28 minutes.'),
      findsOneWidget,
    );
  });

  testWidgets('two subjects join with "and", not a comma', (tester) async {
    await tester.pumpWidget(harness(day: twoSubjects));
    await tester.pumpAndSettle();
    expect(find.textContaining('Algebra and Chemistry today.'), findsOneWidget);
  });

  testWidgets('one subject reads as one subject', (tester) async {
    await tester.pumpWidget(harness(day: oneSubject));
    await tester.pumpAndSettle();
    expect(find.textContaining('Algebra today.'), findsOneWidget);
  });

  testWidgets('one minute reads "1 minute", not "1 minutes"', (tester) async {
    await tester.pumpWidget(harness(day: oneMinuteTotal));
    await tester.pumpAndSettle();
    expect(find.textContaining('About 1 minute.'), findsOneWidget);
  });

  testWidgets('rows carry no chevron', (tester) async {
    await tester.pumpWidget(harness(day: threeLessonsAcrossThreeSubjects));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('the finish state states the work and offers no button',
      (tester) async {
    await tester.pumpWidget(
      harness(day: const UpNextDay(lessons: [], allReadInWeakTopics: true)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Nothing left to read in your weak topics.'),
      findsOneWidget,
    );
    expect(find.byType(BoardButton), findsNothing);
  });

  testWidgets('no lessons at all renders no panel', (tester) async {
    await tester.pumpWidget(
      harness(day: const UpNextDay(lessons: [], allReadInWeakTopics: false)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(RuledPanel), findsNothing);
  });

  testWidgets('Continue lesson is the only non-secondary button',
      (tester) async {
    await tester.pumpWidget(harness(day: threeLessonsAcrossThreeSubjects));
    await tester.pumpAndSettle();

    final buttons = tester.widgetList<BoardButton>(find.byType(BoardButton));
    expect(buttons.where((b) => !b.secondary), hasLength(1));
    expect(find.text('Continue lesson'), findsOneWidget);
  });

  testWidgets('no em dash anywhere in the panel', (tester) async {
    await tester.pumpWidget(harness(day: threeLessonsAcrossThreeSubjects));
    await tester.pumpAndSettle();
    expect(find.textContaining('—'), findsNothing);
  });
}
