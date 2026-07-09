import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/lesson/application/study_map_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A subject heading over its topic rows. A topic expands in place rather than
/// navigating: the topic page is gone.
class StudySubjectSection extends ConsumerWidget {
  const StudySubjectSection({
    required this.subject,
    this.keyForTopic,
    super.key,
  });

  final StudySubject subject;
  final GlobalKey Function(TopicId)? keyForTopic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final styles = context.textStyles;
    final openTopicId = ref.watch(openTopicProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.rule,
                // ignore: avoid_redundant_argument_values
                width: AppDimensions.hairline,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text(subject.name, style: styles.headlineSmall)),
              Text(
                '${subject.readCount} / ${subject.totalCount}',
                style: styles.bodySmall.copyWith(
                  color: colors.inkMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        for (final topic in subject.topics) ...[
          InkTableRow(
            key: keyForTopic?.call(topic.id),
            title: topic.name,
            state: topic.isComplete ? InkRowState.done : InkRowState.plain,
            reserveGlyph: true,
            meta: '${topic.readCount} / ${topic.totalCount}',
            chevron: InkRowChevron.disclosure,
            expanded: openTopicId == topic.id,
            onTap: () => ref.read(openTopicProvider.notifier).toggle(topic.id),
          ),
          if (openTopicId == topic.id)
            for (final lesson in topic.lessons)
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: InkTableRow(
                  title: lesson.title,
                  state: lesson.isRead ? InkRowState.done : InkRowState.plain,
                  reserveGlyph: true,
                  meta: '${lesson.estimatedMinutes} min',
                  chevron: InkRowChevron.link,
                  onTap: () => context.push('/lesson/${lesson.id}?from=study'),
                ),
              ),
        ],
      ],
    );
  }
}
