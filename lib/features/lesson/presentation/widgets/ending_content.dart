import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';

/// Shared layout for the active ending and its inert preview.
class EndingContent extends StatelessWidget {
  const EndingContent({
    required this.ending,
    required this.onLesson,
    required this.onHome,
    super.key,
  });

  final LessonEnding ending;
  final void Function(LessonId) onLesson;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    if (ending is DayFinished) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 120),
                child: _reveal(
                  context,
                  delay: 200,
                  duration: 600,
                  child: Text(
                    "That's enough for today.",
                    textAlign: TextAlign.center,
                    style: context.type.pageTitle.copyWith(
                      fontSize: 26,
                      height: 1.35,
                      letterSpacing: -.312,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            child: TextButton(
              key: const ValueKey('ending-exit'),
              onPressed: onHome,
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 53),
                padding: const EdgeInsets.symmetric(vertical: 15),
                foregroundColor: context.colors.accent,
              ),
              child: Text('Back to Home', style: context.type.emphasized),
            ),
          ),
        ],
      );
    }

    final (name, exam, footing, date, unread) = switch (ending) {
      TopicFinished(
        :final topicName,
        :final examAndSubject,
        :final footing,
        :final dateLine
      ) =>
        (topicName, examAndSubject, footing, dateLine, const <StudyLesson>[]),
      TopicStoppedShort(
        :final topicName,
        :final examAndSubject,
        :final footing,
        :final dateLine,
        :final unread
      ) =>
        (topicName, examAndSubject, footing, dateLine, unread),
      DayFinished() => throw StateError('Day ending handled above.'),
    };
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _reveal(
            context,
            delay: 160,
            duration: 500,
            child: Container(
              key: const ValueKey('ending-plate'),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.separator, width: .5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: context.type.pageTitle.copyWith(
                      fontSize: 31,
                      height: 1.12,
                      letterSpacing: -.682,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exam,
                    textAlign: TextAlign.center,
                    style: context.type.footnote.copyWith(
                      color: colors.secondaryLabel,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(height: .5, color: colors.separator),
                  const SizedBox(height: 14),
                  Text(
                    footing,
                    textAlign: TextAlign.center,
                    style: context.type.subhead.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: colors.label,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    textAlign: TextAlign.center,
                    style: context.type.footnote
                        .copyWith(color: colors.secondaryLabel),
                  ),
                ],
              ),
            ),
          ),
          if (unread.isNotEmpty) ...[
            const SizedBox(height: 28),
            _reveal(
              context,
              delay: 500,
              duration: 450,
              child: GroupedSection(
                header: 'Still unread',
                children: [
                  for (final lesson in unread)
                    ListRow(
                      title: lesson.title,
                      value: '${lesson.estimatedMinutes} min',
                      leading: const SizedBox(width: 24),
                      contentPadding: const EdgeInsets.only(right: 16),
                      verticalPadding: 12,
                      onTap: () => onLesson(lesson.id),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _reveal(
    BuildContext context, {
    required int delay,
    required int duration,
    required Widget child,
  }) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: delay + duration),
      curve:
          Interval(delay / (delay + duration), 1, curve: PantasCurves.houseOut),
      child: child,
      builder: (_, value, child) => Transform.translate(
        offset: Offset(0, 8 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
    );
  }
}
