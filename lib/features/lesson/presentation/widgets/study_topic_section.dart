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
    required this.onToggleTopic,
    this.keyForTopic,
    super.key,
  });

  final StudySubject subject;

  /// Opening a topic is the page's business, not this section's: it has to
  /// hold the tapped row still while the list above it changes height.
  final void Function(TopicId) onToggleTopic;

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
            onTap: () => onToggleTopic(topic.id),
          ),
          // The lessons grow in rather than appearing. A topic that snaps
          // open gives the eye nothing to follow, and the row you tapped is
          // held still while this happens.
          //
          // Height and ink are separated on purpose. Height alone was still
          // abrupt: the rows arrived at full strength the instant there was
          // room for them, so the movement finished before the eye had found
          // what moved. The ink comes up over the back half of the opening,
          // which is what makes it read as unfolding rather than snapping.
          //
          // easeOutQuint over easeOutCubic: it leaves faster and settles
          // slower, so the end of the movement is soft rather than stopped.
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 340),
              curve: Curves.easeOutQuint,
              alignment: Alignment.topCenter,
              child: openTopicId != topic.id
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final lesson in topic.lessons)
                          Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: _FadeIn(
                              child: InkTableRow(
                                title: lesson.title,
                                state: lesson.isRead
                                    ? InkRowState.done
                                    : InkRowState.plain,
                                reserveGlyph: true,
                                meta: '${lesson.estimatedMinutes} min',
                                chevron: InkRowChevron.link,
                                onTap: () => context
                                    .push('/lesson/${lesson.id}?from=study'),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Brings its child up in ink once there is room for it.
///
/// Starts after the opening is underway rather than with it, so the height
/// and the ink are not the same gesture told twice.
class _FadeIn extends StatefulWidget {
  const _FadeIn({required this.child});

  final Widget child;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 340),
    vsync: this,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 1, curve: Curves.easeOut),
      ),
      child: widget.child,
    );
  }
}
