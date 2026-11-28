// The walk-through tap-back on the wide reader, where each section of a lesson
// is drawn by its own renderer (and the held layout by one for the lesson), so
// the controller must serve the whole lesson (E-196).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/lesson_markdown.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';

import '../../../helpers/in_memory_database.dart';

Map<String, Object?> _p(
  String text, {
  String style = 'normal',
  String? list,
  int? number,
  String? anchor,
}) =>
    {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
      if (list != null) 'listItem': list,
      if (list != null) 'level': 1,
      if (number != null) 'listNumber': number,
      if (anchor != null) 'anchor': anchor,
    };

/// Sections, each its own group on the wide reader: a heading to land on, an
/// example with a pair in its fifth of six steps, and the checklist.
List<Map<String, Object?>> _walkSections() => [
      _p('Core Concept', style: 'h2'),
      for (var i = 0; i < 14; i++) _p('Opening line $i.'),
      _p('A subhead', style: 'h3', anchor: 'core-notes'),
      for (var i = 0; i < 14; i++) _p('Middle line $i.'),
      _p('Examples', style: 'h2'),
      _p('#1: Six steps', style: 'h3', anchor: 'six-steps'),
      _p('Evaluate it.'),
      {
        ..._p('Solution:'),
        'children': [
          {
            '_type': 'span',
            'text': 'Solution:',
            'marks': ['strong'],
          },
        ],
      },
      for (var i = 1; i <= 6; i++) ...[
        _p('Step $i text.', list: 'number', number: i),
        _p('Work for step $i.'),
        if (i == 5)
          {
            '_type': 'walkPair',
            'id': 'end-pair',
            'right': [
              {'_type': 'span', 'text': 'Right line', 'marks': <String>[]},
            ],
            'wrong': [
              {'_type': 'span', 'text': 'Wrong line', 'marks': <String>[]},
            ],
            'note': [_p('The note under both.')],
          },
      ],
      for (var i = 0; i < 24; i++) _p('Closing line $i.'),
      _p('Traps to Watch For', style: 'h2'),
      {
        '_type': 'walkChecklist',
        'items': [
          {
            'cue': [
              {'_type': 'span', 'text': 'A pair:', 'marks': <String>[]},
            ],
            'move': [
              {'_type': 'span', 'text': ' go to it.', 'marks': <String>[]},
            ],
            'target': 'end-pair',
          },
          {
            'cue': [
              {'_type': 'span', 'text': 'A heading:', 'marks': <String>[]},
            ],
            'move': [
              {'_type': 'span', 'text': ' go to it.', 'marks': <String>[]},
            ],
            'target': 'core-notes',
          },
        ],
      },
      for (var i = 0; i < 30; i++) _p('Tail line $i.'),
    ];

/// The real Circles lesson (it has figures, so the wide reader holds them in
/// its margin) with a pair and a checklist added.
List<Map<String, Object?>> _heldLesson() {
  final source = File('content/lessons/mathematics/geometry/circles.md')
      .readAsStringSync();
  final body = lessonBlocksFromMarkdown(
    source.substring(
      RegExp(r'^---\n(.*?)\n---\n', dotAll: true).firstMatch(source)!.end,
    ),
  );
  final walk = _walkSections();
  final tail =
      walk.sublist(walk.indexWhere((b) => b['_type'] == 'walkChecklist'));
  return [
    ...body,
    _p('Reading the diagram', style: 'h2'),
    {
      '_type': 'walkPair',
      'id': 'end-pair',
      'right': [
        {'_type': 'span', 'text': 'Right line', 'marks': <String>[]},
      ],
      'wrong': [
        {'_type': 'span', 'text': 'Wrong line', 'marks': <String>[]},
      ],
      'note': [_p('The note under both.')],
    },
    for (var i = 0; i < 24; i++) _p('Closing line $i.'),
    _p('Traps to Watch For', style: 'h2'),
    ...tail,
  ];
}

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late ScrollController scroll;

  Future<void> pump(
    WidgetTester tester,
    List<Map<String, Object?>> body, {
    bool still = false,
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    scroll = ScrollController();
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
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(1440, 900),
              disableAnimations: still,
            ),
            child: Scaffold(
              body: WebReaderLayout(
                reader: ReaderContext(
                  lesson: Lesson(
                    id: 'w',
                    topicId: 't',
                    title: 'A walk-through lesson',
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
                      id: 'w',
                      title: 'A walk-through lesson',
                      isRead: false,
                      isBookmarked: false,
                    ),
                  ],
                  isRead: false,
                  isBookmarked: false,
                  examId: 'e',
                ),
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
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder key(String k) => find.byKey(ValueKey(k));

  /// Scrolls to the end, brings checklist row [index] into view and taps it.
  Future<void> tapRow(WidgetTester tester, int index) async {
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
    // The middle of the window, clear of the reader bar at the top.
    await Scrollable.ensureVisible(
      tester.element(key('walk-checklist-row-$index')),
      alignment: .5,
    );
    await tester.pump();
    await tester.tap(key('walk-checklist-row-$index'));
  }

  /// The target sits in the middle of the reader's window and inside it. The
  /// reader bar slides in as the page scrolls up and moves the window's top
  /// edge by its height, so the middle may move by half of that; the exact
  /// centering is held by the renderer test.
  void expectInMiddle(WidgetTester tester, String slug) {
    final window = tester.getRect(key('web-reader-scroll'));
    final target = tester.getRect(key('walk-target-$slug'));
    expect((target.center.dy - window.center.dy).abs(), lessThan(40));
    expect(target.top, greaterThanOrEqualTo(window.top));
    expect(target.bottom, lessThanOrEqualTo(window.bottom));
  }

  for (final held in [false, true]) {
    final layout = held ? 'held' : 'plain';

    testWidgets('a checklist tap reaches a pair in another section, $layout',
        (tester) async {
      await pump(tester, held ? _heldLesson() : _walkSections());
      // Walk-through solutions are open: no "Show solution" anywhere.
      expect(find.text('Show solution'), findsNothing);
      await tapRow(tester, 0);
      var spent = Duration.zero;
      while (key('walk-tint-end-pair').evaluate().isEmpty &&
          spent < const Duration(seconds: 4)) {
        await tester.pump(const Duration(milliseconds: 50));
        spent += const Duration(milliseconds: 50);
      }
      expect(key('walk-tint-end-pair'), findsOneWidget);
      expectInMiddle(tester, 'end-pair');
      await tester.pumpAndSettle();
    });

    testWidgets('with Reduce Motion it jumps and keeps the outline, $layout',
        (tester) async {
      await pump(
        tester,
        held ? _heldLesson() : _walkSections(),
        still: true,
      );
      await tapRow(tester, 0);
      await tester.pumpAndSettle();
      expect(key('walk-outline-end-pair'), findsOneWidget);
      expectInMiddle(tester, 'end-pair');
      await tester.pump(const Duration(seconds: 3));
      expect(key('walk-outline-end-pair'), findsOneWidget);
    });
  }

  testWidgets('a heading in an earlier section is reached too', (tester) async {
    await pump(tester, _walkSections());
    await tapRow(tester, 1);
    var spent = Duration.zero;
    while (key('walk-tint-core-notes').evaluate().isEmpty &&
        spent < const Duration(seconds: 4)) {
      await tester.pump(const Duration(milliseconds: 50));
      spent += const Duration(milliseconds: 50);
    }
    expect(key('walk-tint-core-notes'), findsOneWidget);
    expectInMiddle(tester, 'core-notes');
    await tester.pumpAndSettle();
  });

  testWidgets('an example in a walk-through lesson shows steps one at a time',
      (tester) async {
    await pump(tester, _walkSections());
    expect(find.text('Show solution'), findsNothing);
    expect(find.text('Step 1 text.'), findsOneWidget);
    expect(find.text('Step 2 text.'), findsNothing);
    expect(find.text('Next step'), findsOneWidget);
  });
}
