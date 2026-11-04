import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';

Future<void> showWebLessonSearch(BuildContext context) => showWebOverlay<void>(
      context: context,
      motion: WebOverlayMotion.popover,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      // The board's gray would lighten a dark page, so dark takes black, as
      // the other wide dialogs do.
      barrierColor: context.webTokens.dark
          ? Colors.black.withValues(alpha: .28)
          : const Color(0x381D1D1F),
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
    final lessonWord = results.length == 1 ? 'LESSON' : 'LESSONS';
    final groupLabel =
        _query.isEmpty ? 'RECENTLY OPENED' : '${results.length} $lessonWord';
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
          padding: const EdgeInsets.only(top: 110),
          child: SizedBox(
            width: 640,
            child: Material(
              color: t.colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: t.cardEdge),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: t.colors.separator,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          PantasIcons.search,
                          size: 18,
                          color: t.colors.tertiaryLabel,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            style: t.style(19),
                            decoration: InputDecoration.collapsed(
                              hintText: 'Search lessons and topics',
                              hintStyle: t.style(
                                19,
                                color: t.colors.tertiaryLabel,
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
                      padding: const EdgeInsets.all(28),
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
                      padding: EdgeInsets.all(12),
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
                        horizontal: 24,
                        vertical: 44,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Nothing matched “$_query”',
                            style: t.style(
                              17,
                              weight: FontWeight.w600,
                              height: 22 / 17,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Try a shorter word, or part of one.',
                            style: t.sub,
                          ),
                        ],
                      ),
                    )
                  else
                    _resultList(t, results, selected, groupLabel),
                  // The board's "nothing matched" panel has no key footer.
                  if (_query.isEmpty || results.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: t.colors.separator,
                          ),
                        ),
                      ),
                      child: Text(
                        '↑ ↓ to move · Enter to open',
                        style: t.sm,
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
              8,
              10,
              8,
              8,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  6,
                  12,
                  6,
                ),
                child: Text(
                  groupLabel,
                  style: t.eb.copyWith(
                    fontSize: 12,
                  ),
                ),
              ),
              for (var i = 0; i < results.length; i++)
                Semantics(
                  key: ValueKey(
                    'web-search-result-${results[i].lessonId}',
                  ),
                  selected: i == selected,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: i == selected
                          ? t.colors.accentTint
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () => _open(
                        results[i].lessonId,
                      ),
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.standard,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
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
                                    t.style(17, height: 22 / 17),
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
                            width: 12,
                          ),
                          Text(
                            '${results[i].estimatedMinutes} min',
                            style: t.sub,
                          ),
                          if (i == selected) ...[
                            const SizedBox(
                              width: 12,
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
      t.style(14, height: 18 / 14, color: t.colors.secondaryLabel);

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
