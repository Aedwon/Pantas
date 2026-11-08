import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

enum TaskState { todo, partial, current, done }

/// The round marker at the start of a plan row (design system TaskStatus):
/// done, half done, up next or not started. 26 px on wide screens, 24 px on a
/// phone. The four shapes differ (empty ring, partial arc, thick ring, check),
/// so color is never the only cue, and each carries its state as hidden text.
///
/// The marker has no hover, pressed or disabled state: the row around it takes
/// them.
class TaskStatus extends StatelessWidget {
  const TaskStatus({
    required this.state,
    this.fraction = .5,
    this.phone,
    this.semanticLabel,
    this.animate = true,
    super.key,
  });

  final TaskState state;

  /// The arc of a [TaskState.partial] marker, 0 to 1.
  final double fraction;

  /// Forces the 24 px phone size (true) or the 26 px wide size (false); by
  /// default the layout decides.
  final bool? phone;

  /// The hidden text; defaults to "Done", "Half done", "Up next" or
  /// "Not started".
  final String? semanticLabel;

  /// False for a marker drawn for something already shown (a list laid out
  /// again): it stands complete at once.
  final bool animate;

  static String defaultLabel(TaskState state) => switch (state) {
        TaskState.done => 'Done',
        TaskState.partial => 'Half done',
        TaskState.current => 'Up next',
        TaskState.todo => 'Not started',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPhone = phone ?? !context.wideWeb;
    final size = isPhone ? PantasSize.check : PantasSize.task;
    final marker = switch (state) {
      TaskState.todo => DecoratedBox(
          key: const ValueKey('task-todo'),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.borderControl,
              width: PantasBorder.ringStrong,
            ),
          ),
        ),
      TaskState.current => DecoratedBox(
          key: const ValueKey('task-current'),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surfaceCard,
            border: Border.all(
              color: colors.accent,
              width: PantasBorder.ringSelected,
            ),
          ),
        ),
      TaskState.partial => ProgressRing.study(
          key: const ValueKey('task-partial'),
          fraction: fraction,
          size: size,
          animateIn: animate,
          trackColor: colors.borderControl,
          trackWidth: PantasBorder.ringStrong,
        ),
      TaskState.done => DecoratedBox(
          key: const ValueKey('task-done'),
          decoration: BoxDecoration(
            color: colors.accentFill,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CheckMark.glyph(
              size: PantasSize.check / 2 + PantasBorder.ring,
              color: colors.onAccent,
              animate: animate,
            ),
          ),
        ),
    };
    return Semantics(
      label: semanticLabel ?? defaultLabel(state),
      excludeSemantics: true,
      child: SizedBox.square(dimension: size, child: marker),
    );
  }
}
