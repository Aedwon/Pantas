import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';

/// What a question page shows when it cannot open its questions, for example
/// an address with an attempt that does not exist. It always has a way out:
/// a Back link to Quiz, which also works when the page was opened directly.
class QuestionsUnavailable extends StatelessWidget {
  const QuestionsUnavailable({required this.onRetry, super.key});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => PantasPage(
        title: 'Questions',
        backLabel: 'Quiz',
        onBack: () =>
            context.canPop() ? context.pop() : context.pushReplacement('/quiz'),
        children: [errorFor('questions', onRetry)],
      );
}
