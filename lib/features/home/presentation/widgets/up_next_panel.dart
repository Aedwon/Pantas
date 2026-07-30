import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/up_next_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "Algebra, Geometry and Chemistry today. About 28 minutes."
///
/// "About" is the content's hedge, not the app's: estimatedMinutes is an
/// authored field. Elsewhere on Home the app states figures it knows
/// exactly and does not hedge them.
@visibleForTesting
String leadSentence(List<UpNextLesson> lessons) {
  final subjects = <String>[];
  for (final lesson in lessons) {
    if (!subjects.contains(lesson.subjectName)) {
      subjects.add(lesson.subjectName);
    }
  }
  final minutes = lessons.fold<int>(0, (sum, l) => sum + l.estimatedMinutes);
  final unit = minutes == 1 ? 'minute' : 'minutes';
  return '${_join(subjects)} today. About $minutes $unit.';
}

String _join(List<String> parts) {
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.single;
  return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
}

class UpNextPanel extends ConsumerWidget {
  const UpNextPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDay = ref.watch(upNextProvider);
    final styles = context.textStyles;
    final colors = context.colors;

    return asyncDay.when(
      loading: () => RuledPanel(
        heading: 'Up next',
        action: 'See all',
        onAction: () => context.go('/study'),
        child: const FaintBars(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (day) {
        if (day.lessons.isEmpty) {
          if (day.allReadInWeakTopics) {
            return RuledPanel(
              heading: 'Up next',
              action: 'See all',
              onAction: () => context.go('/study'),
              child: Text(
                'Nothing left to read in your weak topics.',
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final lead = leadSentence(day.lessons);

        return RuledPanel(
          heading: 'Up next',
          action: 'See all',
          onAction: () => context.go('/study'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lead,
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < day.lessons.length; i++)
                InkTableRow(
                  title: day.lessons[i].title,
                  meta: '${day.lessons[i].estimatedMinutes} min',
                  bottomRule: i < day.lessons.length - 1,
                  onTap: () =>
                      context.push('/lesson/${day.lessons[i].lessonId}'),
                ),
              const SizedBox(height: 16),
              BoardButton(
                label: 'Continue lesson',
                onPressed: () =>
                    context.push('/lesson/${day.lessons.first.lessonId}'),
              ),
            ],
          ),
        );
      },
    );
  }
}
