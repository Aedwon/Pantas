import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The second line under a lesson title: "Part 2 of 9 · 3 questions" for a
/// split lesson, "5 questions" for an unsplit one. [questions] is the count
/// the lesson's quiz will serve. Null when there is nothing to say.
String? biteLabelText({
  required int? part,
  required int? partCount,
  required int questions,
}) {
  final split = part != null && partCount != null;
  final count = questions == 1 ? '1 question' : '$questions questions';
  if (questions <= 0) return split ? 'Part $part of $partCount' : null;
  return split ? 'Part $part of $partCount · $count' : count;
}

/// The quiz button's words: "Quiz yourself, 3 questions". The count is the one
/// the quiz will serve; until it is known the button says "Quiz yourself".
String quizButtonLabel(int? questions) {
  if (questions == null || questions <= 0) return 'Quiz yourself';
  final count = questions == 1 ? '1 question' : '$questions questions';
  return 'Quiz yourself, $count';
}

/// The list row's secondary text style, for lines that sit beside the label.
TextStyle lessonRowSubStyle(BuildContext context) =>
    (context.wideWeb ? PantasType.webRowSub : PantasType.phoneFootnote)
        .copyWith(color: context.colors.textSecondary);

/// The lesson label lines (bite-sized label board, Option 1): the label, then
/// an optional topic line. It takes the row's own secondary text style and
/// wraps only between words. The label is never cut.
///
/// [questions] is null while the count loads: the line then keeps its height
/// so the row does not jump.
class LessonLabelLines extends StatelessWidget {
  const LessonLabelLines({
    required this.part,
    required this.partCount,
    required this.questions,
    this.style,
    this.topicLine,
    this.topicMaxLines,
    this.prefix,
    this.textAlign,
    super.key,
  });

  final int? part;
  final int? partCount;
  final int? questions;

  /// Defaults to the list row's secondary style.
  final TextStyle? style;

  /// A second line under the label in the same style (the lesson's topic on
  /// search and Home rows: title, label, topic line).
  final String? topicLine;

  /// Cuts the topic line with an ellipsis after this many lines. The label
  /// itself is never cut.
  final int? topicMaxLines;

  /// Text before the label on the same line (the reader header: the topic
  /// name, then a middle dot, then the label). Shown alone when the label has
  /// nothing to say.
  final String? prefix;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = style ?? lessonRowSubStyle(context);
    final count = questions;
    // The part is known without the count; only "K questions" waits.
    final label = count == null
        ? (part != null && partCount != null
            ? 'Part $part of $partCount'
            : null)
        : biteLabelText(part: part, partCount: partCount, questions: count);
    final String? line;
    if (prefix != null) {
      line = label == null ? prefix : '$prefix · $label';
    } else {
      // No-break space: an empty line the same height as a label.
      line = count == null ? ' ' : label;
    }
    if (line == null && topicLine == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (line != null)
          Text(line, style: base, softWrap: true, textAlign: textAlign),
        if (topicLine != null)
          Text(
            topicLine!,
            style: base,
            maxLines: topicMaxLines,
            overflow: topicMaxLines == null ? null : TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
