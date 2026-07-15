import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/progress/application/table_order_prefs.dart';
import 'package:flutter/material.dart';

/// The table's head, which is also its only sort control.
///
/// The labels that sort are the labels that name the data, so no separate
/// control exists. Do not add a dropdown, a chip row or an icon button.
class TableHead extends StatelessWidget {
  const TableHead({
    required this.rowNoun,
    required this.showTime,
    required this.sortKey,
    required this.direction,
    required this.onSort,
    super.key,
  });

  /// What the rows are: `Subject`, `Topic` or `Lesson`. A label, never a
  /// control: filtering four subjects down to one is not a thing anyone
  /// wants, and sorting by name is not a question a student asks.
  final String rowNoun;

  /// False until a full length mock has been sat. The Time head is then
  /// absent, not dimmed and not disabled.
  final bool showTime;

  final TableSortKey sortKey;
  final TableSortDirection direction;
  final ValueChanged<TableSortKey> onSort;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.only(bottom: 6),
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
          Expanded(child: _HeadLabel(rowNoun.toUpperCase())),
          _SortCell(
            label: 'SCORE',
            isActive: sortKey == TableSortKey.score,
            direction: direction,
            onTap: () => onSort(TableSortKey.score),
          ),
          if (showTime)
            _SortCell(
              label: 'TIME',
              isActive: sortKey == TableSortKey.time,
              direction: direction,
              onTap: () => onSort(TableSortKey.time),
            ),
        ],
      ),
    );
  }
}

class _HeadLabel extends StatelessWidget {
  const _HeadLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: headStyle(context));
  }
}

/// 11px uppercase in `inkMuted`, shared by the head cells and the scope
/// control so the row reads as one line.
TextStyle headStyle(BuildContext context) => context.textStyles.labelSmall
    .copyWith(color: context.colors.inkMuted, letterSpacing: 0.5);

class _SortCell extends StatelessWidget {
  const _SortCell({
    required this.label,
    required this.isActive,
    required this.direction,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final TableSortDirection direction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        // The figure columns beneath are 52 wide. The head matches them
        // and grows rather than clipping if a label ever needs more.
        constraints: const BoxConstraints(minWidth: 52),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isActive) ...[
              SortCaret(
                key: const ValueKey('sort-caret'),
                direction: direction,
              ),
              const SizedBox(width: 4),
            ],
            Text(label, style: headStyle(context)),
          ],
        ),
      ),
    );
  }
}

/// A 7px solid triangle, drawn only beside the active head.
class SortCaret extends StatelessWidget {
  const SortCaret({required this.direction, super.key});

  final TableSortDirection direction;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(7, 7),
      painter: _CaretPainter(
        color: context.colors.ink,
        pointsUp: direction == TableSortDirection.ascending,
      ),
    );
  }
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter({required this.color, required this.pointsUp});

  final Color color;
  final bool pointsUp;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (pointsUp) {
      path
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CaretPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointsUp != pointsUp;
}
