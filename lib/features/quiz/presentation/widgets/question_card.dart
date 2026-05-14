import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/quiz_answer_tile.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.question,
    required this.onAnswer,
    super.key,
  });

  final Question question;
  final void Function(String chosenChoiceId) onAnswer;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(question.stem, style: styles.headlineSmall),
          const SizedBox(height: 16),
          for (final choice in question.choices) ...[
            QuizAnswerTile(
              letter: choice.label,
              text: choice.text,
              onTap: () => onAnswer(choice.id),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
