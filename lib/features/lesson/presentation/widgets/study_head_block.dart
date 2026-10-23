import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_map_entry.dart';

class StudyHeadBlock extends ConsumerWidget {
  const StudyHeadBlock({required this.map, super.key});
  final StudyMap map;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(lastOpenedLessonProvider);
    return value.when(
      loading: () => loadingFor(value),
      error: (error, _) => errorFor(
        'last lesson',
        () => ref.invalidate(lastOpenedLessonProvider),
        error: error,
      ),
      data: (lesson) {
        if (lesson == null) return const SizedBox.shrink();
        String? topicName;
        for (final subject in map.subjects) {
          for (final topic in subject.topics) {
            if (topic.id == lesson.topicId) topicName = topic.name;
          }
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: StudyMapEntry(
            delay: const Duration(milliseconds: 180),
            child: GroupedSection(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('LAST OPENED', style: context.type.sectionHeader),
                      const SizedBox(height: 2),
                      Text(
                        lesson.title,
                        style: context.type.sectionHero
                            .copyWith(fontSize: 22, letterSpacing: -.264),
                      ),
                      if (topicName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          topicName,
                          style: context.type.subhead
                              .copyWith(color: context.colors.secondaryLabel),
                        ),
                      ],
                      const SizedBox(height: 12),
                      PantasButton(
                        label: 'Resume',
                        onPressed: () => context.push(
                          '/lesson/${lesson.id}?from=study&resume=true',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
