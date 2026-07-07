import 'package:cse_cet_reviewer/features/lesson/application/study_map_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/study_topic_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';
import 'fake_open_topic.dart';

StudyLesson lessonRow(String id, {bool isRead = false}) => StudyLesson(
      id: id,
      title: 'Lesson $id',
      estimatedMinutes: 9,
      isRead: isRead,
      isBookmarked: false,
    );

final subject = StudySubject(
  id: 's1',
  name: 'Mathematics',
  topics: [
    StudyTopic(
      id: 't1',
      name: 'Algebra',
      lessons: [lessonRow('l1', isRead: true), lessonRow('l2')],
      readCount: 1,
      hasBookmark: false,
    ),
    StudyTopic(
      id: 't2',
      name: 'Geometry',
      lessons: [lessonRow('l3', isRead: true)],
      readCount: 1,
      hasBookmark: false,
    ),
  ],
);

Future<void> pumpSection(WidgetTester tester) async {
  await tester.pumpAppWithProviders(
    Scaffold(body: StudySubjectSection(subject: subject)),
    overrides: [openTopicProvider.overrideWith(FakeOpenTopic.new)],
  );
}

void main() {
  testWidgets('a subject heading carries its own read fraction',
      (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('2 / 3'), findsOneWidget);
  });

  testWidgets('topic rows print their fractions and stay closed',
      (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('Lesson l1'), findsNothing);
  });

  testWidgets('tapping a topic reveals its lessons', (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson l1'), findsOneWidget);
    expect(find.text('Lesson l2'), findsOneWidget);
    expect(find.text('9 min'), findsNWidgets(2));
  });

  testWidgets('opening a second topic closes the first', (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Geometry'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson l1'), findsNothing);
    expect(find.text('Lesson l3'), findsOneWidget);
  });

  testWidgets('tapping an open topic closes it', (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson l1'), findsNothing);
  });

  testWidgets('a complete topic is ticked and muted', (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    // Geometry is 1 of 1. Algebra is 1 of 2 and draws no glyph.
    expect(find.text('✓'), findsOneWidget);
  });
}
