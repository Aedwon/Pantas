import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_text_styles.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Renders search results, the empty query state showing what was recently
/// opened, or the no-match state.
class SearchResults extends ConsumerWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider).trim();
    if (query.isEmpty) {
      return const _RecentlyOpenedResults();
    }

    final asyncHits = ref.watch(searchResultsProvider);
    return asyncHits.when(
      loading: () => const FaintBars(),
      error: (e, _) => const ErrorBanner(
        variant: ErrorBannerVariant.error,
        message: 'Could not load search results.',
      ),
      data: (hits) {
        if (hits.isEmpty) {
          return _NoMatchesState(query: query);
        }

        return _HitListView(hits: hits);
      },
    );
  }
}

class _RecentlyOpenedResults extends ConsumerWidget {
  const _RecentlyOpenedResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecent = ref.watch(recentlyOpenedLessonsProvider);
    final colors = context.colors;
    final styles = context.textStyles;

    return asyncRecent.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (recent) {
        if (recent.isEmpty) return const SizedBox.shrink();

        return ListView(
          children: [
            const SizedBox(height: 12),
            Text(
              'Recently opened',
              style: styles.bodySmall.copyWith(
                fontSize: 11.5,
                color: colors.inkMuted,
              ),
            ),
            const SizedBox(height: 8),
            for (final lesson in recent)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/lesson/${lesson.id}?from=study'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colors.rule,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: styles.bodyMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${lesson.estimatedMinutes}m',
                        style:
                            styles.bodySmall.copyWith(color: colors.inkMuted),
                      ),
                      const SizedBox(width: 8),
                      const InkChevron(),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NoMatchesState extends StatelessWidget {
  const _NoMatchesState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nothing matched "$query"',
            style: styles.headlineSmall.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a shorter word, or part of one.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HitListView extends StatelessWidget {
  const _HitListView({required this.hits});

  final List<LessonSearchHit> hits;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final countLabel =
        '${hits.length} ${hits.length == 1 ? 'lesson' : 'lessons'}';

    return ListView(
      children: [
        const SizedBox(height: 12),
        Text(
          countLabel,
          style: styles.bodySmall.copyWith(
            fontSize: 11.5,
            color: colors.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        for (final hit in hits) _HitRow(hit: hit),
      ],
    );
  }
}

class _HitRow extends StatelessWidget {
  const _HitRow({required this.hit});

  final LessonSearchHit hit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/lesson/${hit.lessonId}?from=study'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colors.rule,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleText(styles, colors, hit),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    hit.topicName,
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ),
                Text(
                  '${hit.estimatedMinutes}m',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
                const SizedBox(width: 8),
                const InkChevron(),
              ],
            ),
            if (hit.titleMatch == null && hit.bodySnippet != null) ...[
              const SizedBox(height: 4),
              _buildSnippetText(styles, colors, hit.bodySnippet!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitleText(
    AppTextStyles styles,
    AppColors colors,
    LessonSearchHit hit,
  ) {
    final baseStyle = styles.bodyLarge.copyWith(
      fontWeight: FontWeight.w400,
      color: colors.ink,
    );

    final match = hit.titleMatch;
    if (match == null) {
      return Text(hit.title, style: baseStyle);
    }

    final spans = _buildSpans(
      fullText: match.text,
      matchStart: match.matchStart,
      matchLength: match.matchLength,
      normalStyle: baseStyle,
      matchedStyle: baseStyle.copyWith(fontWeight: FontWeight.w700),
    );

    return Text.rich(TextSpan(children: spans));
  }

  Widget _buildSnippetText(
    AppTextStyles styles,
    AppColors colors,
    SearchSnippet snippet,
  ) {
    final baseStyle = styles.bodySmall.copyWith(
      fontWeight: FontWeight.w400,
      color: colors.inkMuted,
    );

    final spans = _buildSpans(
      fullText: snippet.text,
      matchStart: snippet.matchStart,
      matchLength: snippet.matchLength,
      normalStyle: baseStyle,
      matchedStyle: baseStyle.copyWith(
        fontWeight: FontWeight.w700,
        color: colors.ink,
      ),
    );

    return Text.rich(TextSpan(children: spans));
  }

  List<TextSpan> _buildSpans({
    required String fullText,
    required int matchStart,
    required int matchLength,
    required TextStyle normalStyle,
    required TextStyle matchedStyle,
  }) {
    if (matchStart < 0 || matchStart + matchLength > fullText.length) {
      return [TextSpan(text: fullText, style: normalStyle)];
    }

    final before = fullText.substring(0, matchStart);
    final matched = fullText.substring(matchStart, matchStart + matchLength);
    final after = fullText.substring(matchStart + matchLength);

    return [
      if (before.isNotEmpty) TextSpan(text: before, style: normalStyle),
      TextSpan(text: matched, style: matchedStyle),
      if (after.isNotEmpty) TextSpan(text: after, style: normalStyle),
    ];
  }
}
