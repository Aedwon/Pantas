import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/application/session_debrief_provider.dart';
import 'package:pantas/features/quiz/data/session_diagnosis_api.dart';
import 'package:pantas/features/quiz/domain/models/review_batch_position.dart';
import 'package:pantas/features/quiz/presentation/session_debrief_cards.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';

import 'session_end_screen_test.dart' show completedAttempt, completedSession;

const _plan = DebriefPlanData(
  lessonTitles: {
    'p': 'Order of Operations',
    'l': 'Algebraic Expressions',
    'f': 'Fractions',
  },
  next: DebriefRecommendation(
    title: 'Order of Operations practice',
    because: 'Practice this before going back to Algebraic Expressions.',
    lessonId: 'p',
  ),
);

Map<String, Object?> _group(
  String lesson,
  List<int> positions, {
  bool within = false,
}) =>
    {
      if (within) 'lesson': lesson else 'prerequisite': lesson,
      'questions': [
        for (final n in positions)
          {
            'questionId': 'secret-question-$n',
            'position': n,
            'mistake': 'First mistake $n. Secret second sentence.',
          },
      ],
    };

SessionDiagnosisData _data({
  bool pro = false,
  int count = 3,
  bool multiple = false,
  bool within = false,
}) =>
    SessionDiagnosisData.decode({
      'status': 'ok',
      'tier': pro ? 'pro' : 'free',
      'tracedCount': count,
      'traced': multiple
          ? [
              _group('f', [3, 6]),
              _group('p', [1, 5, 8, 9]),
            ]
          : [
              _group('p', [2, 5, 8].take(count).toList()),
            ],
      'withinLesson': within
          ? [
              _group('l', [10], within: true),
            ]
          : <Object?>[],
    })!;

void main() {
  for (final wide in [false, true]) {
    for (final dark in [false, true]) {
      testWidgets('review fixes wide=$wide dark=$dark', (tester) async {
        Widget cards({required bool pro, required DebriefPlanData? plan}) =>
            MaterialApp(
              theme: dark ? buildDarkTheme() : buildLightTheme(),
              home: Scaffold(
                body: SessionDebriefCards(
                  plan: plan,
                  diagnosis: _data(pro: pro, within: true),
                  pro: pro,
                  wide: wide,
                  onDismiss: () {},
                  onPaywall: () {},
                  onLesson: (_) {},
                  onMistakes: () {},
                  onRecommendation: () {},
                ),
              ),
            );
        await tester.pumpWidget(
          cards(
            pro: false,
            plan: const DebriefPlanData(lessonTitles: {}),
          ),
        );
        expect(
          find.textContaining('See which', findRichText: true),
          findsOneWidget,
        );
        expect(find.text('NEXT'), findsNothing);
        await tester.pumpWidget(cards(pro: false, plan: null));
        expect(
          find.textContaining('See which', findRichText: true),
          findsOneWidget,
        );
        await tester.pumpWidget(cards(pro: true, plan: _plan));
        final chevrons =
            tester.widgetList<Icon>(find.byIcon(Icons.chevron_right));
        expect(chevrons, isNotEmpty);
        for (final icon in chevrons) {
          expect(icon.color, Color(dark ? 0xFF5C5C5C : 0xFFC7C7CC));
        }
        if (wide) {
          final row = find.ancestor(
            of: find.text('1 is in Algebraic Expressions itself'),
            matching: find.byType(InkWell),
          );
          final circle = find.descendant(
            of: row,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).shape ==
                      BoxShape.circle,
            ),
          );
          expect(circle, findsOneWidget);
          expect(tester.getSize(circle), const Size(26, 26));
          final decoration =
              tester.widget<Container>(circle).decoration! as BoxDecoration;
          expect(decoration.color, Color(dark ? 0xFF33201F : 0xFFFDE8EA));
        }
      });
    }
  }

  for (final width in [390.0, 800.0, 1100.0, 1440.0]) {
    final wide = width >= 1024;
    for (final dark in [false, true]) {
      for (var state = 1; state <= 13; state++) {
        testWidgets(
            'state $state width=$width '
            '${dark ? 'dark' : 'light'}', (tester) async {
          tester.view.physicalSize = Size(width, 1100);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final semantics = tester.ensureSemantics();

          final pro = state >= 5 && state <= 10;
          final hidden = [3, 4, 8, 9, 10, 11, 12].contains(state);
          final plan = state == 4
              ? const DebriefPlanData(
                  lessonTitles: {'p': 'Order of Operations'},
                  next: DebriefRecommendation(
                    title: 'Order of Operations',
                    because: 'Algebraic Expressions builds on it.',
                    lessonId: 'p',
                  ),
                )
              : _plan;
          var dismissed = false;
          var paywall = false;
          String? opened;
          await tester.pumpWidget(
            MaterialApp(
              theme: dark ? buildDarkTheme() : buildLightTheme(),
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(state == 13 ? 1.3 : 1),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? (width - 640) / 2 : 16,
                      ),
                      child: SessionDebriefCards(
                        plan: plan,
                        diagnosis: state == 10
                            ? null
                            : _data(
                                pro: pro,
                                count: state == 4 || state == 8
                                    ? 0
                                    : state == 2
                                        ? 1
                                        : state == 6
                                            ? 6
                                            : state == 5
                                                ? 2
                                                : 3,
                                multiple: state == 6,
                                within: state == 5 || state == 6,
                              ),
                        pro: pro,
                        wide: wide,
                        paused: state == 12,
                        showDiagnosis:
                            ![3, 9, 11].contains(state) && !dismissed,
                        onDismiss: () => setState(() => dismissed = true),
                        onPaywall: () => paywall = true,
                        onLesson: (id) => opened = id,
                        onMistakes: () => opened = 'mistakes',
                        onRecommendation: () => opened = 'next',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          expect(find.text('NEXT'), findsOneWidget);
          expect(find.text(plan.next!.because), findsOneWidget);
          if (hidden) {
            expect(find.byTooltip('Dismiss this note'), findsNothing);
            expect(find.text('WHERE YOUR MISSES CAME FROM'), findsNothing);
          } else if (pro) {
            expect(find.text('WHERE YOUR MISSES CAME FROM'), findsOneWidget);
            expect(find.textContaining('Secret second sentence'), findsNothing);
            expect(find.textContaining('secret-question'), findsNothing);
            if (state == 5 || state == 6) {
              expect(
                find.text('1 is in Algebraic Expressions itself'),
                findsOneWidget,
              );
              expect(find.text('Question 10'), findsOneWidget);
            } else {
              expect(find.textContaining('itself'), findsNothing);
            }
            if (state == 6) {
              expect(find.text('and 1 more: Question 9'), findsOneWidget);
              expect(find.text('First mistake 9.'), findsNothing);
            }
            await tester
                .tap(find.textContaining('trace to Order of Operations').first);
            expect(opened, 'p');
          } else {
            final label = state == 2
                ? '1 of your misses traces to an earlier lesson.'
                : '3 of your misses trace to an earlier lesson.';
            expect(find.textContaining(label), findsOneWidget);
            expect(find.textContaining('First mistake'), findsNothing);
            expect(find.textContaining('secret-question'), findsNothing);
            await tester.tap(find.textContaining('See which').first);
            expect(paywall, isTrue);
            final node = tester.getSemantics(
              find.bySemanticsLabel(
                'PRO. $label See which. '
                'Opens the paywall at the diagnosis.',
              ),
            );
            expect(
              node,
              matchesSemantics(
                label: 'PRO. $label See which. '
                    'Opens the paywall at the diagnosis.',
                isButton: true,
                hasTapAction: true,
              ),
            );
            expect(
              tester.getSize(find.byTooltip('Dismiss this note')),
              const Size(44, 44),
            );
          }
          if (!hidden) {
            await tester.tap(find.byTooltip('Dismiss this note'));
            expect(dismissed, isTrue);
            await tester.pump();
            expect(find.byTooltip('Dismiss this note'), findsNothing);
            expect(find.text(plan.next!.title), findsOneWidget);
          }
          semantics.dispose();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  for (final width in [390.0, 800.0, 1100.0, 1440.0]) {
    for (final dark in [false, true]) {
      testWidgets('state 12b review batch at $width dark=$dark',
          (tester) async {
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        debugWebPlatformOverride = true;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          debugWebPlatformOverride = null;
        });
        final session = completedSession().copyWith(
          reviewBatch: const ReviewBatchPosition(
            batchId: 'batch',
            userId: 'local',
            ordinal: 2,
            total: 3,
          ),
        );
        var started = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? buildDarkTheme() : buildLightTheme(),
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1100),
                  disableAnimations: true,
                ),
                child: SessionEndBody(
                  session: session,
                  attempt: completedAttempt(session),
                  subjectNames: const {'t': 'Algebra'},
                  proIsActive: false,
                  onDone: () {},
                  onQuestion: (_) {},
                  onAll: () {},
                  onMistakes: () {},
                  onNotes: () {},
                  onNext: () async {
                    started = true;
                  },
                  debriefCards: SessionDebriefCards(
                    plan: _plan,
                    diagnosis: _data(),
                    pro: false,
                    wide: width >= 1024,
                    onDismiss: () {},
                    onPaywall: () {},
                    onLesson: (_) {},
                    onMistakes: () {},
                    onRecommendation: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Reviews · Session 2 of 3'), findsOneWidget);
        expect(find.text('Start Session 3'), findsOneWidget);
        expect(find.text(_plan.next!.title), findsOneWidget);
        await tester.tap(find.text('Start Session 3'));
        await tester.pumpAndSettle();
        expect(started, isTrue);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final wide in [false, true]) {
    testWidgets('diagnosis heading keeps board spacing wide=$wide',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: SizedBox(
              width: wide ? 640 : 358,
              child: SessionDebriefCards(
                plan: _plan,
                diagnosis: _data(pro: true, within: true),
                pro: true,
                wide: wide,
                onDismiss: () {},
                onPaywall: () {},
                onLesson: (_) {},
                onMistakes: () {},
                onRecommendation: () {},
              ),
            ),
          ),
        ),
      );
      final title = find.text('WHERE YOUR MISSES CAME FROM');
      final row = find.text('3 trace to Order of Operations');
      // The 44 px dismiss control overhangs the heading. It must not add
      // height between the heading and the card.
      expect(
        tester.getTopLeft(row).dy - tester.getTopLeft(title).dy,
        lessThan(wide ? 60 : 55),
      );
      final nextRow = find.ancestor(
        of: find.text(_plan.next!.title),
        matching: find.byType(InkWell),
      );
      expect(
        tester.getTopLeft(title).dy - tester.getBottomLeft(nextRow).dy,
        wide ? 32 : 22,
      );
      expect(find.byType(Divider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [390.0, 800.0, 1100.0, 1440.0]) {
    for (final dark in [false, true]) {
      testWidgets('paused screen keeps its notice at $width dark=$dark',
          (tester) async {
        tester.view.physicalSize = Size(width, 1400);
        tester.view.devicePixelRatio = 1;
        debugWebPlatformOverride = true;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
          debugWebPlatformOverride = null;
        });
        final session = completedSession();
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? buildDarkTheme() : buildLightTheme(),
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 1400),
                  disableAnimations: true,
                ),
                child: SessionEndBody(
                  session: session,
                  attempt: completedAttempt(session),
                  subjectNames: const {'t': 'Algebra'},
                  proIsActive: false,
                  proPaused: true,
                  onDone: () {},
                  onQuestion: (_) {},
                  onAll: () {},
                  onMistakes: () {},
                  onNotes: () {},
                  debriefCards: SessionDebriefCards(
                    plan: _plan,
                    diagnosis: _data(pro: true),
                    pro: false,
                    paused: true,
                    wide: width >= 1024,
                    onDismiss: () {},
                    onPaywall: () {},
                    onLesson: (_) {},
                    onMistakes: () {},
                    onRecommendation: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Connect once to keep using Pro.'), findsOneWidget);
        expect(find.text('WHERE YOUR MISSES CAME FROM'), findsNothing);
        expect(find.textContaining('See which'), findsNothing);
        expect(
          tester.getTopLeft(find.text('NEXT')).dy,
          lessThan(
            tester.getTopLeft(find.textContaining('YOUR MISTAKES')).dy,
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('phone recommendation wraps at large text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: SizedBox(
              width: 358,
              child: SessionDebriefCards(
                plan: _plan,
                diagnosis: null,
                pro: false,
                wide: false,
                onDismiss: () {},
                onPaywall: () {},
                onLesson: (_) {},
                onMistakes: () {},
                onRecommendation: () {},
              ),
            ),
          ),
        ),
      ),
    );
    final title = tester.widget<Text>(find.text(_plan.next!.title));
    expect(title.maxLines, isNull);
    expect(title.overflow, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Free presentation never exposes Pro detail', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: SessionDebriefCards(
            plan: _plan,
            diagnosis: _data(pro: true, multiple: true, within: true),
            pro: false,
            wide: false,
            onDismiss: () {},
            onPaywall: () {},
            onLesson: (_) {},
            onMistakes: () {},
            onRecommendation: () {},
          ),
        ),
      ),
    );
    expect(find.textContaining('See which'), findsOneWidget);
    expect(find.textContaining('First mistake'), findsNothing);
    expect(find.textContaining('secret-question'), findsNothing);
    expect(find.textContaining('Fractions'), findsNothing);
    expect(find.textContaining('Question 10'), findsNothing);
  });

  test('first sentence keeps decimals and supports a note without punctuation',
      () {
    expect(
      firstMistakeSentence('This uses 1.5 instead of 2. Then check.'),
      'This uses 1.5 instead of 2.',
    );
    expect(firstMistakeSentence('One short note'), 'One short note');
  });
}
