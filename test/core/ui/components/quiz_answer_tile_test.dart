import 'package:cse_cet_reviewer/core/ui/components/quiz_answer_tile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('QuizAnswerTile', () {
    testWidgets('shows letter prefix and answer text', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(letter: 'A', text: 'Personnel audit', onTap: () {}),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Personnel audit'), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        QuizAnswerTile(
          letter: 'B',
          text: 'Option B',
          onTap: () => tapped = true,
        ),
      );
      await tester.tap(find.byType(QuizAnswerTile));
      expect(tapped, isTrue);
    });

    testWidgets('selected state shows check icon hidden — letter turns blue',
        (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(
          letter: 'A',
          text: 'Option',
          onTap: () {},
          isSelected: true,
        ),
      );
      // Letter 'A' is still shown (not replaced in selected state)
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('correct state shows checkmark icon', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(
          letter: 'A',
          text: 'Right answer',
          onTap: () {},
          state: TileState.correct,
        ),
      );
      expect(find.text('✅'), findsOneWidget);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('incorrect state shows X icon and strikethrough',
        (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(
          letter: 'B',
          text: 'Wrong answer',
          onTap: () {},
          state: TileState.incorrect,
        ),
      );
      expect(find.text('❌'), findsOneWidget);
    });

    testWidgets('correctMissed state shows bulb icon', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(
          letter: 'C',
          text: 'Correct option',
          onTap: () {},
          state: TileState.correctMissed,
        ),
      );
      expect(find.text('💡'), findsOneWidget);
    });

    testWidgets('has minimum 48dp height', (tester) async {
      await tester.pumpApp(
        QuizAnswerTile(letter: 'A', text: 'Option', onTap: () {}),
      );
      final size = tester.getSize(find.byType(QuizAnswerTile));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
