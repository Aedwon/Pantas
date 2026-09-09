import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/answer_row.dart';
import 'package:pantas/core/ui/components/passage_card.dart';
import 'package:pantas/core/ui/components/portable_text_renderer.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.question,
    required this.onAnswer,
    this.passage,
    this.chosenChoiceId,
    this.revealed = false,
    super.key,
  });

  final Question question;
  final void Function(String chosenChoiceId)? onAnswer;

  /// Optional passage attached to reading comprehension questions.
  final Passage? passage;

  /// Null while the question is unanswered.
  final ChoiceId? chosenChoiceId;

  /// Once revealed the rows are a record. The attempt row and the FSRS update
  /// were written the instant the choice was tapped, so there is nothing an
  /// edit could mean.
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (passage != null) PassageCard(passage: passage!),
        // Stems carry LaTeX and markdown. A plain Text renders them
        // literally, which is UI-005 through UI-007.
        PortableTextRenderer(text: question.stem),
        // The diagram, drawn from the spec in the question's own file. Most
        // questions have none and this collapses to nothing.
        QuestionFigure(specJson: question.figureSpecJson),
        const SizedBox(height: 20),
        for (final choice in question.choices)
          Opacity(
            opacity: _dimmed(choice) ? 0.5 : 1.0,
            child: AnswerRow(
              letter: choice.label,
              text: choice.text,
              state: _stateFor(choice),
              onTap: revealed || onAnswer == null
                  ? null
                  : () => onAnswer!(choice.id),
            ),
          ),
      ],
    );
  }

  AnswerRowState _stateFor(Choice choice) {
    if (!revealed) {
      return choice.id == chosenChoiceId
          ? AnswerRowState.selected
          : AnswerRowState.plain;
    }
    if (choice.id == chosenChoiceId) {
      return choice.isCorrect
          ? AnswerRowState.correct
          : AnswerRowState.incorrect;
    }
    if (choice.isCorrect) return AnswerRowState.correctMissed;
    return AnswerRowState.plain;
  }

  /// Every row that is neither the pick nor the answer recedes.
  bool _dimmed(Choice choice) =>
      revealed && choice.id != chosenChoiceId && !choice.isCorrect;
}
