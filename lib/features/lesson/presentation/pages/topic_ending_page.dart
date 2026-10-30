import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_ending.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/ending_content.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_rail.dart';

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
            child: SkeletonGroups(groups: 1, rows: 4, rowHeight: 63),
          ),
        ),
        error: (e, _) => SafeArea(
          child: Center(
            child: Text(
              'Failed to load topic ending.',
              style: context.type.body.copyWith(color: colors.secondaryLabel),
            ),
          ),
        ),
        data: (map) {
          if (map == null) {
            return SafeArea(
              child: Center(
                child: Text(
                  'Study map unavailable.',
                  style:
                      context.type.body.copyWith(color: colors.secondaryLabel),
                ),
              ),
            );
          }

          StudyTopic? topic;

          for (var sIdx = 0; sIdx < map.subjects.length; sIdx++) {
            final s = map.subjects[sIdx];
            for (var tIdx = 0; tIdx < s.topics.length; tIdx++) {
              final t = s.topics[tIdx];
              if (t.id == topicId) {
                topic = t;
                break;
              }
            }
            if (topic != null) break;
          }

          if (topic == null) {
            return SafeArea(
              child: Center(
                child: Text(
                  'Topic not found.',
                  style:
                      context.type.body.copyWith(color: colors.secondaryLabel),
                ),
              ),
            );
          }

          if (topic.lessons.isEmpty) {
            return const SafeArea(
              child: Center(child: Text('Topic not found.')),
            );
          }
          return LessonPage(
            key: ValueKey('topic-ending-${topic.id}'),
            lessonId: topic.lessons.last.id,
            initialEnding: true,
          );
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
    final day = ending is DayFinished;
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            ReaderBar.ending(
              origin: day ? ReaderOrigin.home : ReaderOrigin.study,
              onBack: day ? () => context.go('/home') : null,
            ),
            const ReaderRail(progress: 1),
            Expanded(
              child: EndingContent(
                ending: ending,
                onLesson: (id) => context.push('/lesson/$id?from=study'),
                onHome: () => context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
