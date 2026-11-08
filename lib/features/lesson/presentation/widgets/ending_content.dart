import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/ending_reveal.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_ending_layout.dart';

/// Shared layout for the active ending and its inert preview.
class EndingContent extends StatelessWidget {
  const EndingContent({
    required this.ending,
    required this.onLesson,
    required this.onHome,
    this.nextTopic,
    this.nextDetail,
    this.onNext,
    this.held = false,
    super.key,
  });

  /// Whether this is an inert preview rising under a pull. Its reveals hold
  /// at their start, so the real ending reveals once when it takes over.
  final bool held;
  final StudyTopic? nextTopic;
  final String? nextDetail;
  final VoidCallback? onNext;
  final LessonEnding ending;
  final void Function(LessonId) onLesson;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return WebEndingLayout(
        ending: ending,
        onLesson: onLesson,
        onHome: onHome,
        nextTopic: nextTopic,
        nextDetail: nextDetail,
        onNext: onNext,
        held: held,
      );
    }
    if (ending is DayFinished) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s32,
                  PantasSpace.s0,
                  PantasSpace.s32,
                  PantasLayout.reserveBar,
                ),
                child: EndingReveal(
                  held: held,
                  delay: 200,
                  duration: 600,
                  child: Text(
                    "That's enough for today.",
                    textAlign: TextAlign.center,
                    style: PantasType.phoneTitle1
                        .copyWith(color: context.colors.label),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s16,
              PantasSpace.s0,
              PantasSpace.s16,
              PantasSpace.s28,
            ),
            child: TextButton(
              key: const ValueKey('ending-exit'),
              onPressed: onHome,
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 53),
                padding: const EdgeInsets.symmetric(vertical: PantasSpace.s14),
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
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s16,
        PantasSpace.s40,
        PantasSpace.s16,
        PantasSpace.s0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EndingReveal(
            held: held,
            delay: 160,
            duration: 500,
            child: Container(
              key: const ValueKey('ending-plate'),
              padding: const EdgeInsets.symmetric(
                horizontal: PantasSpace.s20,
                vertical: PantasSpace.s24,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(PantasRadius.xl),
                border: Border.all(color: colors.separator, width: .5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: PantasType.phoneTitle1.copyWith(color: colors.label),
                  ),
                  const SizedBox(height: PantasSpace.s6),
                  Text(
                    exam,
                    textAlign: TextAlign.center,
                    style: context.type.footnote.copyWith(
                      color: colors.secondaryLabel,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s14),
                  Container(height: .5, color: colors.separator),
                  const SizedBox(height: PantasSpace.s14),
                  Text(
                    footing,
                    textAlign: TextAlign.center,
                    style: context.type.subhead.copyWith(
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: colors.label,
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s2),
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
            const SizedBox(height: PantasSpace.s28),
            EndingReveal(
              held: held,
              delay: 500,
              duration: 450,
              child: GroupedSection(
                header: 'Still unread',
                children: [
                  for (final lesson in unread)
                    ListRow(
                      title: lesson.title,
                      value: '${lesson.estimatedMinutes} min',
                      leading: const SizedBox(width: PantasSpace.s24),
                      contentPadding:
                          const EdgeInsets.only(right: PantasSpace.s16),
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
}
