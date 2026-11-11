import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// Phosphor caret-down (the sort chevron).
const IconData _caretDown = IconData(0xe136, fontFamily: 'Phosphor');

/// One column of a [PantasDataTable].
@immutable
class PantasTableColumn {
  const PantasTableColumn(
    this.label, {
    this.numeric = false,
    this.sortable = false,
  });

  /// The header text. The table draws it uppercase.
  final String label;

  /// A number column: right-aligned, tabular figures, no wrap.
  final bool numeric;

  /// The header holds a sort button.
  final bool sortable;
}

/// A cell that holds a widget (a ProMark, a bar) in place of text.
///
/// The table cannot measure a widget, so the caller gives its [width], the
/// space it needs inside the cell. [semanticLabel] is what a screen reader
/// says for the cell.
@immutable
class PantasTableCell {
  const PantasTableCell.widget(
    Widget this.child, {
    required double this.width,
    this.semanticLabel,
  })  : text = null,
        subtitle = null,
        bold = false,
        indent = 0;

  /// A text cell that is bold (600) or set in from the left by [indent], such
  /// as a topic under its subject. The table measures and wraps it like plain
  /// text.
  const PantasTableCell.text(
    String this.text, {
    this.bold = false,
    this.indent = 0,
    this.subtitle,
  })  : child = null,
        width = null,
        semanticLabel = null;

  final Widget? child;
  final double? width;
  final String? text;

  /// A second line under [text] in `text-secondary` (a subject's topic count).
  final String? subtitle;
  final bool bold;
  final double indent;
  final String? semanticLabel;
}

/// Lays out results in rows and columns (design system DataTable): Record
/// (past mocks) and Performance (subject and topic breakdown).
///
/// A `surface-card` well with `radius-xl` and a 1px `edge-card` ring. The first
/// column is pinned (and is the row header); the other columns scroll sideways
/// inside the card. Header cells are `web-eyebrow` in `text-secondary`; body
/// cells are `web-row-value`, at least 44 high, with `divider` hairlines
/// between rows. A `null` cell reads "No data" in `text-secondary`, never
/// "0%". Rows are one line, so the pinned column lines up with the rest.
///
/// A cell is a `String`, `null` (no data) or a [PantasTableCell] holding a
/// widget. With [onRowTap] a row is one button: the first cell takes focus and
/// Enter or Space, and a tap on any cell of the row reports it.
///
/// Sorting is the caller's: a sortable header calls [onSort] with its column;
/// the table shows [sortColumn] and [sortAscending] and announces the order.
class PantasDataTable extends StatefulWidget {
  const PantasDataTable({
    required this.columns,
    required this.rows,
    this.caption,
    this.sortColumn,
    this.sortAscending = true,
    this.onSort,
    this.emptyCell = 'No data',
    this.onRowTap,
    this.selectedRow,
    this.childRows,
    this.expandedRows = const {},
    this.onChildTap,
    this.selectedChild,
    super.key,
  }) : assert(columns.length > 0, 'A table needs a column.');

  final List<PantasTableColumn> columns;

  /// The rows: one cell per column. A cell is text, a [PantasTableCell], or
  /// `null` for no data.
  final List<List<Object?>> rows;

  /// Makes each row a button; called with the row's index.
  final ValueChanged<int>? onRowTap;

  /// A row kept tinted, such as the one whose panel is open.
  final int? selectedRow;

  /// Child rows by parent row index. A parent in [expandedRows] shows its
  /// children right under it, opening over 240 ms and closing the same way
  /// (at once with reduced motion). Pass the children of every parent, open
  /// or not, so the columns keep one width. Children sit on `surface-inset`.
  final Map<int, List<List<Object?>>>? childRows;
  final Set<int> expandedRows;

  /// Called with the parent row and the child row.
  final void Function(int row, int child)? onChildTap;

  /// The child row kept tinted: (parent row, child row).
  final (int, int)? selectedChild;

  /// The caption (`web-title-sm`), also the accessible name of the table.
  final String? caption;

  /// The sorted column, or null.
  final int? sortColumn;
  final bool sortAscending;
  final ValueChanged<int>? onSort;

  /// The text of a cell with no data.
  final String emptyCell;

  @override
  State<PantasDataTable> createState() => _PantasDataTableState();
}

class _PantasDataTableState extends State<PantasDataTable> {
  final ScrollController _scroll = ScrollController();
  (int, int)? _hover;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _sort(int column) {
    widget.onSort?.call(column);
    // The new order is announced after the caller has applied it.
    final label = widget.columns[column].label;
    final ascending = widget.sortColumn != column || !widget.sortAscending;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Sorted by $label, ${ascending ? 'ascending' : 'descending'}',
        Directionality.of(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => _table(context, box.maxWidth),
      );

  Widget _table(BuildContext context, double maxWidth) {
    final colors = context.colors;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final bodyStyle =
        PantasType.webRowValue.copyWith(color: colors.textPrimary);
    final headStyle =
        PantasType.webEyebrow.copyWith(color: colors.textSecondary);

    double measure(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    final bodyLine = scaler.scale(PantasType.webRowValue.fontSize!) *
        PantasType.webRowValue.height!;
    final headLine = scaler.scale(PantasType.webEyebrow.fontSize!) *
        PantasType.webEyebrow.height!;
    final rowHeight =
        math.max<double>(PantasSize.targetTouch, bodyLine + PantasSpace.s20);
    final headHeight =
        math.max<double>(PantasSize.targetTouch, headLine + PantasSpace.s24);
    final last = widget.columns.length - 1;
    final allRows = [
      ...widget.rows,
      for (final kids in (widget.childRows ?? const {}).values) ...kids,
    ];
    String? textOf(Object? cell) =>
        cell is PantasTableCell ? cell.text : cell as String?;
    final subStyle = PantasType.webRowSub.copyWith(color: colors.textSecondary);
    TextStyle styleOf(Object? cell) => cell is PantasTableCell && cell.bold
        ? bodyStyle.copyWith(fontWeight: FontWeight.w600)
        : bodyStyle;
    final naturals = <double>[
      for (var c = 0; c <= last; c++)
        () {
          final column = widget.columns[c];
          var width = measure(column.label.toUpperCase(), headStyle) +
              (column.sortable
                  // The sort button: 6 of padding each side, a 4 gap and
                  // the chevron.
                  ? PantasSpace.s6 * 2 +
                      PantasSpace.s4 +
                      PantasSize.icon -
                      PantasSpace.s4
                  : 0);
          for (final row in allRows) {
            final cell = row[c];
            width = math.max(
              width,
              cell is PantasTableCell && cell.child != null
                  ? cell.width!
                  : math.max(
                        measure(
                          textOf(cell) ?? widget.emptyCell,
                          styleOf(cell),
                        ),
                        cell is PantasTableCell && cell.subtitle != null
                            ? measure(cell.subtitle!, subStyle)
                            : 0,
                      ) +
                      (cell is PantasTableCell ? cell.indent : 0),
            );
          }
          // Outer cells pad 20; the others 16 on each side.
          return width +
              PantasSpace.s16 * 2 +
              (c == 0 ? PantasSpace.s4 : 0) +
              (c == last ? PantasSpace.s4 : 0);
        }(),
    ];
    // The pinned column never takes more than 60% of the table, so the other
    // columns stay in view; a longer name wraps and its row grows.
    final cap = maxWidth.isFinite
        ? (last > 0 ? maxWidth * .6 : maxWidth)
        : double.infinity;
    // The header never wraps, so the pinned column keeps at least its width.
    final headFirst =
        measure(widget.columns[0].label.toUpperCase(), headStyle) +
            (widget.columns[0].sortable
                ? PantasSpace.s6 * 2 + PantasSize.icon
                : 0) +
            PantasSpace.s16 * 2 +
            PantasSpace.s4;
    final widths = <double>[
      math.max(math.min(naturals[0], cap), math.min(headFirst, naturals[0])),
      for (var c = 1; c <= last; c++) naturals[c],
    ];
    final wraps = naturals[0] > widths[0];
    double heightOf(List<Object?> row) {
      final cell = row[0];
      if (cell is PantasTableCell && cell.child != null) return rowHeight;
      final sub = cell is PantasTableCell ? cell.subtitle : null;
      if (!wraps && sub == null) return rowHeight;
      final room = math.max<double>(
        0,
        widths[0] -
            PantasSpace.s20 -
            PantasSpace.s16 -
            (cell is PantasTableCell ? cell.indent : 0),
      );
      double lines(String text, TextStyle style) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: direction,
          textScaler: scaler,
        )..layout(maxWidth: room);
        final height = painter.height;
        painter.dispose();
        return height;
      }

      final height = lines(textOf(cell) ?? widget.emptyCell, styleOf(cell)) +
          (sub == null ? 0 : PantasSpace.s2 + lines(sub, subStyle));
      return math.max(rowHeight, height + PantasSpace.s20);
    }

    final rowHeights = <double>[for (final row in widget.rows) heightOf(row)];
    final childHeights = <int, List<double>>{
      for (final e in (widget.childRows ?? const {}).entries)
        e.key: [for (final row in e.value) heightOf(row)],
    };

    EdgeInsets pad(int c) {
      final first = c == 0;
      final end = c == last;
      return EdgeInsets.only(
        left: first ? PantasSpace.s20 : PantasSpace.s16,
        right: end ? PantasSpace.s20 : PantasSpace.s16,
      );
    }

    final hairline = BorderSide(
      color: colors.divider,
      width: PantasBorder.hairline,
    );

    Widget header(int c) {
      final column = widget.columns[c];
      final sorted = widget.sortColumn == c;
      final text = Text(
        column.label.toUpperCase(),
        maxLines: 1,
        softWrap: false,
        style: headStyle.copyWith(
          color: sorted ? colors.textPrimary : colors.textSecondary,
        ),
      );
      Widget child = text;
      if (column.sortable && widget.onSort != null) {
        child = Semantics(
          button: true,
          label: column.label,
          value: sorted
              ? (widget.sortAscending ? 'ascending' : 'descending')
              : null,
          excludeSemantics: true,
          onTap: () => _sort(c),
          child: OffsetFocusRing(
            borderRadius: BorderRadius.circular(PantasRadius.xs),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => _sort(c),
                borderRadius: BorderRadius.circular(PantasRadius.xs),
                hoverColor:
                    colors.textPrimary.withValues(alpha: PantasOpacity.hover),
                focusColor: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: PantasSize.targetTouch,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PantasSpace.s6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        text,
                        const SizedBox(width: PantasSpace.s4),
                        AnimatedRotation(
                          turns: sorted && !widget.sortAscending ? .5 : 0,
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : PantasDurations.short2,
                          child: Icon(
                            _caretDown,
                            size: PantasSize.icon - PantasSpace.s4,
                            color: sorted
                                ? colors.textPrimary
                                : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      final cellWidget = Container(
        width: widths[c],
        height: headHeight,
        // The sort button pulls 6 px into the padding, so its text lines up.
        padding: pad(c).copyWith(
          left: pad(c).left - (column.sortable ? PantasSpace.s6 : 0),
        ),
        alignment: column.numeric
            ? AlignmentDirectional.bottomEnd
            : AlignmentDirectional.bottomStart,
        decoration: BoxDecoration(border: Border(bottom: hairline)),
        child: child,
      );
      // A header with no label repeats another column; screen readers skip it.
      return column.label.isEmpty
          ? ExcludeSemantics(child: cellWidget)
          : Semantics(header: true, child: cellWidget);
    }

    String? labelOf(Object? cell) => cell is PantasTableCell
        ? (cell.semanticLabel ?? cell.text)
        : (cell as String?) ?? widget.emptyCell;

    bool opened(int r) =>
        widget.expandedRows.contains(r) &&
        (widget.childRows?[r]?.isNotEmpty ?? false);

    Widget body(int c, int r, [int? k]) {
      final column = widget.columns[c];
      final cells = k == null ? widget.rows[r] : widget.childRows![r]![k];
      final value = cells[c];
      final height = k == null ? rowHeights[r] : childHeights[r]![k];
      final empty = textOf(value) == null && value is! PantasTableCell;
      final sub = value is PantasTableCell ? value.subtitle : null;
      final text = Text(
        textOf(value) ?? widget.emptyCell,
        maxLines: c == 0 ? null : 1,
        softWrap: c == 0,
        overflow: TextOverflow.clip,
        style: styleOf(value).copyWith(
          color: empty ? colors.textSecondary : colors.textPrimary,
          fontFeatures:
              column.numeric ? const [FontFeature.tabularFigures()] : null,
        ),
      );
      final content = value is PantasTableCell && value.child != null
          ? value.child!
          : Padding(
              padding: EdgeInsetsDirectional.only(
                start: value is PantasTableCell ? value.indent : PantasSpace.s0,
              ),
              child: sub == null
                  ? text
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        text,
                        const SizedBox(height: PantasSpace.s2),
                        Text(
                          sub,
                          maxLines: c == 0 ? null : 1,
                          softWrap: c == 0,
                          overflow: TextOverflow.clip,
                          style: subStyle,
                        ),
                      ],
                    ),
            );
      final tap = k == null
          ? (widget.onRowTap == null ? null : () => widget.onRowTap!(r))
          : (widget.onChildTap == null ? null : () => widget.onChildTap!(r, k));
      final id = (r, k ?? -1);
      final selected =
          k == null ? widget.selectedRow == r : widget.selectedChild == (r, k);
      final base = selected
          ? colors.accentTint
          : k != null
              ? colors.surfaceInset
              : null;
      final tint = tap != null && _hover == id
          ? Color.alphaBlend(
              colors.textPrimary.withValues(alpha: PantasOpacity.hover),
              base ?? Colors.transparent,
            )
          : base;
      final lastLine = r == widget.rows.length - 1 &&
          (k == null ? !opened(r) : k == widget.childRows![r]!.length - 1);
      Widget cell = Container(
        width: widths[c],
        height: height,
        padding: pad(c),
        alignment: column.numeric
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: tint,
          border: lastLine ? null : Border(bottom: hairline),
        ),
        child: content,
      );
      if (tap == null) return cell;
      if (c == 0) {
        // The first cell is the row's button: focus, Enter and Space.
        return Semantics(
          button: true,
          selected: selected,
          label: labelOf(value),
          excludeSemantics: true,
          onTap: tap,
          child: OffsetFocusRing(
            borderRadius: BorderRadius.circular(PantasRadius.xs),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: tap,
                onHover: (hovered) => setState(
                  () => _hover = hovered ? id : (_hover == id ? null : _hover),
                ),
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                child: cell,
              ),
            ),
          ),
        );
      }
      cell = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = id),
        onExit: (_) => setState(() => _hover = _hover == id ? null : _hover),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: tap,
          child: cell,
        ),
      );
      return ExcludeSemantics(child: cell);
    }

    /// A parent's children, opening and closing in 240 ms.
    Widget children(int c, int r) {
      final kids = widget.childRows?[r];
      if (kids == null || kids.isEmpty) return const SizedBox.shrink();
      final stack = SizedBox(
        width: widths[c],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (opened(r))
              for (var k = 0; k < kids.length; k++) body(c, r, k),
          ],
        ),
      );
      // A zero-length AnimatedSize re-enters its own layout, so reduced
      // motion skips it.
      return KeyedSubtree(
        key: c == 0 ? ValueKey('data-table-children-$r') : null,
        child: MediaQuery.disableAnimationsOf(context)
            ? stack
            : AnimatedSize(
                duration: PantasDurations.medium1,
                curve: PantasCurves.move,
                alignment: Alignment.topCenter,
                child: stack,
              ),
      );
    }

    Widget column(int c) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header(c),
            for (var r = 0; r < widget.rows.length; r++) ...[
              body(c, r),
              children(c, r),
            ],
          ],
        );

    final radius = BorderRadius.circular(PantasRadius.xl);
    return Semantics(
      container: true,
      label: widget.caption,
      child: Container(
        key: const ValueKey('data-table'),
        decoration:
            BoxDecoration(color: colors.surfaceCard, borderRadius: radius),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: colors.edgeCard),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.caption != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s20,
                    PantasSpace.s16,
                    PantasSpace.s20,
                    PantasSpace.s8,
                  ),
                  child: Text(
                    widget.caption!,
                    style: PantasType.webTitleSm.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The first column is pinned and is the row header.
                  ColoredBox(
                    key: const ValueKey('data-table-pinned'),
                    color: colors.surfaceCard,
                    child: column(0),
                  ),
                  if (last > 0)
                    Expanded(
                      child: Scrollbar(
                        controller: _scroll,
                        child: SingleChildScrollView(
                          controller: _scroll,
                          scrollDirection: Axis.horizontal,
                          child: Focus(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var c = 1; c <= last; c++) column(c),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
