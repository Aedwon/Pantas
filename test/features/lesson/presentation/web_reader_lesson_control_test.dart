import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/in_memory_database.dart';

// The wide reader's lesson control shows "N of M" and a chevron only. It used
// to draw one dash per lesson, which grew with the lessons in a topic.

const _lessonCount = 24;

List<StudyLesson> _lessons() => [
      for (var i = 1; i <= _lessonCount; i++)
        StudyLesson(
          id: 'l$i',
          title: 'Bite number $i',
          isRead: false,
          isBookmarked: false,
        ),
    ];

ReaderContext _reader() => ReaderContext(
      lesson: const Lesson(
        id: 'l3',
        topicId: 't1',
        title: 'Bite number 3',
        summary: '',
        estimatedMinutes: 5,
        bodyJson: [
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {'_type': 'span', 'text': 'Words.', 'marks': <String>[]},
            ],
          },
        ],
      ),
      topicId: 't1',
      topicName: 'Earth Science',
      next: _lessons()[3],
      positionInTopic: 3,
      lessonsInTopic: _lessonCount,
      topicLessons: _lessons(),
      isRead: false,
      isBookmarked: false,
      examId: 'e',
    );

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> pumpReader(WidgetTester tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final scroll = ScrollController();
    final offset = ValueNotifier<double>(0);
    final progress = ValueNotifier<double>(0);
    addTearDown(scroll.dispose);
    addTearDown(offset.dispose);
    addTearDown(progress.dispose);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: WebReaderLayout(
              reader: _reader(),
              controller: scroll,
              scrollOffset: offset,
              progress: progress,
              onBack: () {},
              onBookmark: () {},
              onLesson: (_) {},
              footer: const SizedBox(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a long topic draws no per-lesson dashes in the top bar',
      (tester) async {
    await pumpReader(tester);
    final control = find.ancestor(
      of: find.text('3 of $_lessonCount'),
      matching: find.byType(Row),
    );
    expect(control, findsWidgets);
    final dashes = find.descendant(
      of: control.first,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.minWidth == 18 &&
            w.constraints?.minHeight == 4,
      ),
    );
    expect(dashes, findsNothing);
    expect(find.text('3 of $_lessonCount'), findsOneWidget);
  });

  testWidgets('the control still opens the lesson list', (tester) async {
    await pumpReader(tester);
    expect(find.text(' · $_lessonCount LESSONS'), findsNothing);
    await tester.tap(find.text('3 of $_lessonCount'));
    await tester.pumpAndSettle();
    expect(find.text(' · $_lessonCount LESSONS'), findsOneWidget);
  });
}
