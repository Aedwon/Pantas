import 'package:cse_cet_reviewer/core/ui/components/pennant_mark.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// What a cell says about its question.
///
/// A quiz shows outcomes, because the student has already seen them. A mock
/// never does: `answered` is progress, not a judgment.
enum GridCellMark { none, correct, wrong, answered }

class GridCell {
  GridCell({
    required this.number,
    this.mark = GridCellMark.none,
    this.isFlagged = false,
    this.isCurrent = false,
    this.isEnabled = true,
  });

  final int number;
  final GridCellMark mark;
  final bool isFlagged;
  final bool isCurrent;

  /// False for a part that has not opened yet. Dimmed and untappable
  /// rather than hidden: knowing what is coming and how much is left is
  /// what a printed booklet gives you.
  final bool isEnabled;
}

/// Reserved in every cell. Adding the caret only to the current one grows
/// that cell, and grid rows size to their tallest cell, so the whole row
/// grows and everything below shifts.
const double _caretSlot = 7;
const double _markSlot = 11;
const double _cellHeight = 46;

/// The navigator, as a grid rather than a list.
///
/// A sentence says what a question was about. A navigator is scanned for
/// what went badly and how much is left, which a grid answers at a glance.
/// It is also the only shape that survives a mock: 170 items is a
/// hundred-line scroll as sentences and 29 rows as a grid.
class QuestionGridSheet extends StatelessWidget {
  const QuestionGridSheet({
    required this.cells,
    required this.columns,
    required this.onTap,
    super.key,
  });

  final List<GridCell> cells;

  /// Five in a quiz, six in a mock.
  final int columns;

  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final rows = <List<GridCell>>[];
    for (var i = 0; i < cells.length; i += columns) {
      rows.add(
        cells.sublist(
          i,
          i + columns > cells.length ? cells.length : i + columns,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          GridRow(
            cells: row,
            columns: columns,
            isMock: columns == 6,
            onTap: onTap,
          ),
      ],
    );
  }
}

/// Horizontal rule under each row, nothing vertical.
class GridRow extends StatelessWidget {
  const GridRow({
    required this.cells,
    required this.columns,
    required this.isMock,
    required this.onTap,
    super.key,
  });

  final List<GridCell> cells;
  final int columns;
  final bool isMock;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.ruleFaint,
            // ignore: avoid_redundant_argument_values
            width: AppDimensions.hairline,
          ),
        ),
      ),
      child: Row(
        children: [
          for (final cell in cells)
            Expanded(
              child: GridCellView(cell: cell, isMock: isMock, onTap: onTap),
            ),
          // Keeps a short last row aligned with the ones above it.
          for (var i = cells.length; i < columns; i += 1)
            const Expanded(child: SizedBox(height: _cellHeight)),
        ],
      ),
    );
  }
}

class GridCellView extends StatelessWidget {
  const GridCellView({
    required this.cell,
    required this.isMock,
    required this.onTap,
    super.key,
  });

  final GridCell cell;
  final bool isMock;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final isAnswered = cell.mark != GridCellMark.none;

    final numberStyle = styles.bodyMedium.copyWith(
      fontFamily: 'SourceSerif4',
      fontSize: 15,
      fontWeight: isAnswered ? FontWeight.w600 : FontWeight.w400,
      color: isAnswered ? colors.ink : colors.inkMuted,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final cellBody = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _cellHeight),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: _caretSlot,
            child: cell.isCurrent
                ? Center(
                    child: CustomPaint(
                      size: const Size(8, 5),
                      painter: _CaretPainter(colors.ink),
                    ),
                  )
                : null,
          ),
          Text('${cell.number}', style: numberStyle),
          SizedBox(
            height: _markSlot,
            child: _MarkSlot(cell: cell, isMock: isMock),
          ),
        ],
      ),
    );

    if (!cell.isEnabled) {
      return Opacity(opacity: 0.32, child: cellBody);
    }

    return InkWell(onTap: () => onTap(cell.number), child: cellBody);
  }
}

class _MarkSlot extends StatelessWidget {
  const _MarkSlot({required this.cell, required this.isMock});

  final GridCell cell;
  final bool isMock;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (isMock) {
      // Answered is progress and flagged is doubt, and "answered but
      // unsure" is the most common state in a real exam, so both show.
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (cell.mark == GridCellMark.answered)
            Container(
              key: const ValueKey('mock-cell-dot'),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: colors.amber,
                shape: BoxShape.circle,
              ),
            ),
          if (cell.mark == GridCellMark.answered && cell.isFlagged)
            const SizedBox(width: 4),
          if (cell.isFlagged)
            PennantMark(
              isSet: true,
              size: 12,
              color: colors.inkMuted,
              animate: false,
            ),
        ],
      );
    }

    // A tick means you were right, which is a judgment and earns board.
    return switch (cell.mark) {
      GridCellMark.correct => Text(
          '✓',
          style: TextStyle(fontSize: 11, color: colors.board),
        ),
      GridCellMark.wrong => Text(
          '✕',
          style: TextStyle(fontSize: 11, color: colors.rust),
        ),
      GridCellMark.answered || GridCellMark.none => const SizedBox.shrink(),
    };
  }
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CaretPainter oldDelegate) => oldDelegate.color != color;
}
