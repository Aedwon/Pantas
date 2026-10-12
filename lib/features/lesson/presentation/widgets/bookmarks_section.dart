import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';

class BookmarksSection extends ConsumerWidget {
  const BookmarksSection({this.onSeeAll, super.key});
  final VoidCallback? onSeeAll;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(bookmarkRowsProvider);
    return value.when(
      loading: () => loadingFor(value),
      error: (error, _) => errorFor(
        'bookmarks',
        () => ref.invalidate(bookmarkRowsProvider),
        error: error,
      ),
      data: (rows) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 7),
                  child: SizedBox(
                    height: rows.isEmpty
                        ? null
                        : MediaQuery.textScalerOf(context).scale(15) * 1.35,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'BOOKMARKS',
                        style: context.type.sectionHeader,
                      ),
                    ),
                  ),
                ),
                GroupedSection(
                  children: rows.isEmpty
                      ? [
                          Semantics(
                            liveRegion: true,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 22,
                              ),
                              child: Column(
                                children: [
                                  ExcludeSemantics(
                                    child: Icon(
                                      PantasIcons.bookmark,
                                      size: 22,
                                      color: context.colors.tertiaryLabel,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bookmark a lesson to keep it here.',
                                    textAlign: TextAlign.center,
                                    style: context.type.subhead.copyWith(
                                      color: context.colors.secondaryLabel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]
                      : [
                          for (final row in rows.take(3))
                            ListRow(
                              title: row.title,
                              wrapTitle: true,
                              subtitle: row.topicName,
                              leading: SizedBox.square(
                                dimension: 24,
                                child: Icon(
                                  PantasIcons.bookmark,
                                  size: 18,
                                  color: context.colors.secondaryLabel,
                                ),
                              ),
                              trailingWidget: Icon(
                                PantasIcons.next,
                                size: 14,
                                color: context.colors.chevron,
                              ),
                              verticalPadding: 12,
                              onTap: () => context.push(
                                '/lesson/${row.lessonId}?from=bookmarks',
                              ),
                            ),
                        ],
                ),
              ],
            ),
            if (rows.isNotEmpty)
              Positioned(
                top: 0,
                right: 16,
                child: TextButton(
                  onPressed: onSeeAll,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Semantics(
                    label: 'See all bookmarks',
                    excludeSemantics: true,
                    child: SizedBox(
                      height: 44,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'See all',
                          style: context.type.subheadStrong.copyWith(
                            color: context.colors.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
