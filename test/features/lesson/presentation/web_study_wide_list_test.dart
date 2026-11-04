import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_study_layout.dart';

// Nov 3, items 4 and 12: the wide Study page. Sizes come from the approved
// preview (study-reader.html, section 1 Option A and section 2 Option A).

const _bookmarkPrompt = 'Bookmark a lesson to keep it here.';
const _longTitle = 'Figure Matrices (Completing a 2x2 or 3x3 Grid of Shapes)';
const _longTopic = 'Spatial & Abstract (Non-Verbal) Reasoning';

StudyTopic _topic(String id, String name, {bool bookmarked = false}) =>
    StudyTopic(
      id: id,
      name: name,
      lessons: [
        StudyLesson(
          id: '$id-l1',
          title: 'Lesson of $name',
          estimatedMinutes: 10,
          isRead: false,
          isBookmarked: bookmarked,
        ),
      ],
      readCount: 0,
      hasBookmark: bookmarked,
    );

/// The preview's subjects: 5, 1, 4, 3 and 3 topics.
StudyMap _previewMap({bool bookmarked = false}) => StudyMap(
      examShortName: 'CSE',
      subjects: [
        StudySubject(
          id: 's1',
          name: 'Reasoning',
          topics: [
            _topic('t1', 'Logical & Verbal Reasoning', bookmarked: bookmarked),
            _topic('t2', _longTopic),
            _topic('t3', 'Mechanical & Technical Reasoning'),
            _topic('t4', 'Clerical Ability'),
            _topic('t5', 'Verbal Logic'),
          ],
        ),
        StudySubject(
          id: 's2',
          name: 'Verbal Ability',
          topics: [_topic('t6', 'Vocabulary')],
        ),
        StudySubject(
          id: 's3',
          name: 'General Information',
          topics: [
            _topic('t7', 'Philippine Constitution'),
            _topic('t8', 'Code of Conduct (RA 6713)'),
            _topic('t9', 'Peace and Human Rights'),
            _topic('t10', 'Environment Management'),
          ],
        ),
        StudySubject(
          id: 's4',
          name: 'Mathematics',
          topics: [
            _topic('t11', 'Arithmetic & Number Sense'),
            _topic('t12', 'Algebra'),
            _topic('t13', 'Data Interpretation'),
          ],
        ),
        StudySubject(
          id: 's5',
          name: 'Language Proficiency (English & Filipino)',
          topics: [
            _topic('t14', 'Grammar and Structure'),
            _topic('t15', 'Application'),
            _topic('t16', 'Reading Comprehension'),
          ],
        ),
      ],
      readCount: 0,
      totalCount: 16,
      minutesLeftToRead: 160,
    );

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  /// [window] is the browser width. [content] is the width the shell hands the
  /// Study page: 1080 at 1440 (sidebar, 44 px padding, 1080 cap) and window
  /// minus 88 on a landscape tablet (no sidebar, 44 px padding).
  Future<void> pumpMap(
    WidgetTester tester, {
    required double window,
    required double content,
    required StudyMap map,
    String? openTopicId,
    String? lastLessonId,
    String? lastTitle,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view
      ..physicalSize = Size(window, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: brightness == Brightness.dark
            ? buildDarkTheme(web: true)
            : buildLightTheme(web: true),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: content,
              height: 900,
              child: WebStudyMap(
                map: map,
                openTopicId: openTopicId,
                lastLessonId: lastLessonId,
                lastTitle: lastTitle,
                onTopic: (_) {},
                onLesson: (_, {required resume}) {},
                onBookmarks: () {},
              ),
            ),
          ),
        ),
      ),
    );
    // The map's parts come in over a second; measure them in place.
    await tester.pumpAndSettle();
  }

  bool exceeded(WidgetTester tester, Finder finder) =>
      tester.renderObject<RenderParagraph>(finder).didExceedMaxLines;

  for (final (window, content) in [(1440.0, 1080.0), (1100.0, 1012.0)]) {
    group('at $window wide', () {
      testWidgets('an empty Bookmarks section is not drawn', (tester) async {
        await pumpMap(
          tester,
          window: window,
          content: content,
          map: _previewMap(),
        );
        expect(find.text('BOOKMARKS'), findsNothing);
        expect(find.text(_bookmarkPrompt), findsNothing);
        expect(find.text('See all'), findsNothing);
        // The first subject starts at the top of the list.
        expect(
          tester.getTopLeft(find.text('REASONING')).dy,
          lessThan(
            tester.getTopLeft(find.byKey(const ValueKey('web-study-map'))).dy +
                8,
          ),
        );
      });

      testWidgets('Bookmarks returns once there is a bookmark', (tester) async {
        for (final openTopicId in [null, 't2']) {
          await pumpMap(
            tester,
            window: window,
            content: content,
            map: _previewMap(bookmarked: true),
            openTopicId: openTopicId,
          );
          expect(find.text('BOOKMARKS'), findsOneWidget);
          expect(find.text('Lesson of Logical & Verbal Reasoning'), findsOne);
          expect(find.text('See all'), findsOneWidget);
          expect(find.text(_bookmarkPrompt), findsNothing);
        }
      });

      testWidgets('with nothing selected the list uses the width',
          (tester) async {
        await pumpMap(
          tester,
          window: window,
          content: content,
          map: _previewMap(),
        );
        final list = find.byKey(const ValueKey('web-study-map'));
        expect(tester.getSize(list).width, content);
        // No titles are cut off.
        for (final subject in _previewMap().subjects) {
          for (final topic in subject.topics) {
            final title = find.text(topic.name);
            expect(title, findsOneWidget, reason: topic.name);
            expect(exceeded(tester, title), isFalse, reason: topic.name);
          }
        }
        // Two columns, 24 px apart, each half of the width.
        final column = (content - 24) / 2;
        final left = tester.getTopLeft(find.text('REASONING')).dx;
        final right = tester.getTopLeft(find.text('MATHEMATICS')).dx;
        expect(right - left, column + 24);
        // Rows are 36 px tall and fill the column.
        final row = find
            .ancestor(
              of: find.text(_longTopic),
              matching: find.byType(TextButton),
            )
            .first;
        expect(tester.getSize(row), Size(column, 36));
        // Subjects keep their order and break only between subjects: the
        // preview balances 5, 1, 4 | 3, 3 topics.
        for (final name in [
          'REASONING',
          'VERBAL ABILITY',
          'GENERAL INFORMATION',
        ]) {
          expect(tester.getTopLeft(find.text(name)).dx, left, reason: name);
        }
        for (final name in [
          'MATHEMATICS',
          'LANGUAGE PROFICIENCY (ENGLISH & FILIPINO)',
        ]) {
          expect(tester.getTopLeft(find.text(name)).dx, right, reason: name);
        }
        // 18 px between blocks in a column.
        final reasoningBottom =
            tester.getBottomLeft(find.text('Verbal Logic')).dy;
        final verbalTop = tester.getTopLeft(find.text('VERBAL ABILITY')).dy;
        expect(verbalTop - reasoningBottom, greaterThan(18));
        expect(tester.takeException(), isNull);
      });

      testWidgets('the Last opened card keeps the column width above the list',
          (tester) async {
        await pumpMap(
          tester,
          window: window,
          content: content,
          map: _previewMap(),
          lastLessonId: 't2-l1',
          lastTitle: _longTitle,
        );
        final card = find.byType(WebCard).first;
        final column = (300 + (content - 784) / 1000).clamp(300.0, 340.0);
        expect(tester.getSize(card).width, closeTo(column, 0.01));
        // 22 px between the card and the first subject.
        expect(
          tester.getTopLeft(find.text('REASONING')).dy -
              tester.getBottomLeft(card).dy,
          closeTo(22, 0.01),
        );
        expect(find.text('BOOKMARKS'), findsNothing);
      });

      testWidgets('a selected topic keeps the list and detail layout',
          (tester) async {
        await pumpMap(
          tester,
          window: window,
          content: content,
          map: _previewMap(),
          openTopicId: 't2',
          lastLessonId: 't2-l1',
          lastTitle: _longTitle,
        );
        final list = find.byKey(const ValueKey('web-study-map'));
        final column = (300 + (content - 784) / 1000).clamp(300.0, 340.0);
        expect(tester.getSize(list).width, closeTo(column, 0.01));
        final pane = find.byKey(const ValueKey('web-study-topic'));
        expect(
          tester.getTopLeft(pane).dx,
          closeTo(tester.getTopLeft(list).dx + column + 24, 0.01),
        );
        // One column: every subject label shares the left edge.
        final x = tester.getTopLeft(find.text('REASONING').first).dx;
        expect(tester.getTopLeft(find.text('MATHEMATICS')).dx, x);
        expect(tester.getTopLeft(find.text('VERBAL ABILITY')).dx, x);
        // Detail card shows the topic.
        expect(find.text('Lesson of $_longTopic'), findsOneWidget);
        // Rows still cut off at one line, as today.
        expect(
          tester
              .widget<Text>(
                find.descendant(
                  of: find.byType(TextButton),
                  matching: find.text(_longTopic),
                ),
              )
              .overflow,
          TextOverflow.ellipsis,
        );
        // Bookmarks stay hidden while empty, selected or not.
        expect(find.text('BOOKMARKS'), findsNothing);
        expect(find.text(_bookmarkPrompt), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  }

  group('the Last opened card', () {
    Future<void> pumpCard(
      WidgetTester tester, {
      required double column,
      String title = _longTitle,
      String topic = _longTopic,
      Brightness brightness = Brightness.light,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: brightness == Brightness.dark
              ? buildDarkTheme(web: true)
              : buildLightTheme(web: true),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: column,
                child: WebLastOpenedCard(
                  title: title,
                  topic: topic,
                  onResume: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    for (final brightness in Brightness.values) {
      for (final column in [300.0, 340.0]) {
        testWidgets(
            'holds a 56 and 41 character title with the button below '
            '($column, $brightness)', (tester) async {
          await pumpCard(tester, column: column, brightness: brightness);
          final card = tester.getRect(find.byType(WebCard));
          // Dark cards carry a 1 px edge inside the padding box.
          final edge = brightness == Brightness.dark ? 1.0 : 0.0;
          final title = find.text(_longTitle);
          final topic = find.text(_longTopic);
          final button = tester.getRect(find.byType(WebButton));
          expect(card.width, column);
          // Nothing is cut off, and the text stays inside the padding
          // (18 left, 16 right).
          expect(exceeded(tester, title), isFalse);
          expect(exceeded(tester, topic), isFalse);
          expect(tester.widget<Text>(title).maxLines, isNull);
          expect(tester.widget<Text>(topic).maxLines, isNull);
          for (final text in [title, topic, find.text('LAST OPENED')]) {
            final rect = tester.getRect(text);
            expect(rect.left, card.left + 18 + edge);
            expect(rect.right, lessThanOrEqualTo(card.right - 16 - edge));
          }
          // Both texts wrap in this column.
          expect(tester.getSize(title).height, greaterThan(24));
          expect(tester.getSize(topic).height, greaterThan(18));
          // Eyebrow, 3 px, title, topic.
          expect(
            tester.getTopLeft(title).dy -
                tester.getBottomLeft(find.text('LAST OPENED')).dy,
            closeTo(3, 0.01),
          );
          expect(
            tester.getTopLeft(topic).dy,
            closeTo(tester.getBottomLeft(title).dy, 0.01),
          );
          // The button sits 12 px below the text, at its natural size, on the
          // left, with 16 px under it.
          expect(
            button.top - tester.getBottomLeft(topic).dy,
            closeTo(12, 0.01),
          );
          expect(button.left, card.left + 18 + edge);
          expect(button.height, 44);
          expect(button.width, lessThan(140));
          expect(button.width, lessThan(column / 2));
          expect(card.bottom - button.bottom, 16 + edge);
          expect(
            card.top + 16 + edge,
            tester.getTopLeft(find.text('LAST OPENED')).dy,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('a short title uses the same shape', (tester) async {
      await pumpCard(tester, column: 300, title: 'Circles', topic: 'Geometry');
      final card = tester.getRect(find.byType(WebCard));
      final button = tester.getRect(find.byType(WebButton));
      expect(
        button.top,
        greaterThanOrEqualTo(
          tester.getBottomLeft(find.text('Geometry')).dy + 12,
        ),
      );
      expect(button.left, card.left + 18);
      expect(button.width, lessThan(140));
    });

    testWidgets('Resume still resumes', (tester) async {
      var resumed = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: Scaffold(
            body: WebLastOpenedCard(
              title: 'Circles',
              topic: 'Geometry',
              onResume: () => resumed++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Resume'));
      expect(resumed, 1);
    });
  });

  testWidgets(
      'the Study page waits for the open topic before choosing a layout',
      (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyMapProvider.overrideWith((_) async => _previewMap()),
          openTopicProvider.overrideWith(_NeverOpenTopic.new),
          lastOpenedLessonProvider.overrideWith((_) async => null),
          studyTodayLessonIdsProvider.overrideWith((_) async => <String>{}),
          activeExamFocusProvider.overrideWith(
            (_) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: const Scaffold(body: WebStudyLayout()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(WebStudyLoading), findsOneWidget);
    expect(find.text('REASONING'), findsNothing);
  });
}

class _NeverOpenTopic extends OpenTopicController {
  @override
  Future<String?> build() => Completer<String?>().future;
}
