import 'dart:ui' show Tristate;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/new_design/question_grid_sheet.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import '../../../helpers/accessibility.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('choice results draw and announce their states $brightness',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        for (final state in [
          ChoiceRowState.picked,
          ChoiceRowState.right,
          ChoiceRowState.wrong,
        ]) {
          await pumpAccessibilitySurface(
              tester,
              ChoiceRow(
                  letter: 'B', text: 'The answer', state: state, onTap: () {},),
              brightness: brightness,);
          final word = state == ChoiceRowState.picked
              ? 'selected'
              : state == ChoiceRowState.right
                  ? 'correct'
                  : 'wrong';
          expect(find.bySemanticsLabel(RegExp('B.*$word.*The answer')),
              findsOneWidget,);
          if (state != ChoiceRowState.picked) {
            expect(
                find.byIcon(state == ChoiceRowState.right
                    ? PantasIcons.check
                    : PantasIcons.close,),
                findsOneWidget,);
            expect(find.text('B'), findsNothing);
          }
        }
      } finally {
        semantics.dispose();
      }
    });
    testWidgets(
        'grid labels include result current and flag states $brightness',
        (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await pumpAccessibilitySurface(
            tester,
            QuestionGridSheet(
                page: const Text('Page'),
                open: true,
                onDismiss: () {},
                parts: const [
                  QuestionGridPart(title: 'Quiz', questions: [
                    GridQuestion(
                        number: 1,
                        state: GridQuestionState.right,
                        current: true,
                        flagged: true,),
                    GridQuestion(number: 2, state: GridQuestionState.wrong),
                    GridQuestion(number: 3, state: GridQuestionState.answered),
                    GridQuestion(number: 4, state: GridQuestionState.unreached),
                  ],),
                ],
                onSelected: (_) {},),
            brightness: brightness,
            disableAnimations: true,);
        final current = find
            .bySemanticsLabel(RegExp('Question 1.*current.*correct.*flagged'));
        expect(current, findsOneWidget);
        expect(tester.getSemantics(current).flagsCollection.isSelected,
            Tristate.isTrue,);
        for (final label in [
          'Question 2, wrong',
          'Question 3, answered',
          'Question 4, not reached',
        ]) {
          expect(find.bySemanticsLabel(label), findsOneWidget);
        }
      } finally {
        semantics.dispose();
      }
    });
  }
}
