import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/lesson_label.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';

/// The lesson label under a title: "Part 2 of 9 · 3 questions", or
/// "5 questions" for a lesson that is not split. The count comes only from
/// [lessonQuizCountProvider], the number the lesson's quiz will serve. Lives
/// beside the provider so Study, Home and search can all use it.
class LessonBiteLabel extends ConsumerWidget {
  const LessonBiteLabel({
    required this.lessonId,
    required this.part,
    required this.partCount,
    this.style,
    this.topicLine,
    this.topicMaxLines,
    this.prefix,
    this.textAlign,
    super.key,
  });

  final LessonId lessonId;
  final int? part;
  final int? partCount;
  final TextStyle? style;
  final String? topicLine;
  final int? topicMaxLines;
  final String? prefix;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LessonLabelLines(
        part: part,
        partCount: partCount,
        questions: ref.watch(lessonQuizCountProvider(lessonId)).valueOrNull,
        style: style,
        topicLine: topicLine,
        topicMaxLines: topicMaxLines,
        prefix: prefix,
        textAlign: textAlign,
      );
}
