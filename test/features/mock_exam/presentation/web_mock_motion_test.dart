import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart'
    show MockAnswer;
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';
import 'package:pantas/features/mock_exam/presentation/pages/custom_mock_setup_page.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_session_page.dart';
import 'package:pantas/features/mock_exam/presentation/part_transition_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';

// Wide web plays the phone's mock motion: the paper swap, the between-parts
// dots, the card rise and the row editors.

HydratedMockQuestion _question(String id) => HydratedMockQuestion(
      Question(
        id: id,
        version: 1,
        examIds: const [],
        topicId: 'topic',
        language: 'en',
        stem: 'Stem of $id',
        explanation: 'Explanation.',
        choices: const [
          Choice(id: 'a', label: 'A', text: 'One', isCorrect: true),
          Choice(id: 'b', label: 'B', text: 'Two', isCorrect: false),
        ],
      ),
      null,
    );

class _Paper extends StatefulWidget {
  const _Paper({required this.onAnswer});
  final ValueChanged<int> onAnswer;
  @override
  State<_Paper> createState() => _PaperState();
}

class _PaperState extends State<_Paper> {
  int index = 0;
  @override
  Widget build(BuildContext context) => MockSessionPage(
        state: MockSessionInProgress(
          attemptId: 'a',
          durationSeconds: 3600,
          questionIds: const ['q1', 'q2', 'q3'],
          currentIndex: index,
          elapsedSeconds: 0,
          answers: const {},
          flags: const {},
          strictMode: false,
        ),
        remainingInPart: const Duration(minutes: 48),
        partPosition: index + 1,
        partTotal: 3,
        canGoPrevious: index > 0,
        canGoNext: index < 2,
        onPrevious: () => setState(() => index--),
        onNext: () => setState(() => index++),
        onAnswer: widget.onAnswer,
        onToggleFlag: () {},
        onPause: () {},
        onGoTo: (i) => setState(() => index = i),
      );
}

void main() {
  void wide(WidgetTester tester) {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(
    Widget home, {
    required bool still,
    List<Override> overrides = const [],
  }) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: still),
            child: child!,
          ),
          home: home,
        ),
      );

  Widget paper({bool still = false, ValueChanged<int>? onAnswer}) => app(
        _Paper(onAnswer: onAnswer ?? (_) {}),
        still: still,
        overrides: [
          hydratedMockQuestionProvider
              .overrideWith((ref, id) async => _question(id)),
        ],
      );

  Finder stem(String id) => find.text('Stem of $id', skipOffstage: false);
  Finder swapOut() =>
      find.byKey(const ValueKey('paper-swap-out'), skipOffstage: false);
  Finder swapIn() =>
      find.byKey(const ValueKey('paper-swap-in'), skipOffstage: false);
  double dx(WidgetTester tester, Finder swap) => tester
      .widget<Transform>(
        find.descendant(of: swap, matching: find.byType(Transform)).first,
      )
      .transform
      .getTranslation()
      .x;

  group('M1 wide paper swap', () {
    testWidgets('Next slides the old question out and the new one in',
        (tester) async {
      wide(tester);
      await tester.pumpWidget(paper());
      await tester.pumpAndSettle();
      expect(stem('q1'), findsOneWidget);
      expect(swapOut(), findsNothing);
      await tester.tap(find.byTooltip('Next question'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 190));
      final progress = const Cubic(.2, .9, .3, 1).transform(.5);
      expect(swapOut(), findsOneWidget);
      expect(dx(tester, swapOut()), closeTo(-40 * progress, 1));
      expect(dx(tester, swapIn()), closeTo(40 * (1 - progress), 1));
      expect(stem('q1'), findsOneWidget);
      expect(stem('q2'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(swapOut(), findsNothing);
      expect(stem('q1'), findsNothing);
      expect(stem('q2'), findsOneWidget);
    });

    testWidgets('dark answered cells stand clear of blank ones',
        (tester) async {
      wide(tester);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hydratedMockQuestionProvider
                .overrideWith((ref, id) async => _question(id)),
          ],
          child: MaterialApp(
            theme: buildDarkTheme(web: true),
            home: MockSessionPage(
              state: const MockSessionInProgress(
                attemptId: 'a',
                durationSeconds: 3600,
                questionIds: ['q1', 'q2', 'q3'],
                currentIndex: 2,
                elapsedSeconds: 0,
                answers: {'q1': MockAnswer(selectedIndex: 0, atSec: 0)},
                flags: {},
                strictMode: false,
              ),
              remainingInPart: const Duration(minutes: 48),
              partPosition: 3,
              partTotal: 3,
              canGoPrevious: true,
              canGoNext: false,
              onPrevious: () {},
              onNext: () {},
              onAnswer: (_) {},
              onToggleFlag: () {},
              onPause: () {},
              onGoTo: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Color fill(String number) => tester
          .widget<TextButton>(
            find.ancestor(
              of: find.text(number),
              matching: find.byType(TextButton),
            ),
          )
          .style!
          .backgroundColor!
          .resolve({})!;
      const dark = PantasColors.dark;
      // QuestionNavigator: answered is the `divider` fill with no ring;
      // blank is the card with the 3:1 `border-control` ring. The ring is the
      // shape cue, so the two never rest on the fill alone.
      expect(fill('1'), dark.divider);
      expect(fill('2'), dark.surfaceCard);
      OutlinedBorder shape(String number) => tester
          .widget<TextButton>(
            find.ancestor(
              of: find.text(number),
              matching: find.byType(TextButton),
            ),
          )
          .style!
          .shape!
          .resolve({})!;
      expect(shape('1').side, BorderSide.none);
      expect(shape('2').side.color, dark.borderControl);
    });

    testWidgets(
        'hiding and showing the list never nudges the bar the wrong way',
        (tester) async {
      wide(tester);
      await tester.pumpWidget(paper());
      await tester.pumpAndSettle();
      double barLeft() => tester.getTopLeft(find.byType(WebBottomBar)).dx;
      Future<List<double>> trace(Finder toggle) async {
        final xs = [barLeft()];
        await tester.tap(toggle);
        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          xs.add(barLeft());
        }
        await tester.pumpAndSettle();
        xs.add(barLeft());
        return xs;
      }

      // Hiding: the list leaves and the bar slides left toward the middle of
      // the wider page. It never jumps right on the first frame.
      final hiding = await trace(find.byTooltip('Hide the question list'));
      for (var i = 1; i < hiding.length; i++) {
        expect(hiding[i], lessThanOrEqualTo(hiding[i - 1] + .5), reason: '$i');
      }
      expect(hiding.last, lessThan(hiding.first));
      // Showing: the mirror image, never left before it goes right.
      final showing = await trace(find.byTooltip('Show the question list'));
      for (var i = 1; i < showing.length; i++) {
        expect(
          showing[i],
          greaterThanOrEqualTo(showing[i - 1] - .5),
          reason: '$i',
        );
      }
      expect(showing.last, closeTo(hiding.first, .5));
    });

    testWidgets(
        'keys and answers work during a swap and a rapid Next keeps '
        'the last question', (tester) async {
      wide(tester);
      int? answered;
      await tester.pumpWidget(paper(onAnswer: (i) => answered = i));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(swapOut(), findsOneWidget);
      // The new question takes the answer while the old one fades.
      await tester.tap(
        find.descendant(of: swapIn(), matching: find.text('Two')),
      );
      expect(answered, 1);
      // A second Next mid swap: one outgoing question, never a stack.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(swapOut(), findsOneWidget);
      expect(find.text('3 of 3'), findsOneWidget);
      expect(stem('q1'), findsNothing);
      await tester.pumpAndSettle();
      expect(stem('q3'), findsOneWidget);
      expect(stem('q2'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(stem('q2'), findsOneWidget);
      expect(find.text('2 of 3'), findsOneWidget);
    });

    testWidgets('reduced motion changes the question at once', (tester) async {
      wide(tester);
      await tester.pumpWidget(paper(still: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Next question'));
      await tester.pump();
      // The old question is gone on the first frame; the new one loads.
      expect(swapOut(), findsNothing);
      expect(stem('q1'), findsNothing);
      await tester.pumpAndSettle();
      expect(stem('q2'), findsOneWidget);
    });
  });

  group('M2 wide between parts', () {
    Widget between({required bool still}) => app(
          PartTransitionPage(
            partNames: const ['Numerical Ability', 'General Information'],
            nextPartIndex: 1,
            answeredQuestions: [for (var i = 0; i < 40; i++) i.isEven],
            endedEarly: false,
            onStartNext: () {},
          ),
          still: still,
        );
    Finder dot(int i) => find.byKey(ValueKey('part-dot-opacity-$i'));
    double opacity(WidgetTester tester, int i) =>
        tester.widget<Opacity>(dot(i)).opacity;

    testWidgets('dots run on the phone timeline', (tester) async {
      wide(tester);
      await tester.pumpWidget(between(still: false));
      expect(opacity(tester, 0), 0);
      await tester.pump(const Duration(milliseconds: 300));
      final middle = opacity(tester, 0);
      expect(middle, greaterThan(0));
      expect(middle, lessThan(1));
      expect(opacity(tester, 39), 0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacity(tester, 0), 1);
      await tester.pumpAndSettle();
      expect(opacity(tester, 39), 1);
    });

    testWidgets('reduced motion shows every dot at once', (tester) async {
      wide(tester);
      await tester.pumpWidget(between(still: true));
      expect(opacity(tester, 0), 1);
      expect(opacity(tester, 39), 1);
    });
  });

  group('M3 wide mock card rise', () {
    Widget card({required bool still}) => app(
          const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(40),
              child: MockCard(
                model: MockCardModel(
                  state: MockCardState.neverTaken,
                  name: 'CSE simulation',
                ),
              ),
            ),
          ),
          still: still,
        );
    double opacity(WidgetTester tester) => tester
        .widget<Opacity>(find.byKey(const ValueKey('mock-card-opacity')))
        .opacity;
    double rise(WidgetTester tester) => tester
        .widget<Transform>(find.byKey(const ValueKey('mock-card-rise')))
        .transform
        .getTranslation()
        .y;

    testWidgets('holds 190 ms, then rises 12 px', (tester) async {
      wide(tester);
      await tester.pumpWidget(card(still: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacity(tester), 0);
      expect(rise(tester), 12);
      await tester.pump(const Duration(milliseconds: 250));
      expect(opacity(tester), greaterThan(0));
      expect(opacity(tester), lessThan(1));
      expect(rise(tester), greaterThan(0));
      await tester.pumpAndSettle();
      expect(opacity(tester), 1);
      expect(rise(tester), 0);
    });

    testWidgets('reduced motion shows the card at once', (tester) async {
      wide(tester);
      await tester.pumpWidget(card(still: true));
      expect(opacity(tester), 1);
      expect(rise(tester), 0);
    });
  });

  group('M4 wide custom mock row editors', () {
    const subjects = [
      Subject(id: 'math', examId: 'custom', name: 'Mathematics', ordering: 0),
    ];
    Widget setup({required bool still}) => app(
          CustomMockSetupPage(
            data: const CustomMockSetupData(
              examId: 'custom',
              subjects: subjects,
              topicsBySubject: {},
              availableQuestions: 240,
            ),
            onSave: (_) async {},
            onTickMoreSubjects: () {},
          ),
          still: still,
        );
    Finder editor() => find.ancestor(
          of: find.byTooltip('Decrease Questions'),
          matching: find.byType(AnimatedSize),
        );

    testWidgets('a row opens over 300 ms and closes the same way',
        (tester) async {
      wide(tester);
      await tester.pumpWidget(setup(still: false));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Questions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final partial = tester.getSize(editor()).height;
      expect(partial, greaterThan(0));
      await tester.pumpAndSettle();
      final full = tester.getSize(editor()).height;
      expect(full, greaterThan(partial));
      await tester.tap(find.text('Questions'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final closing = tester.getSize(find.byType(AnimatedSize).first).height;
      expect(closing, lessThan(full));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Decrease Questions'), findsNothing);
    });

    testWidgets('reduced motion opens the row at once', (tester) async {
      wide(tester);
      await tester.pumpWidget(setup(still: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Questions'));
      await tester.pump();
      expect(find.byTooltip('Decrease Questions'), findsOneWidget);
      expect(editor(), findsNothing);
    });
  });
}
