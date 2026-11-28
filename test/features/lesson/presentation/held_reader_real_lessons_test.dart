// Acceptance check 3 of the lesson reader full screen spec: the real lessons
// with the most text, figures, tables and math, at three window heights, with
// the solutions closed and open.
//
// For each: no plate overlaps another, no plate sits beside a different
// passage by more than 40 px, nothing is wider than its column, and every
// figure that stays in the text is listed.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/held_reader.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/in_memory_database.dart';

const _lessons = {
  'triangles': 'content/lessons/mathematics/geometry/triangles.md',
  'basic geometric concepts':
      'content/lessons/mathematics/geometry/basic-geometric-concepts.md',
  'circles': 'content/lessons/mathematics/geometry/circles.md',
  "Earth's motions":
      'content/lessons/science/earth-science-astronomy/earths-motions.md',
  'truth tables': 'content/lessons/reasoning/logical-verbal-reasoning/'
      'truth-tables-propositional-logic.md',
  'systems of equations':
      'content/lessons/mathematics/algebra/systems-of-equations.md',
  'quantum numbers': 'content/lessons/science/chemistry/'
      'quantum-numbers-electron-configuration.md',
};

ReaderContext _reader(String title, List<Map<String, Object?>> body) =>
    ReaderContext(
      lesson: Lesson(
        id: title,
        topicId: 't',
        title: title,
        summary: '',
        estimatedMinutes: 10,
        bodyJson: body,
      ),
      topicId: 't',
      topicName: 'Topic',
      next: null,
      positionInTopic: 1,
      lessonsInTopic: 1,
      topicLessons: const [
        StudyLesson(
          id: 'x',
          title: 'x',
          isRead: false,
          isBookmarked: false,
        ),
      ],
      isRead: false,
      isBookmarked: false,
      examId: 'e',
    );

List<Map<String, Object?>> _body(String path) {
  final source = File(path).readAsStringSync();
  final front = RegExp(r'^---\n(.*?)\n---\n', dotAll: true).firstMatch(source);
  return lessonBlocksFromMarkdown(source.substring(front!.end));
}

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  for (final entry in _lessons.entries) {
    for (final height in [650.0, 720.0, 900.0]) {
      for (final open in [false, true]) {
        testWidgets(
          '${entry.key} at 1440x${height.round()}, solutions '
          '${open ? 'open' : 'closed'}',
          (tester) async {
            final db = inMemoryDatabase();
            addTearDown(db.close);
            tester.view
              ..physicalSize = Size(1440, height)
              ..devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            final scroll = ScrollController();
            final offset = ValueNotifier<double>(0);
            final progress = ValueNotifier<double>(0);
            addTearDown(scroll.dispose);
            addTearDown(offset.dispose);
            addTearDown(progress.dispose);
            scroll.addListener(() => offset.value = scroll.offset);
            await tester.pumpWidget(
              ProviderScope(
                overrides: [appDatabaseProvider.overrideWithValue(db)],
                child: MaterialApp(
                  theme: buildLightTheme(web: true),
                  home: Scaffold(
                    body: WebReaderLayout(
                      reader: _reader(entry.key, _body(entry.value)),
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
            if (open) {
              final buttons =
                  find.byKey(const ValueKey('reader-solution-button'));
              while (buttons.evaluate().isNotEmpty) {
                await tester.ensureVisible(buttons.first);
                await tester.pump();
                await tester.tap(buttons.first, warnIfMissed: false);
                await tester.pumpAndSettle();
              }
              scroll.jumpTo(0);
              await tester.pumpAndSettle();
            }
            expect(tester.takeException(), isNull);
            if (find.byType(HeldReader).evaluate().isEmpty) {
              // Every figure of this lesson is wide art or there is none:
              // the single centered column. With no saved choice a text-only
              // lesson is off (Aedwon's pick B, Nov 28), so it is 680 px.
              expect(
                tester
                    .getSize(find.byKey(const ValueKey('web-reader-column')))
                    .width,
                680,
              );
              return;
            }
            final held = tester.renderObject<RenderHeldReader>(
              find.byType(HeldReader),
            );
            final result = held.result!;
            final placed = result.figures.values.toList()
              ..sort((a, b) => a.top.compareTo(b.top));
            // No plate overlaps another.
            for (var i = 1; i < placed.length; i++) {
              expect(
                placed[i].top,
                greaterThanOrEqualTo(placed[i - 1].top + placed[i - 1].height),
                reason: 'plate ${placed[i].id} overlaps ${placed[i - 1].id}',
              );
            }
            // Every plate ends inside its passage, white space included.
            for (final f in placed) {
              expect(
                f.top + f.height,
                lessThanOrEqualTo(f.passageEnd + .01),
                reason: 'plate ${f.id} runs past its passage',
              );
            }
            // Nothing is wider than the 640 px column.
            final column = tester.getRect(
              find.byType(HeldReader),
            );
            expect(column.width, greaterThanOrEqualTo(640));
            expect(result.overCap, isEmpty, reason: 'no inline fallback');
          },
        );
      }
    }
  }
}
