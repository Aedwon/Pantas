import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/check_mark.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pane_transition.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/lesson/application/bookmark_providers.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/models/study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_tap.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_map_entry.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';

/// The width of the study list skeleton (board value, no token).
const double _skeletonWidth = 340;

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

  /// True while the Bookmarks drawer is open, so the page behind it recedes.
  bool _bookmarksOpen = false;
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

  Future<void> _openBookmarks() async {
    setState(() => _bookmarksOpen = true);
    await showWebOverlay<void>(
      context: context,
      motion: WebOverlayMotion.drawerOf(PantasLayout.drawer),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: context.colors.scrim,
      builder: (context) => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: PantasLayout.drawer,
          height: double.infinity,
          child: Material(
            child: BookmarksSheet(
              wide: true,
              onClose: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
    // The route reports its pop as the drawer starts to leave, so the page
    // comes back in step with it.
    if (mounted) setState(() => _bookmarksOpen = false);
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
  Widget build(BuildContext context) =>
      _PageRecede(receded: _bookmarksOpen, child: _page(context));

  Widget _page(BuildContext context) {
    final value = ref.watch(studyMapProvider);
    final map = value.valueOrNull;
    final last = ref.watch(lastOpenedLessonProvider).valueOrNull;
    final today =
        ref.watch(studyTodayLessonIdsProvider).valueOrNull ?? const <String>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: PantasSpace.s4),
          child: WebText('Study', kind: WebTextKind.h1),
        ),
        const SizedBox(height: PantasSpace.s24),
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
                bookmarkOrder: [
                  for (final row
                      in ref.watch(bookmarkRowsProvider).valueOrNull ??
                          const <BookmarkRow>[])
                    row.lessonId,
                ],
                onTopic: (id) => unawaited(_openTopic(id)),
                onBookmark: (id) => unawaited(_bookmark(id)),
                onLesson: (id, {required resume}) => context.push(
                  '/lesson/$id?from=study${resume ? '&resume=true' : ''}',
                ),
                onBookmarks: () => unawaited(_openBookmarks()),
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

/// The page behind the Bookmarks drawer, as the phone's sheet leaves it: it
/// shifts 10 px down and scales to .985 over 450 ms in and 400 ms out,
/// `slideA`. With reduced motion it changes at once. Only a transform moves,
/// so the page is not laid out again.
class _PageRecede extends StatelessWidget {
  const _PageRecede({required this.receded, required this.child});
  final bool receded;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: receded ? 1.0 : 0.0),
      duration:
          still ? Duration.zero : Duration(milliseconds: receded ? 450 : 400),
      curve: PantasCurves.scroll,
      child: child,
      builder: (context, progress, child) => Transform.translate(
        key: const ValueKey('web-study-page-shift'),
        offset: Offset(0, 10 * progress),
        child: Transform.scale(
          key: const ValueKey('web-study-page-scale'),
          scale: 1 - .015 * progress,
          child: child,
        ),
      ),
    );
  }
}

/// W_Study: the map stays beside the selected topic, never expands in place.
class WebStudyMap extends StatefulWidget {
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
    this.bookmarkOrder = const [],
    this.saveFailed = false,
    this.onRetry,
    super.key,
  });
  final StudyMap map;
  final String? openTopicId;
  final Set<String> today;
  final String? lastLessonId;
  final String? lastTitle;

  /// Bookmarked lessons in the order the student chose in the bookmarks panel,
  /// newest first by default. The map's own order is subject order.
  final List<String> bookmarkOrder;
  final ValueChanged<String> onTopic;
  final ValueChanged<String>? onBookmark;
  final void Function(String, {required bool resume}) onLesson;
  final VoidCallback onBookmarks;
  final bool saveFailed;
  final VoidCallback? onRetry;
  @override
  State<WebStudyMap> createState() => _WebStudyMapState();
}

class _WebStudyMapState extends State<WebStudyMap>
    with SingleTickerProviderStateMixin {
  /// The parts that stand on the map's first frame. Each comes in once, on the
  /// phone's delays. A part that arrives later, or that has finished, is just
  /// there, so scrolling it back in or opening a topic never replays it.
  final _entering = <String>{};
  final _keys = <String, GlobalKey>{};

  /// One key for each subject's block, so the block keeps its rings, marks and
  /// focus when opening or closing a topic moves it to the other layout.
  final _blockKeys = <String, GlobalKey>{};

  /// One key for the map's list, so its scroll position goes with it.
  final _listKey = GlobalKey();

  /// Topics already shown as done. A mark pops only for one that becomes done,
  /// or arrives done with the map.
  final _doneTopics = <String>{};
  bool _settled = false;

  /// Opening or closing a topic changes the columns, and subjects must not
  /// travel across each other to get there. The whole map fades out, takes its
  /// new layout while unseen, and fades back in: the approved view swap, 240
  /// ms in all (out over the first 100 ms, in over the rest).
  late final AnimationController _swap;
  bool _swapping = false;
  bool _swapped = false;
  bool _shownOpen = false;
  ({StudyTopic topic, String subject})? _card;

  static const double _swapOutMs = 100;
  static final double _swapMs =
      PantasDurations.medium1.inMilliseconds.toDouble();

  @override
  void initState() {
    super.initState();
    _swap = AnimationController(vsync: this, duration: PantasDurations.medium1)
      ..addListener(_swapTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _swapping = false);
        }
      });
    _doneTopics.addAll(_doneIn(widget.map));
    WidgetsBinding.instance.addPostFrameCallback((_) => _settled = true);
  }

  Iterable<String> _doneIn(StudyMap map) => [
        for (final subject in map.subjects)
          for (final topic in subject.topics)
            if (topic.isComplete) topic.id,
      ];

  @override
  void didUpdateWidget(WebStudyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.openTopicId == null) != (widget.openTopicId == null) &&
        !MediaQuery.disableAnimationsOf(context)) {
      // Until the map is unseen, it keeps the layout it had. A change that
      // lands before that is picked up there.
      if (_swapping && !_swapped) return;
      _swapping = true;
      _swapped = false;
      unawaited(_swap.forward(from: 0));
    }
  }

  void _swapTick() {
    if (_swapped || _swap.value * _swapMs < _swapOutMs) return;
    _swapped = true;
    setState(() => _shownOpen = widget.openTopicId != null);
  }

  double get _swapOpacity {
    if (!_swapping) return 1;
    final ms = _swap.value * _swapMs;
    if (!_swapped) {
      return 1 - PantasCurves.fade.transform((ms / _swapOutMs).clamp(0.0, 1.0));
    }
    return PantasCurves.move.transform(
      ((ms - _swapOutMs) / (_swapMs - _swapOutMs)).clamp(0.0, 1.0),
    );
  }

  @override
  void dispose() {
    _swap.dispose();
    super.dispose();
  }

  /// [child] entering as the phone's [delayMs] says. The key follows it from
  /// the full-width list to the list beside a topic, so it does not restart.
  Widget _enter(String slot, int delayMs, Widget child) {
    if (!_settled) _entering.add(slot);
    if (!_entering.contains(slot)) return child;
    return StudyMapEntry(
      key: _keys.putIfAbsent(slot, GlobalKey.new),
      delay: Duration(milliseconds: delayMs),
      onEnd: () => _entering.remove(slot),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final map = widget.map;
    final openTopicId = widget.openTopicId;
    final lastLessonId = widget.lastLessonId;
    final lastTitle = widget.lastTitle;
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
    if (widget.bookmarkOrder.isNotEmpty) {
      final rank = {
        for (final (index, id) in widget.bookmarkOrder.indexed) id: index,
      };
      final walk = {
        for (final (index, lesson) in bookmarks.indexed) lesson.id: index,
      };
      // A lesson the order does not name keeps its place at the end.
      int key(StudyLesson lesson) =>
          rank[lesson.id] ?? rank.length + walk[lesson.id]!;
      bookmarks.sort((a, b) => key(a).compareTo(key(b)));
    }
    final hasCard = lastLessonId != null && lastTitle != null;
    if (selected != null) _card = (topic: selected, subject: selectedSubject!);
    if (!_swapping) _shownOpen = selected != null;
    // The topic card in view. While the map fades out for a closing topic it
    // is the one just left, drawn in its last layout.
    final card = _shownOpen ? _card : null;
    // A mark pops once, when its topic becomes done. After this frame it is
    // simply there.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _doneTopics.addAll(_doneIn(widget.map)),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // The board's map column grows from 300 px by a thousandth of the
        // spare width, up to 340.
        final column =
            (300 + (constraints.maxWidth - 784).clamp(0, 40000) / 1000)
                .clamp(300.0, 340.0);
        // Beside an open topic, above the subjects: the Last opened card,
        // then Bookmarks, in the map column. Bookmarks is drawn only once
        // there is a bookmark (Nov 3, item 4).
        Widget lastCard({required bool strip}) => _enter(
              'last',
              180,
              WebLastOpenedCard(
                title: lastTitle!,
                topic: lastTopic,
                strip: strip,
                onResume: () => widget.onLesson(lastLessonId!, resume: true),
              ),
            );
        List<Widget> head() => <Widget>[
              if (hasCard) ...[
                lastCard(strip: false),
                const SizedBox(height: PantasSpace.s20),
              ],
              if (bookmarks.isNotEmpty)
                _enter(
                  'bookmarks',
                  260,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _bookmarkRows(context, bookmarks),
                  ),
                ),
            ];
        // The first subject sits flush under the card when Bookmarks is
        // hidden, and 18 px under Bookmarks when it shows.
        final firstGap = bookmarks.isEmpty ? 0.0 : 18.0;
        // The list is one widget in either layout, so it keeps its scroll
        // position through the change.
        Widget mapList(List<Widget> children) => KeyedSubtree(
              key: _listKey,
              child: ListView(
                key: const ValueKey('web-study-map'),
                padding: EdgeInsets.only(bottom: context.webPageBottomInset),
                children: children,
              ),
            );
        final Widget layout;
        if (card == null) {
          // Nothing open: the Last opened card is a full-width strip, with
          // Bookmarks in the same two columns as the subjects below it (QA
          // polish board, option C).
          layout = mapList([
            if (hasCard) ...[
              lastCard(strip: true),
              const SizedBox(height: PantasSpace.s20),
            ],
            if (bookmarks.isNotEmpty) ...[
              _enter(
                'bookmarks',
                260,
                _wideBookmarks(context, bookmarks),
              ),
              const SizedBox(height: PantasSpace.s18),
            ],
            _subjectColumns(context, map.subjects),
          ]);
        } else {
          layout = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: column,
                child: FocusTraversalGroup(
                  child: mapList([
                    ...head(),
                    for (final (index, subject) in map.subjects.indexed) ...[
                      SizedBox(height: index == 0 ? firstGap : 18),
                      _subjectBlock(context, subject, index),
                    ],
                  ]),
                ),
              ),
              const SizedBox(width: PantasSpace.s24),
              Expanded(
                child: FocusTraversalGroup(
                  child: SingleChildScrollView(
                    key: const ValueKey('web-study-topic'),
                    padding:
                        EdgeInsets.only(bottom: context.webPageBottomInset),
                    child: _TopicSwap(
                      topicId: card.topic.id,
                      child: WebCard(
                        padding: const EdgeInsets.fromLTRB(
                          PantasSpace.s12,
                          PantasSpace.s28,
                          PantasSpace.s12,
                          PantasSpace.s18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                PantasSpace.s20,
                                PantasSpace.s0,
                                PantasSpace.s20,
                                PantasSpace.s18,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.subject.toUpperCase(),
                                    style: t.eb.copyWith(height: 1.45),
                                  ),
                                  Text(
                                    card.topic.name,
                                    style: PantasType.webH2
                                        .copyWith(color: t.colors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            for (final lesson in card.topic.lessons)
                              _WideStudyLessonRow(
                                key: ValueKey(lesson.id),
                                lesson: lesson,
                                today: widget.today.contains(lesson.id),
                                resume: lesson.id == lastLessonId,
                                onPressed: () => widget.onLesson(
                                  lesson.id,
                                  resume: lesson.id == lastLessonId,
                                ),
                                onBookmark: widget.onBookmark == null
                                    ? null
                                    : () => widget.onBookmark!(lesson.id),
                              ),
                            if (widget.saveFailed)
                              WebButton(
                                label: 'Try Saving Again',
                                onPressed: widget.onRetry,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return AnimatedBuilder(
          animation: _swap,
          child: layout,
          builder: (context, child) =>
              Opacity(opacity: _swapOpacity, child: child),
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
              _subjectBlock(context, subject, subjects.indexOf(subject)),
              const SizedBox(height: PantasSpace.s18),
            ],
          ],
        );
    // Each column is its own focus group, so Tab walks all of the first
    // column, then the second, rather than across both row by row.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FocusTraversalGroup(
            child: stack(subjects.take(split).toList()),
          ),
        ),
        const SizedBox(width: PantasSpace.s24),
        Expanded(
          child: FocusTraversalGroup(
            child: stack(subjects.skip(split).toList()),
          ),
        ),
      ],
    );
  }

  /// Bookmarks across the full width: the label and See all on one line, then
  /// the rows in the subjects' two columns, 24 px apart (QA polish board,
  /// option C). The label sits 4 px above the first row.
  Widget _wideBookmarks(BuildContext context, List<StudyLesson> bookmarks) {
    final t = context.webTokens;
    final shown = bookmarks.take(3).toList();
    Widget cell(StudyLesson? lesson) => Expanded(
          child: lesson == null
              ? const SizedBox.shrink()
              : _mapRow(
                  context,
                  lesson.title,
                  leading: Icon(
                    PantasIcons.bookmark,
                    size: 16,
                    color: t.colors.accent,
                  ),
                  onPressed: () => widget.onLesson(lesson.id, resume: false),
                ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s12,
            PantasSpace.s0,
            PantasSpace.s12,
            PantasSpace.s4,
          ),
          // A fixed 20px header (the link's line), so the label sits at the
          // same place whatever the platform's text metrics.
          child: SizedBox(
            height: PantasSpace.s20,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'BOOKMARKS',
                    style: t.eb,
                  ),
                ),
                WebTextLink(
                  label: 'See all',
                  arrow: false,
                  onPressed: widget.onBookmarks,
                ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < shown.length; i += 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cell(shown[i]),
              const SizedBox(width: PantasSpace.s24),
              cell(i + 1 < shown.length ? shown[i + 1] : null),
            ],
          ),
      ],
    );
  }

  List<Widget> _bookmarkRows(
    BuildContext context,
    List<StudyLesson> bookmarks,
  ) {
    final t = context.webTokens;
    return [
      SizedBox(
        height: PantasSpace.s20,
        child: Row(
          children: [
            Expanded(child: _label(context, 'BOOKMARKS')),
            WebTextLink(
              label: 'See all',
              arrow: false,
              onPressed: widget.onBookmarks,
            ),
          ],
        ),
      ),
      for (final lesson in bookmarks.take(3))
        _mapRow(
          context,
          lesson.title,
          leading: Icon(PantasIcons.bookmark, size: 16, color: t.colors.accent),
          onPressed: () => widget.onLesson(lesson.id, resume: false),
        ),
    ];
  }

  /// A subject's label and topics, entering on the phone's delay for the
  /// subject at [index]: 520 ms, then 120 ms for each one after it. The rings
  /// fill 300 ms after the subject arrives, as on the phone.
  Widget _subjectBlock(BuildContext context, StudySubject subject, int index) {
    final t = context.webTokens;
    final slot = 'subject-${subject.id}';
    // A ring fills in only with the subject's first arrival. One that is
    // built again later (scrolled back into view) stands at its fraction.
    final arriving = !_settled || _entering.contains(slot);
    return _enter(
      slot,
      520 + 120 * index,
      KeyedSubtree(
        key: _blockKeys.putIfAbsent(slot, GlobalKey.new),
        child: RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _label(context, subject.name.toUpperCase()),
              for (final topic in subject.topics)
                _mapRow(
                  context,
                  topic.name,
                  selected: topic.id == widget.openTopicId,
                  leading: SizedBox.square(
                    dimension: 18,
                    child: topic.isComplete
                        ? CheckMark.glyph(
                            key: ValueKey('study-done-${topic.id}'),
                            size: 18,
                            color: t.colors.accent,
                            animate:
                                arriving || !_doneTopics.contains(topic.id),
                            // Under the subject's entrance, so the pop starts
                            // once the row shows, with the ring beside it.
                            delay: arriving && _doneTopics.contains(topic.id)
                                ? Duration(milliseconds: 820 + 120 * index)
                                : Duration.zero,
                          )
                        : ProgressRing.study(
                            key: ValueKey('study-ring-${topic.id}'),
                            size: 18,
                            fraction: topic.totalCount == 0
                                ? 0
                                : topic.readCount / topic.totalCount,
                            delay: Duration(milliseconds: 820 + 120 * index),
                            animateIn: arriving,
                          ),
                  ),
                  onPressed: () => widget.onTopic(topic.id),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String label) => Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s12,
          PantasSpace.s0,
          PantasSpace.s12,
          PantasSpace.s6,
        ),
        child: Text(label, style: context.webTokens.eb),
      );
  Widget _mapRow(
    BuildContext context,
    String title, {
    required Widget leading,
    required VoidCallback onPressed,
    bool selected = false,
  }) {
    final t = context.webTokens;
    return ReaderTap(
      onTap: onPressed,
      radius: PantasRadius.sm,
      selectedFill: selected ? t.colors.surface : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: PantasSize.btnXs),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s12,
            vertical: PantasSpace.s6,
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: PantasSpace.s10),
              Expanded(
                // A long topic name wraps to a second line instead of ending in
                // dots (3K-24, Aedwon's Nov 3 complaint about cut titles).
                child: Text(
                  title,
                  style: PantasType.webSub.copyWith(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: t.colors.textPrimary,
                  ),
                ),
              ),
              // The chevron fades in on the quick ease and out again.
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : PantasDurations.short2,
                switchInCurve: PantasCurves.fade,
                switchOutCurve: PantasCurves.fade,
                child: selected
                    ? Icon(
                        PantasIcons.next,
                        key: const ValueKey('web-study-selected-chevron'),
                        size: 14,
                        color: t.colors.tertiaryLabel,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A topic card replacing another. The card being left fades out over the
/// first 90 ms while the new one comes in from 70 ms (the approved pane swap),
/// so the column is never empty between them (2G-19).
class _TopicSwap extends StatefulWidget {
  const _TopicSwap({required this.topicId, required this.child});
  final String topicId;
  final Widget child;
  @override
  State<_TopicSwap> createState() => _TopicSwapState();
}

class _TopicSwapState extends State<_TopicSwap>
    with SingleTickerProviderStateMixin {
  // On the pane clock of 240 ms, the card runs only to 90 ms.
  late final AnimationController _out;
  Widget? _leaving;

  @override
  void initState() {
    super.initState();
    _out = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: PaneMotion.outEndMs.round()),
      upperBound: PaneMotion.outEndMs / PantasDurations.medium1.inMilliseconds,
    );
  }

  @override
  void didUpdateWidget(_TopicSwap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topicId == widget.topicId ||
        MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    _leaving = oldWidget.child;
    unawaited(
      _out.forward(from: 0).whenComplete(() {
        if (mounted) setState(() => _leaving = null);
      }),
    );
  }

  @override
  void dispose() {
    _out.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          if (_leaving case final leaving?)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: ExcludeFocus(
                    child: AnimatedBuilder(
                      animation: _out,
                      child: leaving,
                      builder: (context, child) => Opacity(
                        key: const ValueKey('web-study-topic-leaving'),
                        opacity: PaneMotion.outgoingOpacity(_out.value),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          _TopicEntrance(
            key: ValueKey(('web-study-topic-card', widget.topicId)),
            child: widget.child,
          ),
        ],
      );
}

/// The topic card arriving: the Settings pane's approved fade and 8 px rise,
/// on its 240 ms clock. Key it by topic, so only a different topic replays it
/// and a rebuild of the same topic does not.
class _TopicEntrance extends StatelessWidget {
  const _TopicEntrance({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : PantasDurations.medium1,
        builder: (_, progress, child) => Opacity(
          key: const ValueKey('web-study-topic-opacity'),
          opacity: PaneMotion.incomingOpacity(progress),
          child: Transform.translate(
            offset: Offset(0, PaneMotion.incomingLift(progress)),
            child: child,
          ),
        ),
        // The fade changes only the layer's opacity, so the card is painted
        // once.
        child: RepaintBoundary(child: child),
      );
}

/// The Last opened card (board SD_MapEmpty). With [strip] it spans the page,
/// text on the left and Resume on the right, 24 px apart (QA polish board,
/// option C).
class WebLastOpenedCard extends StatelessWidget {
  const WebLastOpenedCard({
    required this.title,
    required this.onResume,
    this.topic,
    this.strip = false,
    super.key,
  });
  final String title;
  final String? topic;
  final VoidCallback onResume;
  final bool strip;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LAST OPENED',
          style: t.eb,
        ),
        const SizedBox(height: PantasSpace.s2),
        Text(
          title,
          style: PantasType.webRowTitle.copyWith(
            fontWeight: FontWeight.w600,
            color: t.colors.textPrimary,
          ),
        ),
        if (topic != null)
          Text(
            topic!,
            style: PantasType.webRowSub.copyWith(color: t.colors.textSecondary),
          ),
      ],
    );
    final resume = WebButton(
      label: 'Resume',
      variant: WebButtonVariant.secondary,
      onPressed: onResume,
    );
    // Board `.card` draws its 1 px edge as an inset shadow, so the padding is
    // measured from the card's outer edge and the card is 96 px tall in both
    // themes (4N-2).
    if (strip) {
      return WebCard(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s18,
          PantasSpace.s16,
          PantasSpace.s18,
          PantasSpace.s16,
        ),
        child: Row(
          children: [
            Expanded(child: text),
            const SizedBox(width: PantasSpace.s24),
            resume,
          ],
        ),
      );
    }
    return WebCard(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s18,
        PantasSpace.s16,
        PantasSpace.s16,
        PantasSpace.s16,
      ),
      // Resume sits under the text at its natural width, so a long title and
      // topic wrap in full (preview study-reader, section 2 Option A).
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: double.infinity, child: text),
          const SizedBox(height: PantasSpace.s12),
          resume,
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
    super.key,
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
    // Row padding, chevron, two gaps and the value's own width.
    final bookmarkRight = PantasSpace.s20 +
        PantasSpace.s16 +
        PantasSpace.s12 +
        valueWidth +
        PantasSpace.s8;
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
                wrapTitle: true,
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
                          horizontal: PantasSpace.s8,
                          vertical: PantasSpace.s2,
                        ),
                        decoration: BoxDecoration(
                          color: t.colors.accentTint,
                          borderRadius:
                              BorderRadius.circular(PantasRadius.full),
                        ),
                        child: Text(
                          'Today',
                          style: PantasType.webTag.copyWith(color: t.tintText),
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
                  padding: EdgeInsets.only(right: bookmarkRight),
                  child: Opacity(
                    opacity: _hover || _focus || lesson.isBookmarked ? 1 : 0,
                    child: PantasIconButton(
                      tooltip: lesson.isBookmarked
                          ? 'Remove bookmark'
                          : 'Bookmark ${lesson.title}',
                      size: PantasIconButtonSize.sm,
                      onPressed: widget.onBookmark,
                      icon: ReaderBookmarkPop(
                        bookmarked: lesson.isBookmarked,
                        child: Icon(
                          lesson.isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          size: 18,
                          color: lesson.isBookmarked
                              ? t.colors.accent
                              // The muted icon role in both themes.
                              : t.colors.iconMuted,
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
        padding: EdgeInsets.only(bottom: context.webPageBottomInset),
        child: WebCard(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s24,
            vertical: PantasSpace.s56,
          ),
          child: Center(
            child: SizedBox(
              width: PantasLayout.modal,
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
                  const SizedBox(height: PantasSpace.s18),
                  Text(
                    title,
                    style: isError
                        ? PantasType.webLead.copyWith(
                            color: context.colors.textPrimary,
                          )
                        : context.webTokens.h3,
                    textAlign: TextAlign.center,
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: PantasSpace.s8),
                    Text(
                      detail!,
                      style: context.webTokens.sub,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (action != null) ...[
                    const SizedBox(height: PantasSpace.s20),
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
      context.webTokens.eb,
    );
    Widget label(double width) => Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s12,
            PantasSpace.s0,
            PantasSpace.s12,
            PantasSpace.s6,
          ),
          child: SizedBox(
            height: line,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SkeletonBlock(width: width, height: 11),
            ),
          ),
        );
    Widget row() => const SizedBox(
          height: PantasSize.navItem,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: PantasSpace.s12),
            child: Row(
              children: [
                SkeletonBlock(
                  width: PantasSpace.s18,
                  height: PantasSpace.s18,
                  radius: 9,
                ),
                SizedBox(width: PantasSpace.s10),
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
          width: _skeletonWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              label(90),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: PantasSpace.s12,
                  vertical: PantasSpace.s6,
                ),
                child: SkeletonBlock(width: 220, height: PantasSpace.s14),
              ),
              for (var subject = 0; subject < 2; subject++) ...[
                const SizedBox(height: PantasSpace.s18),
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
