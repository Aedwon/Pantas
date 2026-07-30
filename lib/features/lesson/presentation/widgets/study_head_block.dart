import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/lesson.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/exam_name_line.dart';
import 'package:pantas/core/ui/components/stats_band.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';

/// The exam name, the two figures, and the row that offers to resume.
class StudyHeadBlock extends ConsumerWidget {
  const StudyHeadBlock({required this.map, super.key});

  final StudyMap map;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastOpened = ref.watch(lastOpenedLessonProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExamNameLine(map.examShortName),
        StatsBand(
          figures: [
            StatFigure(
              value: '${map.coveredPercent}',
              suffix: '%',
              label: 'covered',
            ),
            StatFigure(
              value: _remainingValue(map.minutesLeftToRead),
              suffix: _remainingSuffix(map.minutesLeftToRead),
              // Describes the material, not the student. Nothing records how
              // long anyone actually read.
              label: 'left to read',
            ),
          ],
        ),
        if (lastOpened != null) _ResumeRow(lesson: lastOpened),
      ],
    );
  }

  /// Whole hours once there is an hour to report, minutes below that. "0h"
  /// would be the honest rounding and a useless thing to print.
  static String _remainingValue(int minutes) =>
      minutes >= 60 ? '${minutes ~/ 60}' : '$minutes';

  static String _remainingSuffix(int minutes) => minutes >= 60 ? 'h' : 'm';
}

class _ResumeRow extends StatelessWidget {
  const _ResumeRow({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last opened',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
                Text(
                  lesson.title,
                  style: styles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IntrinsicWidth(
            child: BoardButton(
              label: 'Resume',
              onPressed: () => context.push('/lesson/${lesson.id}?from=study'),
            ),
          ),
        ],
      ),
    );
  }
}
