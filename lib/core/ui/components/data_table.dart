import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
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
    super.key,
  }) : assert(columns.length > 0, 'A table needs a column.');

  final List<PantasTableColumn> columns;

  /// The rows: one text per column. `null` is a cell with no data.
  final List<List<String?>> rows;

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
  Widget build(BuildContext context) {
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
    final widths = <double>[
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
          for (final row in widget.rows) {
            width = math.max(
              width,
              measure(row[c] ?? widget.emptyCell, bodyStyle),
            );
          }
          // Outer cells pad 20; the others 16 on each side.
          return width +
              PantasSpace.s16 * 2 +
              (c == 0 ? PantasSpace.s4 : 0) +
              (c == last ? PantasSpace.s4 : 0);
        }(),
    ];

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
      return Semantics(
        header: true,
        child: Container(
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
        ),
      );
    }

    Widget body(int c, int r) {
      final column = widget.columns[c];
      final value = widget.rows[r][c];
      final empty = value == null;
      return Container(
        width: widths[c],
        height: rowHeight,
        padding: pad(c),
        alignment: column.numeric
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        decoration: r == widget.rows.length - 1
            ? null
            : BoxDecoration(border: Border(bottom: hairline)),
        child: Text(
          empty ? widget.emptyCell : value,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          style: bodyStyle.copyWith(
            color: empty ? colors.textSecondary : colors.textPrimary,
            fontFeatures:
                column.numeric ? const [FontFeature.tabularFigures()] : null,
          ),
        ),
      );
    }

    Widget column(int c) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header(c),
            for (var r = 0; r < widget.rows.length; r++) body(c, r),
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
