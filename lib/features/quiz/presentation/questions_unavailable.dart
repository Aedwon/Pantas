import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

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
  Widget build(BuildContext context) {
    void close() =>
        context.canPop() ? context.pop() : context.pushReplacement('/quiz');
    final child = notFound
        ? const StateView(message: 'We could not find those questions.')
        : errorFor('questions', onRetry);
    if (context.wideWeb) {
      return QuizUnavailableFrame(onClose: close, child: child);
    }
    return PantasPage(
      title: 'Questions',
      backLabel: 'Quiz',
      onBack: close,
      children: [child],
    );
  }
}

class QuizUnavailableFrame extends StatelessWidget {
  const QuizUnavailableFrame({
    required this.onClose,
    required this.child,
    super.key,
  });

  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): onClose,
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: context.colors.bgPage,
            body: Column(
              children: [
                WebCenteredTopBar(
                  title: 'Quiz',
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WebTopBarButton(
                        tooltip: 'Leave session',
                        onPressed: onClose,
                        icon: Icon(PantasIcons.close, size: 22),
                      ),
                      const SizedBox(width: PantasSpace.s10),
                      const WebKeyHint('Esc'),
                    ],
                  ),
                ),
                Expanded(child: Center(child: child)),
              ],
            ),
          ),
        ),
      );
}
