import 'package:flutter/widgets.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/figure_choice_tiles.dart';
import 'package:pantas/core/ui/figures/choice_figure.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';

/// The one place that decides how a question's choices look: figure tiles when
/// the question asks for them and every choice can be drawn, today's text rows
/// otherwise (also for mixed or bad data). The phone and the web both call it,
/// and so does every surface, so no page repeats the switch.
abstract final class QuestionChoices {
  /// Whether [question] shows figure tiles.
  static bool tiles(Question question) => QuestionChoicePlan.of(question).tiles;

  /// The question's own figure, or null when it has none or the tiles carry
  /// it (an odd-one-out question, where the shapes are the choices).
  static Widget? figure(Question question) {
    if (question.figureSpecJson == null) return null;
    if (!QuestionChoicePlan.of(question).showQuestionFigure) return null;
    return QuestionFigure(specJson: question.figureSpecJson);
  }

  /// The choices as widgets for a question card: one [ChoiceRow] per choice,
  /// or a single [FigureChoiceGroup].
  ///
  /// [stateOf] gives each choice's state. [onPick] picks a choice; null makes
  /// the choices read only. [chosenId] is the choice the student picked, for
  /// the tile's checked state after the reveal.
  static List<Widget> build(
    Question question, {
    required ChoiceRowState Function(Choice choice) stateOf,
    ValueChanged<Choice>? onPick,
    String? chosenId,
  }) {
    final plan = QuestionChoicePlan.of(question);
    final figures = plan.figures;
    if (figures == null) {
      return [
        for (final choice in question.choices)
          ChoiceRow(
            letter: choice.label,
            text: choice.text,
            state: stateOf(choice),
            onTap: onPick == null ? null : () => onPick(choice),
          ),
      ];
    }
    return [
      FigureChoiceGroup(
        stem: question.stem,
        items: [
          for (final (i, choice) in question.choices.indexed)
            FigureChoiceItem(
              letter: choice.label,
              description: choice.text,
              figure: figures[i],
              state: stateOf(choice),
              chosen: chosenId == null ? null : choice.id == chosenId,
            ),
        ],
        onPick: onPick == null ? null : (i) => onPick(question.choices[i]),
      ),
    ];
  }
}
