import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/ink_sheet.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';

const String _lede =
    'Each session has one main topic. This sets how much comes from '
    'other topics.';

/// The three-way choice for how today's session is built.
///
/// A sheet rather than a page, and there is no Save: a choice takes effect on
/// tap because nothing is lost by changing your mind. The reasons are short
/// on purpose. They were too long for a fifth grader before they were ever
/// too long for a sheet.
Future<SessionOrdering?> showOrderingSheet({
  required BuildContext context,
  required SessionOrdering current,
}) {
  return showInkSheet<SessionOrdering>(
    context: context,
    builder: (sheetContext) {
      final colors = sheetContext.colors;
      final styles = sheetContext.textStyles;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How sessions are built',
            style: styles.headlineSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(_lede, style: styles.bodySmall.copyWith(color: colors.inkMuted)),
          const SizedBox(height: 12),
          for (final ordering in SessionOrdering.values)
            _OrderingRow(
              ordering: ordering,
              isSelected: ordering == current,
              isLast: ordering == SessionOrdering.values.last,
              onTap: () => Navigator.of(sheetContext).pop(ordering),
            ),
        ],
      );
    },
  );
}

class _OrderingRow extends StatelessWidget {
  const _OrderingRow({
    required this.ordering,
    required this.isSelected,
    required this.isLast,
    required this.onTap,
  });

  final SessionOrdering ordering;
  final bool isSelected;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return MergeSemantics(
      child: Semantics(
        checked: isSelected,
        inMutuallyExclusiveGroup: true,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.only(top: 12, bottom: 11),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: colors.ruleFaint)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: _Ring(isSelected: isSelected),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ordering.label,
                            style: styles.bodyMedium.copyWith(
                              fontSize: 14.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (ordering.isRecommended) ...[
                            const SizedBox(width: 7),
                            Text(
                              'Recommended',
                              style: styles.labelSmall.copyWith(
                                fontSize: 10.5,
                                color: colors.board,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ordering.reason,
                        style:
                            styles.bodySmall.copyWith(color: colors.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 13,
      height: 13,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? colors.ink : colors.inkMuted,
            width: 1.3,
          ),
        ),
        child: isSelected
            ? Center(
                child: SizedBox(
                  width: 6.8,
                  height: 6.8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.ink,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
