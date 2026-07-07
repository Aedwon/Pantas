import 'package:cse_cet_reviewer/core/ui/components/ink_chevron.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/lesson/application/study_map_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The open topic, held under the app bar while its own row is off screen.
///
/// Deliberately not a sticky header: a sticky header unpins the moment its
/// section scrolls away, which is the moment this bar is for. It works only
/// because one topic is open at a time, so there is never a stack of them.
class PinnedTopicBar extends ConsumerWidget {
  const PinnedTopicBar({
    required this.topic,
    required this.onScrollBack,
    super.key,
  });

  final StudyTopic topic;
  final VoidCallback onScrollBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(
            color: colors.rule,
            // ignore: avoid_redundant_argument_values
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onScrollBack,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'open',
                      style: styles.bodySmall
                          .copyWith(fontSize: 11, color: colors.inkMuted),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topic.name,
                        style: styles.bodyMedium.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${topic.readCount} / ${topic.totalCount}',
                      style: styles.bodySmall.copyWith(
                        color: colors.inkMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            key: const ValueKey('pinned-topic-collapse'),
            onTap: () => ref.read(openTopicProvider.notifier).close(),
            child: const SizedBox(
              width: AppDimensions.minTapTarget,
              height: AppDimensions.minTapTarget,
              child: Center(child: InkChevron(pointsDown: true)),
            ),
          ),
        ],
      ),
    );
  }
}
