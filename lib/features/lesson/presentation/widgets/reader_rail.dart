import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';

/// Scroll progress stays per lesson; the visible day line spans its real order.
class ReaderRail extends StatelessWidget {
  const ReaderRail({required this.progress, this.dayContext, super.key});
  final double progress;
  final LessonDayContext? dayContext;

  @override
  Widget build(BuildContext context) {
    final fraction = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);
    final day = dayContext;
    final fill =
        day == null ? fraction : (day.index + fraction) / day.lessonIds.length;
    final colors = context.colors;
    return SizedBox(
      height: 3,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          clipBehavior: Clip.none,
          children: [
            ColoredBox(
              color: colors.fill,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fill,
                  child: ColoredBox(
                    key: const ValueKey('reader-progress-fill'),
                    color: colors.accentFill,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            if (day != null)
              for (var index = 1; index < day.lessonIds.length; index++)
                Positioned(
                  key: ValueKey('reader-day-tick-$index'),
                  left:
                      constraints.maxWidth * index / day.lessonIds.length - .5,
                  top: -1,
                  width: 1,
                  height: 5,
                  child: ColoredBox(color: colors.label),
                ),
          ],
        ),
      ),
    );
  }
}
