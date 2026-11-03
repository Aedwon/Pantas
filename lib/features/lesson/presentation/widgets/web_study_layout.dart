import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
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
        const SizedBox(height: 26),
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
                if (ref.watch(contentLimitReachedProvider)) {
                  return const StateView(
                    message: contentLimitMessage,
                    boardLayout: true,
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
              // The list takes the whole width until a topic is open, so wait
              // for the saved topic rather than flash the wrong layout.
              final openTopic = ref.watch(openTopicProvider);
              if (!openTopic.hasValue && !openTopic.hasError) {
                return const WebStudyLoading();
              }
              return WebStudyMap(
                map: map,
                openTopicId: openTopic.valueOrNull,
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
                  barrierColor: const Color(0x381D1D1F),
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
    final hasCard = lastLessonId != null && lastTitle != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        // The board's map column grows from 300 px by a thousandth of the
        // spare width, up to 340.
        final column =
            (300 + (constraints.maxWidth - 784).clamp(0, 40000) / 1000)
                .clamp(300.0, 340.0);
        // Above the subjects: the Last opened card, then Bookmarks. Bookmarks
        // is drawn only once there is a bookmark (Nov 3, item 4).
        final head = <Widget>[
          if (hasCard) ...[
            WebLastOpenedCard(
              title: lastTitle!,
              topic: lastTopic,
              onResume: () => onLesson(lastLessonId!, resume: true),
            ),
            const SizedBox(height: 22),
          ],
          if (bookmarks.isNotEmpty) ..._bookmarkRows(context, bookmarks),
        ];
        // The first subject sits flush under the card when Bookmarks is
        // hidden, and 18 px under Bookmarks when it shows.
        final firstGap = bookmarks.isEmpty ? 0.0 : 18.0;
        if (selected == null) {
          return ListView(
            key: const ValueKey('web-study-map'),
            children: [
              if (head.isNotEmpty)
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: column,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: head,
                    ),
                  ),
                ),
              if (bookmarks.isNotEmpty) const SizedBox(height: 18),
              _subjectColumns(context, map.subjects),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: column,
              child: ListView(
                key: const ValueKey('web-study-map'),
                children: [
                  ...head,
                  for (final (index, subject) in map.subjects.indexed) ...[
                    SizedBox(height: index == 0 ? firstGap : 18),
                    ..._subjectBlock(context, subject),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SingleChildScrollView(
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
                              style: t.eb.copyWith(height: 1.45),
                            ),
                            Text(
                              selected.name,
                              style: t.style(
                                30,
                                weight: FontWeight.w700,
                                height: 1.2,
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
      },
    );
  }

  /// Subjects in two columns across the full width, for when no topic is
  /// open (preview study-reader section 1, Option A). A subject never splits
  /// across columns. The columns balance like CSS columns: the first column
  /// takes as many whole subjects as it can without the page growing taller
  /// than the shortest balanced split.
  Widget _subjectColumns(BuildContext context, List<StudySubject> subjects) {
    // Row 36 px, label 21 px, 18 px between subjects. Only the order of the
    // heights matters, so the label is an estimate.
    double height(Iterable<StudySubject> group) =>
        group.fold<double>(
          0,
          (sum, subject) => sum + 21 + subject.topics.length * 36,
        ) +
        18 * (group.length - 1).clamp(0, subjects.length);
    var split = subjects.length;
    var best = double.infinity;
    for (var k = 1; k < subjects.length; k++) {
      final taller = math.max(
        height(subjects.take(k)),
        height(subjects.skip(k)),
      );
      // A tie keeps more subjects in the first column.
      if (taller <= best) {
        best = taller;
        split = k;
      }
    }
    Widget stack(List<StudySubject> group) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final subject in group) ...[
              ..._subjectBlock(context, subject),
              const SizedBox(height: 18),
            ],
          ],
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: stack(subjects.take(split).toList())),
        const SizedBox(width: 24),
        Expanded(child: stack(subjects.skip(split).toList())),
      ],
    );
  }

  List<Widget> _bookmarkRows(
    BuildContext context,
    List<StudyLesson> bookmarks,
  ) {
    final t = context.webTokens;
    return [
      Row(
        children: [
          Expanded(child: _label(context, 'BOOKMARKS')),
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
      for (final lesson in bookmarks.take(3))
        _mapRow(
          context,
          lesson.title,
          leading: Icon(PantasIcons.bookmark, size: 16, color: t.colors.accent),
          onPressed: () => onLesson(lesson.id, resume: false),
        ),
    ];
  }

  List<Widget> _subjectBlock(BuildContext context, StudySubject subject) {
    final t = context.webTokens;
    return [
      _label(context, subject.name.toUpperCase()),
      for (final topic in subject.topics)
        _mapRow(
          context,
          topic.name,
          selected: topic.id == openTopicId,
          leading: SizedBox.square(
            dimension: 18,
            child: topic.isComplete
                ? Icon(PantasIcons.check, size: 18, color: t.colors.accent)
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
    ];
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
        visualDensity: VisualDensity.standard,
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
                weight: selected ? FontWeight.w600 : FontWeight.w500,
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

/// The Last opened card (board SD_MapEmpty).
class WebLastOpenedCard extends StatelessWidget {
  const WebLastOpenedCard({
    required this.title,
    required this.onResume,
    this.topic,
    super.key,
  });
  final String title;
  final String? topic;
  final VoidCallback onResume;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return WebCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      // Resume sits under the text at its natural width, so a long title and
      // topic wrap in full (preview study-reader, section 2 Option A).
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('LAST OPENED', style: t.eb.copyWith(fontSize: 12)),
                const SizedBox(height: 3),
                Text(title, style: t.style(17, weight: FontWeight.w600)),
                if (topic != null)
                  Text(
                    topic!,
                    style: t.style(14, color: t.colors.secondaryLabel),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          WebButton(
            label: 'Resume',
            variant: WebButtonVariant.secondary,
            onPressed: onResume,
          ),
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
    final value = widget.resume
        ? 'Resume'
        : lesson.isRead
            ? null
            : '${lesson.estimatedMinutes} min';
    final valuePainter = TextPainter(
      text: TextSpan(text: value ?? '', style: t.sub),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final valueWidth = valuePainter.width;
    valuePainter.dispose();
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Focus(
          onFocusChange: (value) => setState(() => _focus = value),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              WebRow(
                title: lesson.title,
                titleColor: lesson.isRead ? t.colors.tertiaryLabel : null,
                divider: false,
                compact: true,
                leadingGap: 14,
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
                value: value,
                trailing: Icon(
                  PantasIcons.next,
                  size: 16,
                  color: t.colors.tertiaryLabel,
                ),
                onPressed: widget.onPressed,
              ),
              if (widget.onBookmark != null)
                Padding(
                  // Sits left of the minutes: row padding, chevron, gaps and
                  // the value's own width, so the board's row stays as drawn.
                  padding:
                      EdgeInsets.only(right: 20 + 16 + 12 + valueWidth + 8),
                  child: Opacity(
                    opacity: _hover || _focus || lesson.isBookmarked ? 1 : 0,
                    child: Tooltip(
                      message: lesson.isBookmarked
                          ? 'Remove bookmark'
                          : 'Bookmark ${lesson.title}',
                      child: InkResponse(
                        onTap: widget.onBookmark,
                        radius: 16,
                        child: SizedBox.square(
                          dimension: 32,
                          child: Icon(
                            lesson.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 18,
                            color: lesson.isBookmarked
                                ? t.colors.accent
                                // W_Study: lesson-row bookmark is #8A8A8E.
                                : t.dark
                                    ? t.colors.tertiaryLabel
                                    : const Color(0xFF8A8A8E),
                          ),
                        ),
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

/// The Study map before it loads: a bookmarks line, then each subject's label
/// and topic rows in the 340 wide map column. The topic pane is empty until a
/// topic is opened, so it has no placeholder.
class WebStudyLoading extends StatelessWidget {
  const WebStudyLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final line = skeletonLineHeight(
      context.webTokens.eb.copyWith(fontSize: 12),
    );
    Widget label(double width) => Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: SizedBox(
            height: line,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SkeletonBlock(width: width, height: 11),
            ),
          ),
        );
    Widget row() => const SizedBox(
          height: 36,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                SkeletonBlock(width: 18, height: 18, radius: 9),
                SizedBox(width: 10),
                SkeletonBlock(width: 170, height: 13),
              ],
            ),
          ),
        );
    return SkeletonPulse(
      label: 'Loading study',
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              label(90),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: SkeletonBlock(width: 220, height: 14),
              ),
              for (var subject = 0; subject < 2; subject++) ...[
                const SizedBox(height: 18),
                label(120),
                for (var topic = 0; topic < 4; topic++) row(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
