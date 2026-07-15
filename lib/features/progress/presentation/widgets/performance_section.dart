import 'package:cse_cet_reviewer/core/ui/components/data_row_tile.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
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
class PerformanceSection extends ConsumerWidget {
  const PerformanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Performance',
          trailing: LevelControl(
            level: level,
            isPro: isPro,
            lessonAvailable: table?.lessonLevelAvailable ?? false,
            onChanged: (next) =>
                ref.read(tableOrderProvider.notifier).setLevel(next),
            onLocked: () => context.push('/paywall'),
          ),
        ),
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
          for (final row in _sorted(table.rows, order, table.timeIsMeasurable))
            DataRowTile(
              title: row.title,
              subtext: row.subtext,
              primaryFigure: _accuracyFigure(row),
              primaryColor: _accuracyColour(context, row),
              secondaryFigure: table.timeIsMeasurable ? _timeFigure(row) : null,
              primaryIsActive: order.sortKey == TableSortKey.score ||
                  !table.timeIsMeasurable,
              onTap: level == TableLevel.lesson
                  ? () => context.push('/lesson/${row.id}')
                  : null,
            ),
          if (!table.timeIsMeasurable) _NoTimeLine(),
        ],
      ],
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
