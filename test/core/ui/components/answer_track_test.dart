// The answer track in the session bar (core loops B2): one mark per question,
// 10 x 4 px on the wide bar and 8 x 4 on the phone, 3 px apart. Unanswered is
// gray, the current one is solid ink, a checked one is teal or red and changes
// color in 200 ms. Over 20 questions the marks give way to one thin line.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/answer_track.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';

import '../../../helpers/pump_app.dart';

Color _color(WidgetTester tester, int i) {
  // The painted color, not the one the mark is heading for.
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byKey(ValueKey('answer-track-mark-$i')),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as BoxDecoration).color!;
}

void main() {
  const colors = PantasColors.light;

  testWidgets('draws one mark per question with the state colors',
      (tester) async {
    await tester.pumpApp(
      const AnswerTrack(total: 10, answered: [true, false, true], current: 3),
    );
    expect(find.byType(AnimatedContainer), findsNWidgets(10));
    expect(_color(tester, 0), colors.accent);
    expect(_color(tester, 1), colors.danger);
    expect(_color(tester, 2), colors.accent);
    expect(_color(tester, 3), colors.textPrimary);
    for (var i = 4; i < 10; i++) {
      expect(_color(tester, i), colors.dividerStrong);
    }
  });

  testWidgets('the checked current question is colored, not solid ink',
      (tester) async {
    await tester.pumpApp(
      const AnswerTrack(
        total: 10,
        answered: [true, false, true, false],
        current: 3,
      ),
    );
    expect(_color(tester, 3), colors.danger);
    expect(_color(tester, 4), colors.dividerStrong);
  });

  testWidgets('wide marks are 10 x 4, 3 px apart', (tester) async {
    await tester.pumpApp(
      const AnswerTrack(total: 10, answered: [], current: 0),
    );
    final first =
        tester.getRect(find.byKey(const ValueKey('answer-track-mark-0')));
    final second =
        tester.getRect(find.byKey(const ValueKey('answer-track-mark-1')));
    expect(first.size, const Size(10, 4));
    expect(second.left - first.right, 3);
  });

  testWidgets('phone marks are 8 x 4', (tester) async {
    await tester.pumpApp(
      const AnswerTrack(total: 10, answered: [], current: 0, phone: true),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('answer-track-mark-0'))),
      const Size(8, 4),
    );
  });

  testWidgets('a mark changes color over 200 ms', (tester) async {
    expect(PantasDurations.trackColor, const Duration(milliseconds: 200));
    final answered = ValueNotifier<List<bool>>(const []);
    await tester.pumpApp(
      ValueListenableBuilder<List<bool>>(
        valueListenable: answered,
        builder: (_, list, __) =>
            AnswerTrack(total: 10, answered: list, current: 0),
      ),
    );
    answered.value = const [true];
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_color(tester, 0), isNot(colors.accent));
    expect(_color(tester, 0), isNot(colors.textPrimary));
    await tester.pump(const Duration(milliseconds: 101));
    expect(_color(tester, 0), colors.accent);
  });

  testWidgets('over 20 questions the marks give way to one line',
      (tester) async {
    await tester.pumpApp(
      AnswerTrack(
        total: 25,
        answered: List.filled(13, true),
        current: 13,
      ),
    );
    expect(find.byKey(const ValueKey('answer-track-mark-0')), findsNothing);
    expect(find.byKey(const ValueKey('answer-track-line')), findsOneWidget);
    final line =
        tester.getSize(find.byKey(const ValueKey('answer-track-line')));
    expect(line, const Size(104, 4));
    final fill =
        tester.getSize(find.byKey(const ValueKey('answer-track-line-fill')));
    expect(fill.width, closeTo(104 * 13 / 25, 0.01));
  });

  testWidgets('20 questions still draw marks', (tester) async {
    await tester.pumpApp(
      const AnswerTrack(total: 20, answered: [], current: 0),
    );
    expect(find.byType(AnimatedContainer), findsNWidgets(20));
  });

  testWidgets('the phone line is as wide as ten phone marks', (tester) async {
    await tester.pumpApp(
      const AnswerTrack(total: 25, answered: [], current: 0, phone: true),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('answer-track-line'))).width,
      107,
    );
  });

  testWidgets('says which questions are right and wrong', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      const AnswerTrack(total: 10, answered: [true, false, true], current: 3),
    );
    expect(
      tester.getSemantics(find.byType(AnswerTrack)).label,
      'Question 4 of 10. Questions 1 and 3 right, question 2 wrong.',
    );
    handle.dispose();
  });

  testWidgets('a result word is read once as a status', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      const AnswerTrack(
        total: 10,
        answered: [true, true, true, true],
        current: 3,
        status: 'Correct',
      ),
    );
    final node = tester.getSemantics(find.byType(AnswerTrack));
    expect(node.label, startsWith('Question 4 of 10. Correct.'));
    expect(node.flagsCollection.isLiveRegion, isTrue);
    expect(find.text('Correct'), findsNothing);
    handle.dispose();
  });

  testWidgets('still motion changes color at once', (tester) async {
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: AnswerTrack(total: 10, answered: [], current: 0),
      ),
    );
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: AnswerTrack(total: 10, answered: [false], current: 0),
      ),
    );
    expect(_color(tester, 0), colors.danger);
  });
}
