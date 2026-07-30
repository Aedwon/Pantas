import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/domain/use_cases/decide_ending.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookplate.dart';
import 'package:pantas/features/lesson/presentation/widgets/next_topic_block.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TopicEndingPage extends ConsumerWidget {
  const TopicEndingPage({
    required this.topicId,
    this.ending,
    super.key,
  });

  final TopicId topicId;
  final LessonEnding? ending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    if (ending != null) {
      return _TopicEndingView(ending: ending!);
    }

    final asyncMap = ref.watch(studyMapProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: asyncMap.when(
        loading: () => const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: FaintBars(),
          ),
        ),
        error: (e, _) => SafeArea(
          child: Center(
            child: Text(
              'Failed to load topic ending.',
              style: textStyles.bodyMedium.copyWith(color: colors.inkMuted),
            ),
          ),
        ),
        data: (map) {
          if (map == null) {
            return SafeArea(
              child: Center(
                child: Text(
                  'Study map unavailable.',
                  style: textStyles.bodyMedium.copyWith(color: colors.inkMuted),
                ),
              ),
            );
          }

          StudyTopic? topic;
          StudySubject? subject;
          StudyTopic? nextTopic;

          for (var sIdx = 0; sIdx < map.subjects.length; sIdx++) {
            final s = map.subjects[sIdx];
            for (var tIdx = 0; tIdx < s.topics.length; tIdx++) {
              final t = s.topics[tIdx];
              if (t.id == topicId) {
                topic = t;
                subject = s;
                if (tIdx + 1 < s.topics.length) {
                  nextTopic = s.topics[tIdx + 1];
                } else if (sIdx + 1 < map.subjects.length &&
                    map.subjects[sIdx + 1].topics.isNotEmpty) {
                  nextTopic = map.subjects[sIdx + 1].topics.first;
                }
                break;
              }
            }
            if (topic != null) break;
          }

          if (topic == null || subject == null) {
            return SafeArea(
              child: Center(
                child: Text(
                  'Topic not found.',
                  style: textStyles.bodyMedium.copyWith(color: colors.inkMuted),
                ),
              ),
            );
          }

          final user = ref.watch(currentUserProvider).valueOrNull;
          final studentName = user?.displayName;

          final computedEnding = decideEnding(
            topic: topic,
            subject: subject,
            examShortName: map.examShortName,
            studentName: studentName,
            today: DateTime.now(),
            nextTopic: nextTopic,
          );

          return _TopicEndingView(ending: computedEnding);
        },
      ),
    );
  }
}

class _TopicEndingView extends StatelessWidget {
  const _TopicEndingView({required this.ending});

  final LessonEnding ending;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/study');
                  }
                },
              ),
            ),
            const ReaderRail(progress: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: switch (ending) {
                  TopicFinished(
                    :final studentName,
                    :final topicName,
                    :final examAndSubject,
                    :final footing,
                    :final dateLine,
                    :final next,
                    :final nextTopicMeta
                  ) =>
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Bookplate(
                          studentName: studentName,
                          topicName: topicName,
                          examAndSubject: examAndSubject,
                          footing: footing,
                          dateLine: dateLine,
                        ),
                        if (next != null && nextTopicMeta != null) ...[
                          const SizedBox(height: 24),
                          NextTopicBlock(
                            topic: next,
                            meta: nextTopicMeta,
                            onTap: () =>
                                context.go('/study?topicId=${next.id}'),
                          ),
                        ],
                      ],
                    ),
                  TopicStoppedShort(
                    :final studentName,
                    :final topicName,
                    :final examAndSubject,
                    :final footing,
                    :final dateLine,
                    :final unread
                  ) =>
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Bookplate(
                          studentName: studentName,
                          topicName: topicName,
                          examAndSubject: examAndSubject,
                          footing: footing,
                          dateLine: dateLine,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Still unread',
                          style: textStyles.captionSmall.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final lesson in unread)
                          InkTableRow(
                            title: lesson.title,
                            meta: '${lesson.estimatedMinutes} min',
                            chevron: InkRowChevron.link,
                            onTap: () => context.go('/lesson/${lesson.id}'),
                          ),
                      ],
                    ),
                  DayFinished() => Column(
                      children: [
                        const SizedBox(height: 26),
                        Text(
                          "That's enough for today.",
                          textAlign: TextAlign.center,
                          style: textStyles.displaySmall.copyWith(
                            letterSpacing: -0.2,
                            color: colors.ink,
                          ),
                        ),
                      ],
                    ),
                },
              ),
            ),
            InkWell(
              key: const ValueKey('ending-exit'),
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/study');
                }
              },
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colors.ruleFaint,
                      // ignore: avoid_redundant_argument_values
                      width: AppDimensions.hairline,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Back to Study',
                  style: textStyles.labelLarge.copyWith(
                    color: colors.board,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
