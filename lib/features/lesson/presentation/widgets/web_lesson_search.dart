import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/application/lesson_search_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/lesson_search_hit.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_search_snippet.dart';

Future<void> showWebLessonSearch(BuildContext context) => showDialog<void>(
      context: context,
      barrierColor: const Color(0x381D1D1F),
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
    Navigator.pop(context);
    router.push('/lesson/$id?from=search');
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
        const SingleActivator(LogicalKeyboardKey.enter): () {
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
                          width: .5,
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
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_query.isNotEmpty && results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(38),
                      child: Column(
                        children: [
                          Text(
                            'Nothing matched “$_query”',
                            style: t.h3,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try a shorter word, or part of one.',
                            style: t.sub,
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
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
                                _query.isEmpty
                                    ? 'RECENTLY OPENED'
                                    : '${results.length} $lessonWord',
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text.rich(
                                                _highlight(
                                                  results[i].titleMatch,
                                                  results[i].title,
                                                  t.style(
                                                    17,
                                                    weight: FontWeight.w600,
                                                  ),
                                                  context,
                                                ),
                                              ),
                                              Text(
                                                results[i].topicName,
                                                style: t.sm,
                                              ),
                                              if (results[i].bodySnippet !=
                                                  null)
                                                Text.rich(
                                                  _highlight(
                                                    results[i].bodySnippet,
                                                    '',
                                                    t.sm,
                                                    context,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: t.colors.separator,
                          width: .5,
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
