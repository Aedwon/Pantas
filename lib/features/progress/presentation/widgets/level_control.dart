import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';

/// Subject, Topic, Lesson, separated by rule ticks. No pills, and nothing
/// hidden behind a picker.
class LevelControl extends StatelessWidget {
  const LevelControl({
    required this.level,
    required this.isPro,
    required this.lessonAvailable,
    required this.onChanged,
    required this.onLocked,
    super.key,
  });

  final TableLevel level;

  /// Free is fixed at Subject and sees the other labels dimmed rather than
  /// hidden, so it knows what Pro opens.
  final bool isPro;

  /// Lesson is absent, not dimmed, until questions carry a lesson. The two
  /// states carry different promises: dimmed says pay for this, absent says
  /// this does not exist yet, and selling the first when the second is true
  /// is a promise the app cannot keep.
  final bool lessonAvailable;

  final ValueChanged<TableLevel> onChanged;
  final VoidCallback onLocked;

  @override
  Widget build(BuildContext context) {
    final levels = [
      TableLevel.subject,
      TableLevel.topic,
      if (lessonAvailable) TableLevel.lesson,
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < levels.length; i += 1) ...[
          if (i > 0) _Tick(),
          _LevelLabel(
            label: _labelFor(levels[i]),
            isActive: levels[i] == level,
            isLocked: !isPro && levels[i] != TableLevel.subject,
            onTap: () {
              if (!isPro && levels[i] != TableLevel.subject) {
                onLocked();
                return;
              }
              onChanged(levels[i]);
            },
          ),
        ],
      ],
    );
  }

  String _labelFor(TableLevel level) => switch (level) {
        TableLevel.subject => 'Subject',
        TableLevel.topic => 'Topic',
        TableLevel.lesson => 'Lesson',
      };
}

class _Tick extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 11,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: context.colors.rule,
    );
  }
}

class _LevelLabel extends StatelessWidget {
  const _LevelLabel({
    required this.label,
    required this.isActive,
    required this.isLocked,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final semanticsLabel = isLocked ? '$label, Pro only' : label;

    return Semantics(
      container: true,
      button: true,
      enabled: true,
      selected: isActive,
      label: semanticsLabel,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        excludeFromSemantics: true,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          child: Center(
            child: Text(
              label,
              style: styles.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive && !isLocked ? colors.ink : colors.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
