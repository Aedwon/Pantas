import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_section.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/pinned_topic_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_field_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_head_block.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_map_entry.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_skeletons.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_topic_section.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_study_layout.dart';
import 'package:pantas/features/quiz/application/quiz_starts.dart';

class StudyTabHome extends ConsumerStatefulWidget {
  const StudyTabHome({
    this.openTopicId,
    this.searchOnOpen = false,
    this.onSearchCancelled,
    super.key,
  });

  final TopicId? openTopicId;
  final bool searchOnOpen;
  final VoidCallback? onSearchCancelled;

  @override
  ConsumerState<StudyTabHome> createState() => _StudyTabHomeState();
}

class _StudyTabHomeState extends ConsumerState<StudyTabHome> {
  final _scrollController = ScrollController();
  final _topicKeys = <TopicId, GlobalKey>{};
  final _listKey = GlobalKey();
  bool _searching = false;
  bool _bookmarksOpen = false;
  StudyTopic? _pinnedTopic;
  final _topicAnchors = <TopicId, double>{};
  bool _saveFailed = false;

  /// Whether the open topic's row has left the screen.
  ///
  /// The pinned bar exists to get you back to a topic you can no longer see.
  /// It used to appear the instant a topic opened, which is the one moment
  /// you are looking straight at it, and it announced that by pushing the
  /// whole list down.
  final _openTopicOffScreen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncPinnedBar);
    final requested = widget.openTopicId;
    if (requested != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(openTopicProvider.notifier).open(requested);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _openTopicOffScreen.dispose();
    super.dispose();
  }

  /// A notifier rather than `setState`: this runs on every scroll frame and
  /// the list below it must not rebuild for it.
  void _syncPinnedBar() {
    final topicId = ref.read(openTopicProvider).valueOrNull;
    if (topicId == null) {
      _openTopicOffScreen.value = false;
      return;
    }
    _openTopicOffScreen.value = !_isOnScreen(topicId);
  }

  bool _isOnScreen(TopicId topicId) {
    final rowContext = _topicKeys[topicId]?.currentContext;
    final listContext = _listKey.currentContext;
    final row = rowContext?.findRenderObject() as RenderBox?;
    final list = listContext?.findRenderObject() as RenderBox?;
    if (row == null || list == null || !row.attached || !list.attached) {
      // Unknown, so say it is visible: a bar that appears on a guess is
      // worse than one that arrives a frame late.
      final anchor = _topicAnchors[topicId];
      return anchor == null ||
          !_scrollController.hasClients ||
          _scrollController.offset < anchor + 48;
    }
    final rowTop = row.localToGlobal(Offset.zero).dy;
    final rowBottom = rowTop + row.size.height;
    final listTop = list.localToGlobal(Offset.zero).dy;
    _topicAnchors[topicId] = _scrollController.offset + rowTop - listTop;
    return rowBottom > listTop;
  }

  /// Toggles a topic and leaves the row the student tapped exactly where
  /// it was on screen.
  ///
  /// Only one topic is open at a time, so opening one closes another, and
  /// when the closed one sits above the tapped row everything below it
  /// slides up under the finger. The row is measured before and after the
  /// frame and the scroll is corrected by the difference.
  Future<void> _toggleTopic(TopicId topicId) async {
    final before = _offsetOf(topicId);
    try {
      await ref.read(openTopicProvider.notifier).toggle(topicId);
      if (mounted) setState(() => _saveFailed = false);
    } on Exception {
      if (mounted) setState(() => _saveFailed = true);
    }
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final after = _offsetOf(topicId);
      if (before == null || after == null || !_scrollController.hasClients) {
        return;
      }
      _syncPinnedBar();
      final drift = after - before;
      if (drift.abs() < 0.5) return;
      final target = (_scrollController.offset + drift).clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(target);
    });
  }

  double? _offsetOf(TopicId topicId) {
    final context = _topicKeys[topicId]?.currentContext;
    final box = context?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero).dy;
  }

  GlobalKey _keyFor(TopicId topicId) =>
      _topicKeys.putIfAbsent(topicId, GlobalKey.new);

  Widget _stateFrame(
    BuildContext context,
    Widget state, {
    bool loading = false,
  }) =>
      Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (loading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchFieldBar(onCancel: () {}),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Study', style: context.type.largeTitle),
                ),
              if (loading) const SizedBox(height: 24),
              Expanded(
                child: loading
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: state,
                      )
                    : state,
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return WebStudyLayout(
        searchOnOpen: widget.searchOnOpen,
        onSearchCancelled: widget.onSearchCancelled,
      );
    }
    final asyncMap = ref.watch(studyMapProvider);

    return asyncMap.when(
      loading: () =>
          _stateFrame(context, const StudyMapSkeleton(), loading: true),
      error: (error, _) => _stateFrame(
        context,
        errorFor(
          'topics',
          () => ref.invalidate(studyMapProvider),
          error: error,
          icon: Icon(PantasIcons.studyTab),
          boardLayout: true,
        ),
      ),
      data: (map) {
        if (map == null) {
          return _stateFrame(context, chooseExamFallback(context));
        }
        if (map.isEmpty) {
          final exam = ref.watch(activeExamFocusProvider).valueOrNull?.exam;
          if (exam == null) {
            return _stateFrame(context, chooseExamFallback(context));
          }
          return _stateFrame(
            context,
            StateView(
              message: 'Nothing to study yet',
              detail: 'This exam has no lessons on your device yet. Check back '
                  'after the next content update.',
              actionLabel: 'Try a Quick Quiz',
              icon: Icon(PantasIcons.studyTab),
              boardLayout: true,
              onRetry: () => startQuickQuiz(context, examId: exam.id),
            ),
          );
        }

        final openTopicId = ref.watch(openTopicProvider).valueOrNull;
        final today = ref.watch(studyTodayLessonIdsProvider);
        final disableAnimations = MediaQuery.disableAnimationsOf(context);
        StudyTopic? openTopic;
        if (openTopicId != null) {
          for (final subject in map.subjects) {
            for (final topic in subject.topics) {
              if (topic.id == openTopicId) {
                openTopic = topic;
                break;
              }
            }
          }
        }

        if (openTopic != null) _pinnedTopic = openTopic;
        return PantasSheet(
          bookmarks: true,
          scrollable: false,
          open: _bookmarksOpen,
          label: 'Bookmarks',
          onDismiss: () => setState(() => _bookmarksOpen = false),
          page: PantasPage.content(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchFieldBar(
                  // Skip the focus-blocking entry animation for route requests.
                  entryAnimation: !widget.searchOnOpen,
                  autofocus: widget.searchOnOpen,
                  onCancel: () {
                    setState(() => _searching = false);
                    widget.onSearchCancelled?.call();
                  },
                  onEditingChanged: (editing) =>
                      setState(() => _searching = editing),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1, end: _searching ? 0 : 1),
                        duration: disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 200),
                        curve: PantasCurves.houseOut,
                        builder: (context, value, child) => IgnorePointer(
                          ignoring: _searching,
                          child: ExcludeFocus(
                            excluding: _searching,
                            child: ExcludeSemantics(
                              excluding: _searching,
                              child: Opacity(
                                key: const ValueKey('study-map-opacity'),
                                opacity: value,
                                child: child,
                              ),
                            ),
                          ),
                        ),
                        child: Stack(
                          key: _listKey,
                          children: [
                            ListView(
                              controller: _scrollController,
                              children: [
                                StudyHeadBlock(map: map),
                                StudyMapEntry(
                                  delay: const Duration(milliseconds: 260),
                                  child: BookmarksSection(
                                    onSeeAll: () =>
                                        setState(() => _bookmarksOpen = true),
                                  ),
                                ),
                                if (today.hasError)
                                  errorFor(
                                    'plan',
                                    () => ref.invalidate(
                                      studyTodayLessonIdsProvider,
                                    ),
                                  ),
                                if (_saveFailed)
                                  saveFailureLine(() async {
                                    try {
                                      await ref
                                          .read(openTopicProvider.notifier)
                                          .save();
                                      if (mounted) {
                                        setState(() => _saveFailed = false);
                                      }
                                    } on Exception {
                                      // Keep the retry visible.
                                    }
                                  }),
                                for (var i = 0; i < map.subjects.length; i++)
                                  StudyMapEntry(
                                    key: ValueKey(map.subjects[i].id),
                                    delay:
                                        Duration(milliseconds: 520 + 120 * i),
                                    child: StudySubjectSection(
                                      subject: map.subjects[i],
                                      ringDelay: Duration(
                                        milliseconds: 820 + 120 * i,
                                      ),
                                      onToggleTopic: (topicId) =>
                                          unawaited(_toggleTopic(topicId)),
                                      keyForTopic: _keyFor,
                                    ),
                                  ),
                              ],
                            ),
                            if (_pinnedTopic != null)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: _openTopicOffScreen,
                                  builder: (context, offScreen, child) {
                                    final visible =
                                        offScreen && openTopic != null;
                                    return IgnorePointer(
                                      ignoring: !visible,
                                      child: ExcludeFocus(
                                        excluding: !visible,
                                        child: ExcludeSemantics(
                                          excluding: !visible,
                                          child: AnimatedOpacity(
                                            opacity: visible ? 1 : 0,
                                            duration:
                                                disableAnimations || visible
                                                    ? Duration.zero
                                                    : const Duration(
                                                        milliseconds: 200,
                                                      ),
                                            curve: PantasCurves.houseOut,
                                            child: child,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: PinnedTopicBar(
                                    topic: _pinnedTopic!,
                                    onClose: () =>
                                        _toggleTopic(_pinnedTopic!.id),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_searching) const SearchResults(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          child: BookmarksSheet(
            key: ValueKey(
              ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id,
            ),
            onClose: () => setState(() => _bookmarksOpen = false),
          ),
        );
      },
    );
  }
}
