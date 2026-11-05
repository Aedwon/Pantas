import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// What a start says when another quiz is paused. Starting never discards a
/// paused quiz, so the student resumes it or discards it, the same two
/// choices the Quiz tab's paused card offers.
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
    final line = wide
        ? context.webTokens.sub
        : context.type.subhead.copyWith(color: context.colors.secondaryLabel);
    return Semantics(
      liveRegion: true,
      child: Padding(
        // The wide panel pads its rows by 16 px; the phone sheet pads itself.
        padding: EdgeInsets.fromLTRB(wide ? 16 : 0, 4, wide ? 16 : 0, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You paused a quiz. Resume it or discard it to start these '
              'questions.',
              style: line,
            ),
            const SizedBox(height: 12),
            if (wide) ...[
              WebButton(label: 'Resume', expand: true, onPressed: onResume),
              const SizedBox(height: 6),
              WebButton(
                label: 'Discard this session',
                variant: WebButtonVariant.tertiary,
                expand: true,
                onPressed: onDiscard,
              ),
            ] else ...[
              PantasButton(label: 'Resume', onPressed: onResume),
              const SizedBox(height: 6),
              TextButton(
                onPressed: onDiscard,
                child: Text(
                  'Discard this session',
                  style: context.type.subheadStrong
                      .copyWith(color: context.colors.accent),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
