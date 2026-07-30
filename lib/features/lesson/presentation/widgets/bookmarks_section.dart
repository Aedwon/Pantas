import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/core/ui/components/pennant_mark.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';

class BookmarksSection extends ConsumerWidget {
  const BookmarksSection({
    this.onSeeAll,
    super.key,
  });

  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(bookmarkRowsProvider);
    final countAsync = ref.watch(bookmarkCountProvider);

    final rows = rowsAsync.valueOrNull ?? const [];
    final count = countAsync.valueOrNull ?? 0;

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final styles = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.ruleFaint),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Bookmarks',
                style: styles.headlineSmall,
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: styles.bodySmall.copyWith(color: colors.inkMuted),
              ),
              const Spacer(),
              if (count > 3)
                GestureDetector(
                  onTap: onSeeAll,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'See all',
                    style: styles.bodySmall.copyWith(
                      color: colors.board,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (final row in rows.take(3))
          GestureDetector(
            onTap: () => context.push('/lesson/${row.lessonId}'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.ruleFaint),
                ),
              ),
              child: Row(
                children: [
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
                          style: styles.bodySmall.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const InkChevron(),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
