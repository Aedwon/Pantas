import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/components/ink_checkbox.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';

Future<void> showBookmarksSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    barrierColor: context.colors.ink.withValues(alpha: 0.34),
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.74,
    ),
    builder: (_) => const _BookmarksSheet(),
  );
}

class _BookmarksSheet extends ConsumerStatefulWidget {
  const _BookmarksSheet();

  @override
  ConsumerState<_BookmarksSheet> createState() => _BookmarksSheetState();
}

class _BookmarksSheetState extends ConsumerState<_BookmarksSheet> {
  bool _editing = false;
  final Set<LessonId> _selectedIds = {};
  String? _undoMessage;
  Set<LessonId>? _removedForUndo;

  void _toggleSelect(LessonId id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _removeSelected(List<BookmarkRow> rows) async {
    if (_selectedIds.isEmpty) return;

    final repo = ref.read(lessonBookmarksRepositoryProvider);
    final toRemove = Set<LessonId>.from(_selectedIds);
    final count = toRemove.length;

    await repo.unmarkAll(toRemove);
    ref.invalidate(bookmarkRowsProvider);

    setState(() {
      _undoMessage = '$count bookmark${count == 1 ? '' : 's'} removed';
      _removedForUndo = toRemove;
      _selectedIds.clear();
    });
  }

  Future<void> _undoRemove() async {
    final toRestore = _removedForUndo;
    if (toRestore == null || toRestore.isEmpty) return;

    final repo = ref.read(lessonBookmarksRepositoryProvider);
    for (final id in toRestore) {
      await repo.mark(id);
    }
    ref.invalidate(bookmarkRowsProvider);

    setState(() {
      _undoMessage = null;
      _removedForUndo = null;
    });
  }

  Widget _tapTarget({
    required String label,
    required VoidCallback onTap,
    required Widget child,
    bool? selected,
  }) {
    return Semantics(
      button: true,
      label: label,
      selected: selected,
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 50),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final rowsAsync = ref.watch(bookmarkRowsProvider);
    final orderAsync = ref.watch(bookmarkOrderProvider);

    final rows = rowsAsync.valueOrNull ?? const [];
    final currentOrder = orderAsync.valueOrNull ?? BookmarkOrder.recent;
    final isCustom = currentOrder == BookmarkOrder.custom;
    final compactLayout = MediaQuery.textScalerOf(context).scale(1) >= 1.5;

    final editAction = _tapTarget(
      label: _editing ? 'Done editing bookmarks' : 'Edit bookmarks',
      onTap: () {
        setState(() {
          _editing = !_editing;
          _selectedIds.clear();
        });
      },
      child: Text(
        _editing ? 'Done' : 'Edit',
        style: styles.bodySmall.copyWith(
          color: colors.board,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );

    Widget orderAction(BookmarkOrder order) => _tapTarget(
          label: 'Order bookmarks by ${order.label}',
          selected: currentOrder == order,
          onTap: () {
            ref.read(bookmarkOrderProvider.notifier).choose(order);
          },
          child: Text(
            order.label,
            style: styles.bodySmall.copyWith(
              fontSize: 12.5,
              color: currentOrder == order ? colors.ink : colors.inkMuted,
              fontWeight:
                  currentOrder == order ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(top: BorderSide(color: colors.rule)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Container(
            width: 34,
            height: 3,
            margin: const EdgeInsets.only(top: 9, bottom: 2),
            decoration: BoxDecoration(
              color: colors.rule,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: compactLayout
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Bookmarks', style: styles.headlineMedium),
                      Align(
                        alignment: Alignment.centerRight,
                        child: editAction,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Text('Bookmarks', style: styles.headlineMedium),
                      const Spacer(),
                      editAction,
                    ],
                  ),
          ),

          // Order Selector
          Container(
            height: compactLayout ? 100 : 50,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.ruleFaint),
              ),
            ),
            child: compactLayout
                ? Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        for (final order in BookmarkOrder.values)
                          orderAction(order),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < BookmarkOrder.values.length; i++) ...[
                        if (i > 0)
                          Container(
                            width: 1,
                            height: 12,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            color: colors.rule,
                          ),
                        orderAction(BookmarkOrder.values[i]),
                      ],
                    ],
                  ),
          ),

          // Main bookmark list
          Expanded(
            child: isCustom && !_editing
                ? ReorderableListView.builder(
                    itemCount: rows.length,
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) async {
                      final ids = [for (final r in rows) r.lessonId];
                      final moved = ids.removeAt(oldIndex);
                      final targetIndex =
                          oldIndex < newIndex ? newIndex - 1 : newIndex;
                      ids.insert(targetIndex, moved);

                      await ref
                          .read(lessonBookmarksRepositoryProvider)
                          .reorder(ids);
                      ref.invalidate(bookmarkRowsProvider);
                    },
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return _buildRow(
                        key: ValueKey(row.lessonId),
                        row: row,
                        index: index,
                        isCustom: true,
                        isEditing: false,
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return _buildRow(
                        key: ValueKey(row.lessonId),
                        row: row,
                        index: index,
                        isCustom: isCustom,
                        isEditing: _editing,
                      );
                    },
                  ),
          ),

          // Undo Banner
          if (_undoMessage != null)
            ErrorBanner(
              variant: ErrorBannerVariant.success,
              message: _undoMessage!,
              actionLabel: 'Undo',
              onAction: _undoRemove,
            ),

          // Reset order button (only in custom mode)
          if (isCustom && !_editing)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _tapTarget(
                label: 'Reset bookmark order',
                onTap: () async {
                  await ref
                      .read(lessonBookmarksRepositoryProvider)
                      .clearCustomOrder();
                  ref.invalidate(bookmarkRowsProvider);
                },
                child: Text(
                  'Reset order',
                  style: styles.bodySmall.copyWith(
                    color: colors.inkMuted,
                  ),
                ),
              ),
            ),

          // Edit mode footer
          if (_editing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.ruleFaint),
                ),
              ),
              child: Builder(
                builder: (context) {
                  final selectedCount = Text(
                    '${_selectedIds.length} selected',
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  );
                  final selectAll = _tapTarget(
                    label: 'Select all bookmarks',
                    onTap: () {
                      setState(() {
                        if (_selectedIds.length == rows.length) {
                          _selectedIds.clear();
                        } else {
                          _selectedIds.addAll(rows.map((r) => r.lessonId));
                        }
                      });
                    },
                    child: Text(
                      'Select all',
                      style: styles.bodySmall.copyWith(color: colors.inkMuted),
                    ),
                  );
                  final remove = _tapTarget(
                    label: 'Remove selected bookmarks',
                    onTap: () => _removeSelected(rows),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colors.rust),
                      ),
                      child: Text(
                        'Remove',
                        style: styles.bodySmall.copyWith(
                          color: colors.rust,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                  if (compactLayout) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        selectedCount,
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            spacing: 16,
                            children: [selectAll, remove],
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      selectedCount,
                      const Spacer(),
                      selectAll,
                      const SizedBox(width: 16),
                      remove,
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required Key key,
    required BookmarkRow row,
    required int index,
    required bool isCustom,
    required bool isEditing,
  }) {
    final colors = context.colors;
    final styles = context.textStyles;

    void onRowTap() {
      if (isEditing) {
        _toggleSelect(row.lessonId);
      } else {
        context.push('/lesson/${row.lessonId}');
      }
    }

    return Semantics(
      key: key,
      button: !isEditing,
      checked: isEditing ? _selectedIds.contains(row.lessonId) : null,
      label: isEditing
          ? 'Select bookmark: ${row.title}'
          : 'Open bookmark: ${row.title}',
      onTap: onRowTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onRowTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.ruleFaint),
              ),
            ),
            child: Row(
              children: [
                if (isEditing) ...[
                  InkCheckbox(
                    state: _selectedIds.contains(row.lessonId)
                        ? InkCheckState.on
                        : InkCheckState.off,
                    onTap: () => _toggleSelect(row.lessonId),
                  ),
                  const SizedBox(width: 12),
                ],
                PennantMark(
                  isSet: true,
                  color: colors.inkMuted,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(row.title, style: styles.bodyMedium),
                      Text(
                        '${row.topicName}, ${row.estimatedMinutes} min',
                        style:
                            styles.bodySmall.copyWith(color: colors.inkMuted),
                      ),
                    ],
                  ),
                ),
                if (!isEditing) ...[
                  const SizedBox(width: 10),
                  const InkChevron(),
                ],
                if (isCustom) ...[
                  const SizedBox(width: 2),
                  ReorderableDragStartListener(
                    index: index,
                    child: SizedBox.square(
                      dimension: 48,
                      child: Icon(
                        Icons.drag_handle,
                        key: const ValueKey('bookmark-grip'),
                        color: colors.inkMuted,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
