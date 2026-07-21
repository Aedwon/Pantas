import 'package:cse_cet_reviewer/core/ui/components/data_row_tile.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_panel.dart';
import 'package:cse_cet_reviewer/core/ui/severity.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_providers.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/progress/application/performance_provider.dart';
import 'package:cse_cet_reviewer/features/progress/application/table_order_prefs.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/level_control.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/subject_scope_sheet.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/table_head.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The tab's centre: accuracy and pace, readable at three levels, whose
/// labels are its own controls.
///
/// **Enclosed like the sections either side of it**, which amends the design
/// spec. It was the only unframed thing on the tab and read as loose:
/// *"that section feels out of place"*. The panel's heading replaces the
/// section header, so there is still only one rule under the title rather
/// than the two four pixels apart the spec warns about.
///
/// **Collapsed by default.** Rows with nothing measured already sort last, so
/// collapsing hides exactly those, which is what removing them was meant to
/// achieve without losing the fact that they have not been started. At Lesson
/// level for a Pro student the full table runs to a hundred rows.
class PerformanceSection extends ConsumerStatefulWidget {
  const PerformanceSection({super.key});

  @override
  ConsumerState<PerformanceSection> createState() => _PerformanceSectionState();
}

class _PerformanceSectionState extends ConsumerState<PerformanceSection> {
  /// How many rows the collapsed table shows.
  static const _collapsedRows = 6;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(tableOrderProvider).valueOrNull;
    if (order == null) return const FaintBars();

    final entitlement =
        ref.watch(entitlementProvider).valueOrNull ?? const Entitlement.free();
    final isPro = entitlement.proIsActive;

    // Free reads the table at subject level. The control still shows the
    // deeper labels, dimmed, so it knows what Pro opens.
    final level = isPro ? order.level : TableLevel.subject;
    final subjectId = level == TableLevel.subject ? null : order.subjectId;

    final tableAsync = ref.watch(
      performanceProvider(
        PerformanceQuery(level: level, subjectId: subjectId),
      ),
    );
    final table = tableAsync.valueOrNull;

    final sorted = table == null
        ? const <PerformanceRow>[]
        : _sorted(table.rows, order, table.timeIsMeasurable);
    final hidden = _expanded
        ? 0
        : (sorted.length - _collapsedRows).clamp(0, sorted.length);
    final shown = _expanded ? sorted : sorted.take(_collapsedRows).toList();
    final unmeasuredHidden =
        sorted.skip(shown.length).where((r) => r.accuracy == null).length;

    return RuledPanel(
      heading: 'Performance',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: LevelControl(
              level: level,
              isPro: isPro,
              lessonAvailable: table?.lessonLevelAvailable ?? false,
              onChanged: (next) =>
                  ref.read(tableOrderProvider.notifier).setLevel(next),
              onLocked: () => context.push('/paywall'),
            ),
          ),
          const SizedBox(height: 8),
          if (table == null)
            const FaintBars()
          else ...[
            TableHead(
              rowNoun: _nounFor(level),
              showTime: table.timeIsMeasurable,
              sortKey: table.timeIsMeasurable
                  ? order.sortKey
                  // With no Time column there is nothing else to sort by, so
                  // the sort falls back to Score rather than pointing at a
                  // head that is not drawn.
                  : TableSortKey.score,
              direction: order.direction,
              onSort: (key) => _sort(ref, order, key),
              scopeLabel: _scopeLabel(level, table, subjectId),
              onScope: _canScope(level, table)
                  ? () => _openScope(context, ref, level, table, subjectId)
                  : null,
            ),
            for (final row in shown)
              DataRowTile(
                title: row.title,
                subtext: row.subtext,
                primaryFigure: _accuracyFigure(row),
                primaryColor: _accuracyColour(context, row),
                secondaryFigure:
                    table.timeIsMeasurable ? _timeFigure(row) : null,
                primaryIsActive: order.sortKey == TableSortKey.score ||
                    !table.timeIsMeasurable,
                // The bar reads the row before the number does, which is what
                // Home's weakest-areas panel already does with the same
                // component. No bar where there is nothing measured.
                showMeterSlot: true,
                meterValue: row.accuracy,
                onTap: level == TableLevel.lesson
                    ? () => context.push('/lesson/${row.id}')
                    : null,
              ),
            if (hidden > 0 || _expanded)
              _ExpandControl(
                expanded: _expanded,
                hidden: hidden,
                unmeasured: unmeasuredHidden,
                noun: _nounFor(level).toLowerCase(),
                onTap: () => setState(() => _expanded = !_expanded),
              ),
            if (!table.timeIsMeasurable) _NoTimeLine(),
          ],
        ],
      ),
    );
  }

  String _nounFor(TableLevel level) => switch (level) {
        TableLevel.subject => 'Subject',
        TableLevel.topic => 'Topic',
        TableLevel.lesson => 'Lesson',
      };

  bool _canScope(TableLevel level, PerformanceTable table) =>
      level != TableLevel.subject && table.subjects.length >= 2;

  String? _scopeLabel(
    TableLevel level,
    PerformanceTable table,
    String? subjectId,
  ) {
    if (!_canScope(level, table)) return null;
    return scopeLabelFor(
      level: level,
      subjectName: table.subjects
          .where((s) => s.id == subjectId)
          .map((s) => s.name)
          .firstOrNull,
    );
  }

  Future<void> _openScope(
    BuildContext context,
    WidgetRef ref,
    TableLevel level,
    PerformanceTable table,
    String? subjectId,
  ) async {
    final noun = level == TableLevel.lesson ? 'lessons' : 'topics';
    final choice = await showSubjectScopeSheet(
      context,
      subjects: table.subjects,
      selectedId: subjectId,
      allLabel: 'All $noun',
      heading: 'Show which $noun',
    );
    // Nothing at all means dismissed, which leaves the filter alone.
    if (choice == null) return;
    await ref.read(tableOrderProvider.notifier).setSubjectId(choice.subjectId);
  }

  void _sort(WidgetRef ref, TableOrder order, TableSortKey key) {
    final notifier = ref.read(tableOrderProvider.notifier);
    if (order.sortKey == key) {
      notifier.setDirection(
        order.direction == TableSortDirection.ascending
            ? TableSortDirection.descending
            : TableSortDirection.ascending,
      );
      return;
    }
    notifier.setSortKey(key);
  }

  String? _accuracyFigure(PerformanceRow row) {
    final accuracy = row.accuracy;
    if (accuracy == null) return null;
    return '${(accuracy * 100).round()}%';
  }

  Color? _accuracyColour(BuildContext context, PerformanceRow row) {
    final accuracy = row.accuracy;
    if (accuracy == null) return null;
    // Computed from the figure and never from the row's position, so
    // re-sorting the table cannot change a colour.
    return severityFor(accuracy, context.colors);
  }

  String? _timeFigure(PerformanceRow row) {
    final seconds = row.secondsPerQuestion;
    if (seconds == null) return null;
    return '${seconds.round()}s';
  }

  List<PerformanceRow> _sorted(
    List<PerformanceRow> rows,
    TableOrder order,
    bool timeIsMeasurable,
  ) {
    final sortByTime = order.sortKey == TableSortKey.time && timeIsMeasurable;
    final sorted = [...rows]..sort((a, b) {
        final aValue = sortByTime ? a.secondsPerQuestion : a.accuracy;
        final bValue = sortByTime ? b.secondsPerQuestion : b.accuracy;
        // A row with nothing measured sits at the end either way, so the
        // table never opens on a run of blanks.
        if (aValue == null && bValue == null) return a.title.compareTo(b.title);
        if (aValue == null) return 1;
        if (bValue == null) return -1;
        final cmp = aValue.compareTo(bValue);
        return order.direction == TableSortDirection.ascending ? cmp : -cmp;
      });
    return sorted;
  }
}

class _NoTimeLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Text(
        'Your pace per question appears here after your first full length '
        'mock, because that is the only place the app can measure you '
        'against a real clock.',
        style: styles.bodySmall.copyWith(color: colors.inkMuted),
      ),
    );
  }
}

/// The control that opens and closes the table.
///
/// **It names what it reveals.** "Show more" makes a student guess whether
/// there are three rows behind it or ninety, and how many of them are worth
/// looking at. Naming the not-started count is also the honest answer to
/// hiding them: they are not gone, they are behind a labelled door.
class _ExpandControl extends StatelessWidget {
  const _ExpandControl({
    required this.expanded,
    required this.hidden,
    required this.unmeasured,
    required this.noun,
    required this.onTap,
  });

  final bool expanded;
  final int hidden;
  final int unmeasured;
  final String noun;
  final VoidCallback onTap;

  String get _label {
    if (expanded) return 'Show less';
    if (unmeasured == hidden && hidden > 0) {
      return 'Show $hidden not started';
    }
    if (unmeasured > 0) {
      return 'Show $hidden more, $unmeasured not started';
    }
    return 'Show $hidden more ${noun}s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        // Ink, not board. The spec is explicit that board green appears
        // nowhere in this table, and the colour budget keeps it for primary
        // actions. Weight carries this instead of colour.
        child: Text(
          _label,
          style: styles.labelSmall.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
