import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// The phone bar's count with its up-down caret (board NF_Text, idea 3): the
/// count, 8 apart from a 16 px caret in the secondary text color. The caret is
/// decoration, so screen readers skip it; the button that holds this label
/// carries the name. Padding is 0 12 0 16 (`nf-v-t3`).
class QuestionCount extends StatelessWidget {
  const QuestionCount({required this.text, required this.style, super.key});

  final String text;
  final TextStyle style;

  static const EdgeInsets padding = EdgeInsets.only(
    left: PantasSpace.s16,
    right: PantasSpace.s12,
  );

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(text, style: style)),
          const SizedBox(width: PantasSpace.s8),
          ExcludeSemantics(
            child: Icon(
              PantasIcons.caretUpDown,
              size: 16,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      );
}

/// The count as a button that opens the question navigator (mock phone bar).
/// A 44 px minimum hit area; pressed scales to 0.97 with no fill.
class QuestionCountButton extends StatelessWidget {
  const QuestionCountButton({
    required this.text,
    required this.style,
    required this.semanticLabel,
    required this.onPressed,
    super.key,
  });

  final String text;
  final TextStyle style;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: onPressed != null,
        label: semanticLabel,
        onTap: onPressed,
        child: ExcludeSemantics(
          child: PressScale(
            scale: .97,
            enabled: onPressed != null,
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                minimumSize:
                    const Size(PantasSize.targetTouch, PantasSize.targetTouch),
                padding: QuestionCount.padding,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor: Colors.transparent,
                shape: const StadiumBorder(),
                foregroundColor: context.colors.textPrimary,
                textStyle: style,
              ),
              child: QuestionCount(text: text, style: style),
            ),
          ),
        ),
      );
}
