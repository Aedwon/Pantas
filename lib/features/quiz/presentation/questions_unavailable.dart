import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/state_view.dart';

/// What a question page shows when it cannot open its questions, for example
/// an address with an attempt that does not exist. It always has a way out:
/// a Back link to Quiz, which also works when the page was opened directly.
/// When the questions do not exist, [notFound] says so with no Try Again,
/// which could never work; a real load failure keeps it.
class QuestionsUnavailable extends StatelessWidget {
  const QuestionsUnavailable({
    required this.onRetry,
    this.notFound = false,
    super.key,
  });
  final VoidCallback onRetry;
  final bool notFound;

  @override
  Widget build(BuildContext context) => PantasPage(
        title: 'Questions',
        backLabel: 'Quiz',
        onBack: () =>
            context.canPop() ? context.pop() : context.pushReplacement('/quiz'),
        children: [
          if (notFound)
            const StateView(message: 'We could not find those questions.')
          else
            errorFor('questions', onRetry),
        ],
      );
}
