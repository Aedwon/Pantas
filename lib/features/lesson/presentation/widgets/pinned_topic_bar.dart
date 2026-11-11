import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_tap.dart';

class PinnedTopicBar extends StatelessWidget {
  const PinnedTopicBar({required this.topic, required this.onClose, super.key});
  final StudyTopic topic;
  final VoidCallback onClose;
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: context.colors.background,
        child: Semantics(
          label: 'Close ${topic.name}',
          expanded: true,
          child: ReaderTap(
            key: const ValueKey('pinned-topic-collapse'),
            onTap: onClose,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 47),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s16,
                  vertical: PantasSpace.s12,
                ),
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
                    const SizedBox(width: PantasSpace.s12),
                    Expanded(
                      child: Text(
                        topic.name,
                        style: context.type.emphasized,
                      ),
                    ),
                    const SizedBox(width: PantasSpace.s8),
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
