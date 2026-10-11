import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';

class SearchResults extends ConsumerWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider).trim();
    if (query.isEmpty) {
      final recent = ref.watch(recentlyOpenedLessonsProvider);
      return recent.when(
        loading: () => loadingFor(recent),
        error: (error, _) => errorFor(
          'recent lessons',
          () => ref.invalidate(recentlyOpenedLessonsProvider),
          error: error,
        ),
        data: (lessons) {
          if (lessons.isEmpty) return const SizedBox.shrink();
          final map = ref.watch(studyMapProvider).valueOrNull;
          final topicByLesson = <String, String>{
            if (map != null)
              for (final subject in map.subjects)
                for (final topic in subject.topics)
                  for (final lesson in topic.lessons) lesson.id: topic.name,
          };
          return _ResultGroup(
            label: 'RECENTLY OPENED',
            delay: const Duration(milliseconds: 100),
            children: [
              for (final lesson in lessons.take(3))
                ListRow(
                  title: lesson.title,
                  titleColor:
                      lesson.isRead ? context.colors.secondaryLabel : null,
                  subtitle: topicByLesson[lesson.id],
                  leading: SizedBox.square(
                    dimension: 24,
                    child: lesson.isRead
                        ? Icon(
                            PantasIcons.check,
                            size: 18,
                            color: context.colors.accent,
                          )
                        : null,
                  ),
                  value:
                      lesson.isRead ? null : '${lesson.estimatedMinutes} min',
                  verticalPadding: 12,
                  onTap: () => context.push('/lesson/${lesson.id}?from=search'),
                ),
            ],
          );
        },
      );
    }

    final hits = ref.watch(searchResultsProvider);
    return hits.when(
      loading: () => loadingFor(hits),
      error: (error, _) => errorFor(
        'search results',
        () => ref.invalidate(searchResultsProvider),
        error: error,
      ),
      data: (results) {
        if (results.isEmpty) {
          return Semantics(
            liveRegion: true,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nothing matched “$query”',
                          textAlign: TextAlign.center,
                          style: context.type.emphasized.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try a shorter word, or part of one.',
                          textAlign: TextAlign.center,
                          style: context.type.subhead.copyWith(
                            color: context.colors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        return _ResultGroup(
          label:
              '${results.length} ${results.length == 1 ? 'LESSON' : 'LESSONS'}',
          children: [
            for (final hit in results) _HitRow(hit: hit, query: query),
          ],
        );
      },
    );
  }
}

class _ResultGroup extends StatelessWidget {
  const _ResultGroup({
    required this.label,
    required this.children,
    this.delay = Duration.zero,
  });
  final String label;
  final List<Widget> children;
  final Duration delay;

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(label),
            tween: Tween(begin: 0, end: 1),
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : Duration(milliseconds: 300 + delay.inMilliseconds),
            curve: Interval(
              delay.inMilliseconds / (300 + delay.inMilliseconds),
              1,
              curve: PantasCurves.houseOut,
            ),
            builder: (context, value, child) => Opacity(
              key: const ValueKey('search-results-opacity'),
              opacity: value,
              child: ExcludeFocus(
                excluding: value == 0,
                child: ExcludeSemantics(excluding: value == 0, child: child),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(label, style: context.type.sectionHeader),
                  ),
                ),
                const SizedBox(height: 7),
                GroupedSection(children: children),
              ],
            ),
          ),
        ],
      );
}

class _HitRow extends StatelessWidget {
  const _HitRow({required this.hit, required this.query});
  final LessonSearchHit hit;
  final String query;

  @override
  Widget build(BuildContext context) => ListRow(
        title: hit.title,
        richTitle: hit.titleMatch == null
            ? null
            : _spans(hit.titleMatch!, context.type.body),
        subtitle: hit.topicName,
        richSubtitle:
            buildSearchSnippet(source: hit.topicName, query: query) == null
                ? null
                : _spans(
                    buildSearchSnippet(source: hit.topicName, query: query)!,
                    context.type.footnote,
                  ),
        value: '${hit.estimatedMinutes} min',
        valueStyle: context.type.subhead.copyWith(
          color: context.colors.secondaryLabel,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        verticalPadding: 12,
        footer: hit.titleMatch == null && hit.bodySnippet != null
            ? Text.rich(
                _spans(
                  hit.bodySnippet!,
                  context.type.footnote,
                  matchColor: context.colors.label,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        onTap: () => context.push('/lesson/${hit.lessonId}?from=search'),
      );

  TextSpan _spans(SearchSnippet match, TextStyle style, {Color? matchColor}) {
    final start = match.matchStart;
    final end = start + match.matchLength;
    if (start < 0 || end > match.text.length) {
      return TextSpan(text: match.text, style: style);
    }
    return TextSpan(
      style: style,
      children: [
        TextSpan(text: match.text.substring(0, start)),
        TextSpan(
          text: match.text.substring(start, end),
          style: style.copyWith(fontWeight: FontWeight.w700, color: matchColor),
        ),
        TextSpan(text: match.text.substring(end)),
      ],
    );
  }
}
