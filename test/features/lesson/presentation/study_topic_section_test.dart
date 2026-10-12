import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_topic_section.dart';

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

/// The page owns opening a topic now, so the section takes a callback.
/// These tests wire it to the same provider the page does.
Future<void> pumpSection(
  WidgetTester tester, {
  bool disableAnimations = false,
}) async {
  await tester.pumpAppWithProviders(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Consumer(
          builder: (context, ref, _) => StudySubjectSection(
            subject: subject,
            onToggleTopic: (topicId) =>
                ref.read(openTopicProvider.notifier).toggle(topicId),
          ),
        ),
      ),
    ),
    overrides: [openTopicProvider.overrideWith(FakeOpenTopic.new)],
  );
}

void main() {
  testWidgets('long lesson names at 200 percent are fully revealed',
      (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(
      () => tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio(),
    );
    final longSubject = StudySubject(
      id: 's',
      name: 'Science',
      topics: [
        StudyTopic(
          id: 't1',
          name: 'Topic',
          readCount: 0,
          hasBookmark: false,
          lessons: [
            for (var i = 0; i < 30; i++)
              StudyLesson(
                id: '$i',
                title: 'A very long lesson title that occupies several lines '
                    'on a narrow phone screen $i',
                estimatedMinutes: 10,
                isRead: false,
                isBookmarked: false,
              ),
          ],
        ),
      ],
    );
    await tester.pumpAppWithProviders(
      MediaQuery(
        data: const MediaQueryData(
          textScaler: TextScaler.linear(2),
          disableAnimations: true,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Consumer(
              builder: (context, ref, _) => StudySubjectSection(
                subject: longSubject,
                onToggleTopic: (id) =>
                    ref.read(openTopicProvider.notifier).toggle(id),
              ),
            ),
          ),
        ),
      ),
      overrides: [openTopicProvider.overrideWith(FakeOpenTopic.new)],
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topic'));
    await tester.pumpAndSettle();
    final reveal = find.byKey(const ValueKey('topic-reveal-t1'));
    final content =
        find.descendant(of: reveal, matching: find.byType(Column)).first;
    expect(
      tester.getSize(reveal).height,
      greaterThanOrEqualTo(tester.getSize(content).height),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a subject heading has no count', (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    expect(find.text('MATHEMATICS'), findsOneWidget);
    expect(find.text('2 / 3'), findsNothing);
  });

  testWidgets('topic rows use rings without printed counts', (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('1 / 2'), findsNothing);
    expect(find.text('Lesson l1'), findsNothing);
  });

  testWidgets('tapping a topic reveals its lessons', (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson l1'), findsOneWidget);
    expect(find.text('Lesson l2'), findsOneWidget);
    expect(find.text('9 min'), findsOneWidget);
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

  testWidgets('reduced motion opens a topic without size or fade transitions',
      (tester) async {
    await pumpSection(tester, disableAnimations: true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Algebra'));
    await tester.pump();

    expect(find.text('Lesson l1'), findsOneWidget);
    expect(find.byType(AnimatedSize), findsNothing);
    for (final fade in tester.widgetList<FadeTransition>(
      find.byType(FadeTransition),
    )) {
      expect(fade.opacity.value, 1);
    }
  });

  testWidgets('a complete topic is ticked and muted', (tester) async {
    await pumpSection(tester);
    await tester.pumpAndSettle();

    // Geometry is 1 of 1. Algebra is 1 of 2 and draws no glyph.
    expect(find.byType(CheckMark), findsOneWidget);
  });
}
