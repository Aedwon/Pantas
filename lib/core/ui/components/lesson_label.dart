import 'package:flutter/widgets.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The quiz button's words: "Quiz yourself, 3 questions". The count is the one
/// the quiz will serve; until it is known the button says "Quiz yourself".
///
/// Lesson rows carry no part or question-count label (Aedwon, Nov 23: the
/// "Part 2 of 9 · 3 questions" line is noise for a learner). The part data
/// stays in the models; only this button shows a count.
String quizButtonLabel(int? questions) {
  if (questions == null || questions <= 0) return 'Quiz yourself';
  final count = questions == 1 ? '1 question' : '$questions questions';
  return 'Quiz yourself, $count';
}

/// The list row's secondary text style, for lines that sit under a title.
TextStyle lessonRowSubStyle(BuildContext context) =>
    (context.wideWeb ? PantasType.webRowSub : PantasType.phoneFootnote)
        .copyWith(color: context.colors.textSecondary);

/// A lesson row's footer: the lesson's topic line, or nothing. Null when
/// [topic] is null, so a row with no topic is one line, as the boards draw it.
Widget? lessonTopicFooter(
  BuildContext context,
  String? topic, {
  int? maxLines,
  TextStyle? style,
}) =>
    topic == null
        ? null
        : Text(
            topic,
            style: style ?? lessonRowSubStyle(context),
            maxLines: maxLines,
            overflow: maxLines == null ? null : TextOverflow.ellipsis,
          );
