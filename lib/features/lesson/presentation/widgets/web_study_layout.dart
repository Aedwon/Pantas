import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';

class WebStudyLayout extends ConsumerStatefulWidget {
  const WebStudyLayout({
    this.searchOnOpen = false,
    this.onSearchCancelled,
    super.key,
  });
  final bool searchOnOpen;
  final VoidCallback? onSearchCancelled;
  @override
  ConsumerState<WebStudyLayout> createState() => _WebStudyLayoutState();
}

class _WebStudyLayoutState extends ConsumerState<WebStudyLayout> {
  bool _saveFailed = false;
  String? _failedTopic;
  String? _bookmarkFailure;
  final _bookmarkPending = <String>{};
  @override
  void initState() {
    super.initState();
    if (widget.searchOnOpen) _openSearch();
  }

  @override
  void didUpdateWidget(WebStudyLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchOnOpen && !oldWidget.searchOnOpen) _openSearch();
  }

  void _openSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showWebLessonSearch(context);
      widget.onSearchCancelled?.call();
    });
  }

  Future<void> _openTopic(String id) async {
    try {
      await ref.read(openTopicProvider.notifier).open(id);
      if (mounted) setState(() => _saveFailed = false);
    } on Exception {
      if (mounted) {
        setState(() {
          _saveFailed = true;
          _failedTopic = id;
        });
      }
    }
  }

  Future<void> _bookmark(String id) async {
    if (!_bookmarkPending.add(id)) return;
    try {
      final reader = await ref.read(readerContextProvider(id).future);
      if (!mounted || reader == null || reader.boundary == null) return;
      bool current() =>
          mounted &&
          ref.read(activeExamFocusProvider).valueOrNull?.exam?.id ==
              reader.examId;
      await toggleBookmark(
        ref,
        id,
        boundary: reader.boundary!,
        isCurrent: current,
        bookmarked: !reader.isBookmarked,
      );
      if (mounted) setState(() => _bookmarkFailure = null);
    } on Exception {
      if (mounted) setState(() => _bookmarkFailure = id);
    } finally {
      _bookmarkPending.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(studyMapProvider);
    final map = value.valueOrNull;
    final last = ref.watch(lastOpenedLessonProvider).valueOrNull;
    final today =
        ref.watch(studyTodayLessonIdsProvider).valueOrNull ?? const <String>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: WebText('Study', kind: WebTextKind.h1),
        ),
        const SizedBox(height: 22),
        Expanded(
          child: value.when(
            loading: () => const WebStudyLoading(),
            error: (_, __) => WebStudyState(
              title: 'Could not load your topics.',
              isError: true,
              action: 'Try Again',
              onAction: () => ref.invalidate(studyMapProvider),
            ),
            data: (map) {
              if (map == null) {
                return WebStudyState(
                  title: 'Choose your exam',
                  detail: 'Pick the exam you are reviewing for.',
                  action: 'Choose Exam',
                  onAction: () => context.push('/settings/exam/change'),
                );
              }
              if (map.isEmpty) {
                final exam =
                    ref.watch(activeExamFocusProvider).valueOrNull?.exam;
                if (exam == null) {
                  return WebStudyState(
                    title: 'Choose your exam',
                    detail: 'Pick the exam you are reviewing for.',
                    action: 'Choose Exam',
                    onAction: () => context.push('/settings/exam/change'),
                  );
                }
                return WebStudyState(
                  title: 'Nothing to study yet',
                  detail:
                      'This exam has no lessons on your device yet. Check back '
                      'after the next content update.',
                  action: 'Try a Quick Quiz',
                  onAction: () => startQuickQuiz(context, examId: exam.id),
                );
              }
              return WebStudyMap(
                map: map,
                openTopicId: ref.watch(openTopicProvider).valueOrNull,
                today: today,
                lastLessonId: last?.id,
                lastTitle: last?.title,
                onTopic: (id) => unawaited(_openTopic(id)),
                onBookmark: (id) => unawaited(_bookmark(id)),
                onLesson: (id, {required resume}) => context.push(
                  '/lesson/$id?from=study${resume ? '&resume=true' : ''}',
                ),
                onBookmarks: () => showDialog<void>(
                  context: context,
                  builder: (context) => Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 480,
                      height: double.infinity,
                      child: Material(
                        child: BookmarksSheet(
                          wide: true,
                          onClose: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),
                ),
                saveFailed: _saveFailed,
                onRetry: () {
                  final id = _failedTopic;
                  if (id != null) unawaited(_openTopic(id));
                },
              );
            },
          ),
        ),
        if (_bookmarkFailure != null)
          WebButton(
            label: 'Try Saving Again',
            onPressed: () => unawaited(_bookmark(_bookmarkFailure!)),
          ),
        if (ref.watch(lastOpenedLessonProvider).hasError)
          WebButton(
            label: 'Try Again',
            variant: WebButtonVariant.tertiary,
            onPressed: () => ref.invalidate(lastOpenedLessonProvider),
          ),
        // Show plan failures alongside the usable study map.
        if (map != null && ref.watch(studyTodayLessonIdsProvider).hasError)
          WebButton(
            label: 'Try Loading Your Plan Again',
            variant: WebButtonVariant.tertiary,
            onPressed: () => ref.invalidate(studyTodayLessonIdsProvider),
          ),
      ],
    );
  }
}

/// W_Study: the map stays beside the selected topic, never expands in place.
class WebStudyMap extends StatelessWidget {
  const WebStudyMap({
    required this.map,
    required this.onTopic,
    required this.onLesson,
    required this.onBookmarks,
    this.openTopicId,
    this.onBookmark,
    this.today = const {},
    this.lastLessonId,
    this.lastTitle,
    this.saveFailed = false,
    this.onRetry,
    super.key,
  });
  final StudyMap map;
  final String? openTopicId;
  final Set<String> today;
  final String? lastLessonId;
  final String? lastTitle;
  final ValueChanged<String> onTopic;
  final ValueChanged<String>? onBookmark;
  final void Function(String, {required bool resume}) onLesson;
  final VoidCallback onBookmarks;
  final bool saveFailed;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    StudyTopic? selected;
    String? selectedSubject;
    String? lastTopic;
    final bookmarks = <StudyLesson>[];
    for (final subject in map.subjects) {
      for (final topic in subject.topics) {
        if (topic.id == openTopicId) {
          selected = topic;
          selectedSubject = subject.name;
        }
        for (final lesson in topic.lessons) {
          if (lesson.id == lastLessonId) lastTopic = topic.name;
          if (lesson.isBookmarked) bookmarks.add(lesson);
        }
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 340,
          child: ListView(
            key: const ValueKey('web-study-map'),
            children: [
              if (lastLessonId != null && lastTitle != null) ...[
                WebCard(
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LAST OPENED',
                              style: t.eb.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              lastTitle!,
                              style: t.style(17, weight: FontWeight.w600),
                            ),
                            if (lastTopic != null)
                              Text(
                                lastTopic,
                                style: t.style(
                                  14,
                                  color: t.colors.secondaryLabel,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      WebButton(
                        label: 'Resume',
                        variant: WebButtonVariant.secondary,
                        onPressed: () => onLesson(lastLessonId!, resume: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
              ],
              Row(
                children: [
                  Expanded(child: _label(context, 'BOOKMARKS')),
                  if (bookmarks.isNotEmpty)
                    TextButton(
                      onPressed: onBookmarks,
                      child: Text(
                        'See all',
                        style: t.style(
                          14,
                          color: t.colors.accent,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              if (bookmarks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    'Bookmark a lesson to keep it here.',
                    style: t.sm,
                  ),
                ),
              for (final lesson in bookmarks.take(3))
                _mapRow(
                  context,
                  lesson.title,
                  leading: Icon(
                    PantasIcons.bookmark,
                    size: 16,
                    color: t.colors.accent,
                  ),
                  onPressed: () => onLesson(lesson.id, resume: false),
                ),
              for (final subject in map.subjects) ...[
                const SizedBox(height: 18),
                _label(context, subject.name.toUpperCase()),
                for (final topic in subject.topics)
                  _mapRow(
                    context,
                    topic.name,
                    selected: topic.id == openTopicId,
                    leading: SizedBox.square(
                      dimension: 18,
                      child: topic.isComplete
                          ? Icon(
                              PantasIcons.check,
                              size: 18,
                              color: t.colors.accent,
                            )
                          : CircularProgressIndicator(
                              value: topic.totalCount == 0
                                  ? 0
                                  : topic.readCount / topic.totalCount,
                              strokeWidth: 2,
                              backgroundColor: t.colors.separator,
                              color: t.colors.accent,
                            ),
                    ),
                    onPressed: () => onTopic(topic.id),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: selected == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  key: const ValueKey('web-study-topic'),
                  child: WebCard(
                    padding: const EdgeInsets.fromLTRB(12, 30, 12, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedSubject!.toUpperCase(),
                                style: t.eb,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selected.name,
                                style: t.style(
                                  30,
                                  weight: FontWeight.w700,
                                  spacing: -.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final lesson in selected.lessons)
                          _WideStudyLessonRow(
                            lesson: lesson,
                            today: today.contains(lesson.id),
                            resume: lesson.id == lastLessonId,
                            onPressed: () => onLesson(
                              lesson.id,
                              resume: lesson.id == lastLessonId,
                            ),
                            onBookmark: onBookmark == null
                                ? null
                                : () => onBookmark!(lesson.id),
                          ),
                        if (saveFailed)
                          WebButton(
                            label: 'Try Saving Again',
                            onPressed: onRetry,
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _label(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        child: Text(label, style: context.webTokens.eb.copyWith(fontSize: 12)),
      );
  Widget _mapRow(
    BuildContext context,
    String title, {
    required Widget leading,
    required VoidCallback onPressed,
    bool selected = false,
  }) {
    final t = context.webTokens;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: selected ? t.colors.surface : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.style(
                15,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (selected)
            Icon(PantasIcons.next, size: 14, color: t.colors.tertiaryLabel),
        ],
      ),
    );
  }
}

class _WideStudyLessonRow extends StatefulWidget {
  const _WideStudyLessonRow({
    required this.lesson,
    required this.today,
    required this.resume,
    required this.onPressed,
    this.onBookmark,
  });
  final StudyLesson lesson;
  final bool today;
  final bool resume;
  final VoidCallback onPressed;
  final VoidCallback? onBookmark;
  @override
  State<_WideStudyLessonRow> createState() => _WideStudyLessonRowState();
}

class _WideStudyLessonRowState extends State<_WideStudyLessonRow> {
  bool _hover = false;
  bool _focus = false;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final lesson = widget.lesson;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Focus(
          onFocusChange: (value) => setState(() => _focus = value),
          child: WebRow(
            title: lesson.title,
            titleColor: lesson.isRead ? t.colors.tertiaryLabel : null,
            divider: false,
            compact: true,
            leading: SizedBox.square(
              dimension: 20,
              child: lesson.isRead
                  ? Icon(
                      PantasIcons.check,
                      size: 20,
                      color: t.colors.accent,
                    )
                  : null,
            ),
            titleSuffix: widget.today
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: t.colors.accentTint,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Today',
                      style: t.style(
                        12,
                        weight: FontWeight.w600,
                        color: t.tintText,
                      ),
                    ),
                  )
                : null,
            value: widget.resume
                ? 'Resume'
                : lesson.isRead
                    ? null
                    : '${lesson.estimatedMinutes} min',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onBookmark != null)
                  Opacity(
                    opacity: _hover || _focus || lesson.isBookmarked ? 1 : 0,
                    child: IconButton(
                      tooltip: lesson.isBookmarked
                          ? 'Remove bookmark'
                          : 'Bookmark ${lesson.title}',
                      onPressed: widget.onBookmark,
                      icon: Icon(
                        lesson.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 18,
                        color: lesson.isBookmarked
                            ? t.colors.accent
                            : t.colors.tertiaryLabel,
                      ),
                    ),
                  ),
                Icon(
                  PantasIcons.next,
                  size: 16,
                  color: t.colors.tertiaryLabel,
                ),
              ],
            ),
            onPressed: widget.onPressed,
          ),
        ),
      ),
    );
  }
}

class WebStudyState extends StatelessWidget {
  const WebStudyState({
    required this.title,
    this.detail,
    this.isError = false,
    this.action,
    this.onAction,
    super.key,
  });
  final String title;
  final bool isError;
  final String? detail;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: WebCard(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 140),
          child: Center(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError
                        ? Icons.warning_amber_rounded
                        : title == 'Choose your exam'
                            ? PantasIcons.exam
                            : PantasIcons.studyTab,
                    size: isError
                        ? 28
                        : title == 'Choose your exam'
                            ? 32
                            : 30,
                    color: context.webTokens.colors.tertiaryLabel,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: isError
                        ? context.webTokens.style(17)
                        : context.webTokens.h3,
                    textAlign: TextAlign.center,
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      detail!,
                      style: context.webTokens.sub,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (action != null) ...[
                    const SizedBox(height: 20),
                    WebButton(
                      label: action!,
                      onPressed: onAction,
                      variant: WebButtonVariant.secondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}

class WebStudyLoading extends StatefulWidget {
  const WebStudyLoading({super.key});
  @override
  State<WebStudyLoading> createState() => _WebStudyLoadingState();
}

class _WebStudyLoadingState extends State<WebStudyLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  Timer? _delay;
  bool _shown = false;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _delay = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _shown = true);
      if (!MediaQuery.disableAnimationsOf(context)) {
        _pulse.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shown) return const SizedBox.shrink();
    Widget shape(double height, double radius) => Container(
          height: height,
          decoration: BoxDecoration(
            color: context.webTokens.colors.skeleton,
            borderRadius: BorderRadius.circular(radius),
          ),
        );
    return Semantics(
      label: 'Loading study',
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Opacity(
          opacity: MediaQuery.disableAnimationsOf(context)
              ? 1
              : .5 + .5 * _pulse.value,
          child: child,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 340,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final height in [
                    76.0,
                    14.0,
                    36.0,
                    36.0,
                    36.0,
                    14.0,
                    36.0,
                    36.0,
                    36.0,
                    36.0,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: shape(
                        height,
                        height == 76
                            ? 16
                            : height == 14
                                ? 6
                                : 9,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(child: shape(640, 20)),
          ],
        ),
      ),
    );
  }
}
