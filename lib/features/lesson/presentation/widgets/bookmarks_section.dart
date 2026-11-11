import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_skeletons.dart';

class BookmarksSection extends ConsumerWidget {
  const BookmarksSection({this.onSeeAll, super.key});
  final VoidCallback? onSeeAll;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(bookmarkRowsProvider);
    return value.when(
      loading: () => const BookmarksSkeleton(),
      error: (error, _) => errorFor(
        'bookmarks',
        () => ref.invalidate(bookmarkRowsProvider),
        error: error,
      ),
      data: (rows) => Padding(
        padding: const EdgeInsets.only(bottom: PantasSpace.s24),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    PantasSpace.s0,
                    PantasSpace.s16,
                    PantasSpace.s6,
                  ),
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
                                horizontal: PantasSpace.s24,
                                vertical: PantasSpace.s20,
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
                                  const SizedBox(height: PantasSpace.s8),
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
                          for (final (index, row) in rows.take(3).indexed)
                            ListRow(
                              title: row.title,
                              wrapTitle:
                                  MediaQuery.textScalerOf(context).scale(17) >
                                      25.5,
                              // Board: one line at default text.
                              truncateTitle:
                                  MediaQuery.textScalerOf(context).scale(17) <=
                                      25.5,
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
                              verticalPadding: 12.5,
                              contentPadding: context.wideWeb
                                  ? null
                                  : const EdgeInsets.fromLTRB(
                                      PantasSpace.s16,
                                      PantasSpace.s10,
                                      PantasSpace.s16,
                                      PantasSpace.s12,
                                    ),
                              subtitleGap: context.wideWeb
                                  ? PantasSpace.s0
                                  : PantasSpace.s2,
                              divider: index < rows.take(3).length - 1,
                              dividerInset: 52,
                              onTap: () => context.push(
                                '/lesson/${row.lessonId}?from=study',
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
                child: Semantics(
                  label: 'See all bookmarks',
                  excludeSemantics: true,
                  // The link draws at its own size; the box around it is the
                  // 44 px hit area on every width.
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onSeeAll,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: PantasSize.targetTouch,
                        minWidth: PantasSize.targetTouch,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        widthFactor: 1,
                        child: WebTextLink(
                          label: 'See all',
                          arrow: false,
                          onPressed: onSeeAll,
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
