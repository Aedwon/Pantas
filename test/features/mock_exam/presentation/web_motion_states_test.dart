import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_question.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_reader_layout.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_mock_panel_tab.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';

import '../../../helpers/in_memory_database.dart';
import 'web_mock_layout_test.dart' show question;

void main() {
  testWidgets('hidden navigation tab is available on first frame',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1440, 1000)),
          child: WebMockPanelTab(hidden: true, onPressed: () {}),
        ),
      ),
    );
    expect(
      find.byTooltip('Show the question list').hitTestable(),
      findsOneWidget,
    );
  });
  for (final reduced in [false, true]) {
    testWidgets('reveal stages and passage stays selectable, reduced=$reduced',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var checked = false;
      String? chosen;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(1440, 1000),
              disableAnimations: reduced,
            ),
            child: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return SingleChildScrollView(
                    child: WebQuizQuestion(
                      question: question,
                      subject: 'Science',
                      passage: const Passage(
                        id: 'p',
                        topicId: 't',
                        language: 'en',
                        wordCount: 2,
                        title: 'Passage',
                        body: 'Read this.',
                      ),
                      chosenId: chosen,
                      checked: checked,
                      onPick: (id) => update(() => chosen = id),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Second answer'));
      expect(chosen, 'b');
      update(() => checked = true);
      await tester.pump();
      final options =
          tester.widgetList<WebAnswerOption>(find.byType(WebAnswerOption));
      expect(options.first.badgeProgress, reduced ? 1 : 0);
      if (!reduced) {
        await tester.pump(const Duration(milliseconds: 320));
        final miss = find
            .ancestor(
              of: find.byIcon(Icons.close),
              matching: find.byType(Transform),
            )
            .first;
        expect(
          tester.widget<Transform>(miss).transform.storage[0],
          closeTo(1.1, .001),
        );
        await tester.pump(const Duration(milliseconds: 160));
        final fix = find
            .ancestor(
              of: find.byIcon(Icons.check),
              matching: find.byType(Transform),
            )
            .first;
        expect(
          tester.widget<Transform>(fix).transform.storage[0],
          closeTo(1.15, .001),
        );
      }
      await tester.pump(const Duration(milliseconds: 1840));
      expect(
        tester
            .widgetList<WebAnswerOption>(find.byType(WebAnswerOption))
            .first
            .badgeProgress,
        1,
      );
      expect(
        tester
            .widget<Opacity>(find.byKey(const ValueKey('web-answer-reveal')))
            .opacity,
        1,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('reader focus finishes and returns, reduced=$reduced',
        (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final offset = ValueNotifier<double>(0);
      final progress = ValueNotifier<double>(0);
      final scroll = ScrollController();
      addTearDown(offset.dispose);
      addTearDown(progress.dispose);
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(1440, 1000),
                disableAnimations: reduced,
              ),
              child: Scaffold(
                body: WebReaderLayout(
                  reader: ReaderContext(
                    lesson: Lesson(
                      id: 'l',
                      topicId: 't',
                      title: 'Layers',
                      summary: '',
                      estimatedMinutes: 1,
                      bodyJson: [
                        {
                          '_type': 'block',
                          'style': 'h2',
                          'children': [
                            {'text': 'First section'},
                          ],
                        },
                        {
                          '_type': 'block',
                          'style': 'normal',
                          'children': [
                            {
                              'text': List.filled(
                                150,
                                'Read this lesson carefully.',
                              ).join(' '),
                            }
                          ],
                        },
                        {
                          '_type': 'block',
                          'style': 'h2',
                          'children': [
                            {'text': 'Second section'},
                          ],
                        },
                        {
                          '_type': 'block',
                          'style': 'normal',
                          'children': [
                            {
                              'text': List.filled(150, 'More of the lesson.')
                                  .join(' '),
                            }
                          ],
                        },
                      ],
                    ),
                    topicId: 't',
                    topicName: 'Science',
                    next: null,
                    positionInTopic: 1,
                    lessonsInTopic: 1,
                    topicLessons: [],
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
      final dot = find.byKey(const ValueKey('web-reader-outline-dot'));
      final initialDot = tester.getTopLeft(dot);
      final second = find.text('Second section').last;
      scroll.jumpTo(tester.getTopLeft(second).dy - 100);
      offset.value = scroll.offset;
      await tester.pump();
      final target = tester.widget<AnimatedPositioned>(dot).top!;
      expect(target, greaterThan(12));
      await tester.pump(Duration(milliseconds: reduced ? 0 : 250));
      expect(tester.getTopLeft(dot).dy, greaterThan(initialDot.dy));
      scroll.jumpTo(0);
      offset.value = 45;
      await tester.pump();
      final title = tester
          .widget<Align>(find.byKey(const ValueKey('web-reader-title-width')));
      expect(title.widthFactor, .5);
      offset.value = 300;
      await tester.pump();
      await tester.pump(Duration(milliseconds: reduced ? 0 : 700));
      final slide = find.byKey(const ValueKey('web-reader-focus-slide'));
      final transition =
          find.descendant(of: slide, matching: find.byType(SlideTransition));
      expect(
        tester.widget<SlideTransition>(transition).position.value,
        const Offset(0, -1),
      );
      offset.value = 200;
      await tester.pump();
      await tester.pump(Duration(milliseconds: reduced ? 0 : 420));
      expect(
        tester.widget<SlideTransition>(transition).position.value,
        Offset.zero,
      );
    });
    testWidgets('exam switching completes, reduced=$reduced', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var counted = 0;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: MediaQuery(
              data: MediaQueryData(
                size: const Size(1440, 1000),
                disableAnimations: reduced,
              ),
              child: CarryOverScreen(
                exam: 'CSE Professional',
                previous: 'CSE Subprofessional',
                onCounted: () => counted++,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Count Them'));
      await tester.pump();
      if (!reduced) {
        await tester.pump(const Duration(milliseconds: 650));
        expect(
          tester
              .widget<Opacity>(
                find.byKey(const ValueKey('web-transfer-ripple')),
              )
              .opacity,
          greaterThan(0),
        );
        await tester.pump(const Duration(milliseconds: 5750));
      }
      expect(counted, 1);
      expect(
        find.byKey(const ValueKey('web-transfer-wave-old')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('web-transfer-wave-new')),
        findsOneWidget,
      );
      expect(find.text('Done').hitTestable(), findsOneWidget);
      expect(
        tester
            .widget<Transform>(find.byKey(const ValueKey('web-transfer-new')))
            .transform
            .storage[13],
        0,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('navigation edge tab end state, reduced=$reduced',
        (tester) async {
      var hidden = false;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(1440, 1000),
              disableAnimations: reduced,
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return WebMockPanelTab(hidden: hidden, onPressed: () {});
              },
            ),
          ),
        ),
      );
      update(() => hidden = true);
      await tester.pump();
      if (!reduced) await tester.pump(const Duration(milliseconds: 800));
      expect(
        tester
            .widget<Transform>(
              find.byKey(const ValueKey('web-mock-edge-tab')),
            )
            .transform
            .storage[12],
        0,
      );
      update(() => hidden = false);
      await tester.pump();
      if (!reduced) await tester.pump(const Duration(milliseconds: 180));
      expect(find.byKey(const ValueKey('web-mock-edge-tab')), findsNothing);
    });
  }
}
