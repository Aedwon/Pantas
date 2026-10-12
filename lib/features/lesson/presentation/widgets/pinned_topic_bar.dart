import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';

class PinnedTopicBar extends StatelessWidget {
  const PinnedTopicBar({required this.topic, required this.onClose, super.key});
  final StudyTopic topic;
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) => Material(
        color: context.colors.background,
        child: Semantics(
          button: true,
          label: 'Close ${topic.name}',
          expanded: true,
          child: InkWell(
            key: const ValueKey('pinned-topic-collapse'),
            onTap: onClose,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 47),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 11.5),
                child: Row(
                  children: [
                    if (topic.isComplete)
                      const CheckMark()
                    else
                      ProgressRing.study(
                        fraction: topic.totalCount == 0
                            ? 0
                            : topic.readCount / topic.totalCount,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        topic.name,
                        style: context.type.emphasized,
                      ),
                    ),
                    const SizedBox(width: 8),
                    RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        PantasIcons.next,
                        size: 14,
                        color: context.colors.chevron,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
