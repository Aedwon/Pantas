import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// What a start says when another quiz is paused. Starting never discards a
/// paused quiz, so the student resumes it or discards it, the same two
/// choices the Quiz tab's paused card offers. It follows the Notice pattern:
/// one sentence in `text-secondary`, then the actions.
class PausedQuizNotice extends StatelessWidget {
  const PausedQuizNotice({
    required this.onResume,
    required this.onDiscard,
    super.key,
  });

  final VoidCallback onResume;

  /// Null while a discard is running.
  final VoidCallback? onDiscard;

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final colors = context.colors;
    final line = (wide ? PantasType.webSub : PantasType.phoneExplanation)
        .copyWith(color: colors.textSecondary);
    return Semantics(
      liveRegion: true,
      child: Padding(
        // The wide panel pads its rows by 16; the phone sheet pads itself.
        padding: EdgeInsets.fromLTRB(
          wide ? PantasSpace.s16 : PantasSpace.s0,
          PantasSpace.s4,
          wide ? PantasSpace.s16 : PantasSpace.s0,
          PantasSpace.s14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You paused a quiz. Resume it or discard it to start these '
              'questions.',
              style: line,
            ),
            const SizedBox(height: PantasSpace.s12),
            if (wide) ...[
              WebButton(label: 'Resume', expand: true, onPressed: onResume),
              const SizedBox(height: PantasSpace.s6),
              WebButton(
                label: 'Discard this session',
                variant: WebButtonVariant.tertiary,
                expand: true,
                onPressed: onDiscard,
              ),
            ] else ...[
              PantasButton(label: 'Resume', onPressed: onResume),
              const SizedBox(height: PantasSpace.s6),
              TextButton(
                onPressed: onDiscard,
                style: TextButton.styleFrom(
                  minimumSize: const Size(
                    PantasSize.targetTouch,
                    PantasSize.targetTouch,
                  ),
                ),
                child: Text(
                  'Discard this session',
                  style: PantasType.webLink.copyWith(color: colors.accent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
