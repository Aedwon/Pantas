import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/task_status.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

import '../../../helpers/ds_matrix.dart';

void main() {
  dsMatrix(
    'task status: four shapes, 26 wide and 24 phone, hidden text',
    (context) => const Wrap(
      spacing: 8,
      children: [
        TaskStatus(state: TaskState.todo),
        TaskStatus(state: TaskState.partial),
        TaskStatus(state: TaskState.current),
        TaskStatus(state: TaskState.done),
      ],
    ),
    check: (tester, cell) async {
      final palette = cell.dark ? PantasColors.dark : PantasColors.light;
      final side = cell.width >= 1024 ? 26.0 : 24.0;
      for (final state in TaskState.values) {
        expect(
          tester
              .getSize(
                find.byWidgetPredicate(
                  (w) => w is TaskStatus && w.state == state,
                ),
              )
              .width,
          side,
        );
      }
      BoxDecoration deco(String key) =>
          tester.widget<DecoratedBox>(find.byKey(ValueKey(key))).decoration
              as BoxDecoration;
      // Not started: a 1.5 px border-control ring and no fill.
      expect(deco('task-todo').border!.top.width, 1.5);
      expect(deco('task-todo').border!.top.color, palette.borderControl);
      expect(deco('task-todo').color, isNull);
      // Up next: a 2 px accent ring on surface-card.
      expect(deco('task-current').border!.top.width, 2);
      expect(deco('task-current').border!.top.color, palette.accent);
      expect(deco('task-current').color, palette.surfaceCard);
      // Done: an accent-fill disc.
      expect(deco('task-done').color, palette.accentFill);
      // Half done reuses the ring with a border-control track.
      expect(find.byKey(const ValueKey('task-partial')), findsOneWidget);
      expect(find.byType(ProgressRing), findsOneWidget);
      for (final label in ['Not started', 'Half done', 'Up next', 'Done']) {
        expect(find.bySemanticsLabel(label), findsOneWidget);
      }
    },
  );
}
