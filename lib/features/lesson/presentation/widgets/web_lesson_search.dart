import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
// ds-raw: bare overlay input with no box
import 'package:pantas/core/ui/raw_controls.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_tap.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';

Future<void> showWebLessonSearch(BuildContext context) => showWebOverlay<void>(
      context: context,
      motion: WebOverlayMotion.popover,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      // The board's gray would lighten a dark page, so dark takes black, as
      // the other wide dialogs do.
      barrierColor: context.colors.scrimSearch,
      builder: (_) => const WebLessonSearch(),
    );

class WebLessonSearch extends ConsumerStatefulWidget {
  const WebLessonSearch({super.key});
  @override
  ConsumerState<WebLessonSearch> createState() => _WebLessonSearchState();
}

class _WebLessonSearchState extends ConsumerState<WebLessonSearch> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  int _selected = 0;
  String _query = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _open(String id) {
    final router = GoRouter.of(context);
    // The wide search is a dialog, so Esc from the lesson lands on the page it
    // was opened over, never on the search. The back label names that page.
    final from =
        router.routerDelegate.currentConfiguration.uri.path.startsWith('/home')
            ? 'home'
            : 'study';
    Navigator.pop(context);
    router.push('/lesson/$id?from=$from');
  }

  void _move(int delta, int length) {
    if (length == 0) return;
    setState(() => _selected = (_selected + delta).clamp(0, length - 1));
    if (_scroll.hasClients) {
      _scroll.jumpTo(
        (_selected * 68.0).clamp(0, _scroll.position.maxScrollExtent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final recent = ref.watch(recentlyOpenedLessonsProvider);
    final hits = ref.watch(searchResultsProvider);
    final map = ref.watch(studyMapProvider).valueOrNull;
    final topics = <String, String>{
      if (map != null)
        for (final subject in map.subjects)
          for (final topic in subject.topics)
            for (final lesson in topic.lessons) lesson.id: topic.name,
    };
    final results = _query.isEmpty
        ? [
            for (final lesson in (recent.valueOrNull ?? []).take(3))
              LessonSearchHit(
                lessonId: lesson.id,
                title: lesson.title,
                topicName: topics[lesson.id] ?? '',
                estimatedMinutes: lesson.estimatedMinutes,
              ),
          ]
        : hits.valueOrNull ?? <LessonSearchHit>[];
    final loading = _query.isEmpty ? recent.isLoading : hits.isLoading;
    final error = _query.isEmpty ? recent.hasError : hits.hasError;
    final lessonWord = results.length == 1 ? 'Lesson' : 'Lessons';
    final groupLabel =
        _query.isEmpty ? 'Recently Opened' : '${results.length} $lessonWord';
    final selected =
        results.isEmpty ? 0 : _selected.clamp(0, results.length - 1);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.pop(context),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
            _move(1, results.length),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
            _move(-1, results.length),
        const SingleActivator(
          LogicalKeyboardKey.enter,
          includeRepeats: false,
        ): () {
          if (results.isNotEmpty) _open(results[selected].lessonId);
        },
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: PantasLayout.searchTop),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PantasRadius.xl),
              boxShadow: context.shadows.modal,
            ),
            child: SizedBox(
              width: PantasLayout.search,
              child: Material(
                color: t.colors.surfaceModal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PantasRadius.xl),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: PantasSize.searchField,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s18,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: t.colors.divider,
                            width: PantasBorder.hairline,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PantasIcons.search,
                            size: 18,
                            color: t.colors.iconMuted,
                          ),
                          const SizedBox(width: PantasSpace.s12),
                          Expanded(
                            child: TextField(
                              // ds-raw: bare overlay input, no box
                              controller: _controller,
                              autofocus: true,
                              style: PantasType.webSearchInput.copyWith(
                                color: t.colors.textPrimary,
                              ),
                              decoration: InputDecoration.collapsed(
                                hintText: 'Search lessons and topics',
                                hintStyle: PantasType.webSearchInput.copyWith(
                                  color: t.colors.textSecondary,
                                ),
                              ),
                              onChanged: (query) {
                                setState(() {
                                  _selected = 0;
                                  _query = query.trim();
                                });
                                ref
                                    .read(
                                      searchQueryProvider.notifier,
                                    )
                                    .state = query;
                              },
                            ),
                          ),
                          const WebKeyHint('Esc'),
                        ],
                      ),
                    ),
                    if (error)
                      Padding(
                        padding: const EdgeInsets.all(PantasSpace.s28),
                        child: WebButton(
                          label: 'Try Again',
                          onPressed: () => ref.invalidate(
                            _query.isEmpty
                                ? recentlyOpenedLessonsProvider
                                : searchResultsProvider,
                          ),
                        ),
                      )
                    else if (loading)
                      const Padding(
                        padding: EdgeInsets.all(PantasSpace.s12),
                        child: SkeletonGroups(
                          groups: 1,
                          rows: 4,
                          rowHeight: 63,
                          header: false,
                        ),
                      )
                    else if (_query.isNotEmpty && results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PantasSpace.s24,
                          vertical: PantasSpace.s44,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Nothing matched “$_query”',
                              style: PantasType.webTitleSm.copyWith(
                                color: t.colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: PantasSpace.s12),
                            Text(
                              'Try a shorter word, or part of one.',
                              style: t.sub,
                            ),
                          ],
                        ),
                      )
                    else if (results.isNotEmpty)
                      _resultList(t, results, selected, groupLabel),
                    // The board's "nothing matched" panel has no key footer,
                    // and neither has an empty list: nothing to move through
                    // (2G-5).
                    if (results.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PantasSpace.s18,
                          vertical: PantasSpace.s10,
                        ),
                        decoration: BoxDecoration(
                          color: t.colors.surfaceInset,
                          border: Border(
                            top: BorderSide(
                              color: t.colors.divider,
                              width: PantasBorder.hairline,
                            ),
                          ),
                        ),
                        // Decorative: the field already speaks the keys.
                        child: ExcludeSemantics(
                          child: Text(
                            'Up and Down to move, Enter to open, '
                            'Esc to close',
                            style: t.sm,
                          ),
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

  Widget _resultList(
    WebTokens t,
    List<LessonSearchHit> results,
    int selected,
    String groupLabel,
  ) {
    return Flexible(
      // The group fades in as the phone's does: 300 ms, and
      // the recent list 100 ms later. A new label fades again.
      child: SearchGroupFade(
        key: ValueKey(groupLabel),
        delay:
            _query.isEmpty ? const Duration(milliseconds: 100) : Duration.zero,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 480,
          ),
          child: ListView(
            controller: _scroll,
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s8,
              PantasSpace.s10,
              PantasSpace.s8,
              PantasSpace.s8,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s12,
                  PantasSpace.s6,
                  PantasSpace.s12,
                  PantasSpace.s6,
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(groupLabel, style: t.eb),
                ),
              ),
              for (var i = 0; i < results.length; i++)
                Semantics(
                  key: ValueKey(
                    'web-search-result-${results[i].lessonId}',
                  ),
                  selected: i == selected,
                  child: ReaderTap(
                    onTap: () => _open(results[i].lessonId),
                    selectedFill:
                        i == selected ? t.colors.surfaceModalHover : null,
                    hoverFill: t.colors.surfaceModalHover,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s12,
                        vertical: PantasSpace.s10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Every title wraps to two lines, then ends
                                // in an ellipsis, so rows behave alike.
                                Text.rich(
                                  _highlight(
                                    results[i].titleMatch,
                                    results[i].title,
                                    PantasType.webTitleSm
                                        .copyWith(color: t.colors.textPrimary),
                                    context,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  results[i].topicName,
                                  style: _small(t),
                                ),
                                if (results[i].bodySnippet != null)
                                  Text.rich(
                                    _highlight(
                                      results[i].bodySnippet,
                                      '',
                                      _small(t),
                                      context,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: PantasSpace.s12,
                          ),
                          Text(
                            '${results[i].estimatedMinutes} min',
                            style: PantasType.webRowValue.copyWith(
                              color: t.colors.textSecondary,
                            ),
                          ),
                          if (i == selected) ...[
                            const SizedBox(
                              width: PantasSpace.s12,
                            ),
                            const WebKeyHint(
                              'Enter',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _small(WebTokens t) =>
      PantasType.webRowSub.copyWith(color: t.colors.textSecondary);

  TextSpan _highlight(
    SearchSnippet? match,
    String fallback,
    TextStyle style,
    BuildContext context,
  ) {
    if (match == null) return TextSpan(text: fallback, style: style);
    final start = match.matchStart;
    final end = start + match.matchLength;
    if (start < 0 || end > match.text.length) {
      return TextSpan(text: match.text, style: style);
    }
    final t = context.webTokens;
    return TextSpan(
      style: style,
      children: [
        TextSpan(text: match.text.substring(0, start)),
        TextSpan(
          text: match.text.substring(start, end),
          style: TextStyle(
            color: t.tintText,
            backgroundColor: t.colors.accentTint,
          ),
        ),
        TextSpan(text: match.text.substring(end)),
      ],
    );
  }
}
