import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';
import 'package:pantas/features/lesson/data/repos/reader_position_repository.dart';
import 'package:pantas/features/lesson/presentation/widgets/lesson_contents_sheet.dart';
import 'package:pantas/features/lesson/presentation/widgets/pull_to_advance.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_gap.dart';
import 'package:pantas/features/lesson/presentation/widgets/reader_rail.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';

/// The reader.
///
/// **Advancing to the next lesson is not a navigation.** It used to push a
/// route, which meant the page transition carried the bar and the rail with
/// it: one `< Study` slid out while an identical one slid in. Both describe
/// the reader rather than the lesson, so both stay still and only the body
/// travels, in the direction the pull went.
class LessonPage extends ConsumerStatefulWidget {
  const LessonPage({
    required this.lessonId,
    this.origin = ReaderOrigin.study,
    this.resume = false,
    this.dayContext,
    super.key,
  });

  final LessonId lessonId;
  final ReaderOrigin origin;
  final LessonDayContext? dayContext;
  final bool resume;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  late LessonId _lessonId = widget.lessonId;

  /// The last lesson that actually loaded.
  ///
  /// Held so an advance never falls back to the loading skeleton. That
  /// skeleton replaces the whole body, chrome included, so a swap flashed the
  /// bar and the rail out and back: *"the entire app still has a moment of
  /// loading sort of"*. The reader keeps showing what it has until the next
  /// lesson is ready, and the body is off screen while it waits, so there is
  /// nothing to see and nothing to flash.
  ReaderContext? _shown;

  LessonId? _warmedId;
  ProviderSubscription<Object?>? _warm;

  @override
  void didUpdateWidget(covariant LessonPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new route for the same page, so follow it.
    if (oldWidget.lessonId != widget.lessonId) {
      _lessonId = widget.lessonId;
      _shown = null;
    }
  }

  @override
  void dispose() {
    _warm?.close();
    super.dispose();
  }

  LessonDayContext? _dayContextFor(LessonId id) {
    final day = widget.dayContext;
    if (day == null) return null;
    final index = day.lessonIds.indexOf(id);
    if (index < 0) return null;
    return LessonDayContext(
      date: day.date,
      lessonIds: day.lessonIds,
      index: index,
    );
  }

  void _advanceTo(LessonId next) => setState(() => _lessonId = next);

  /// Loads the next lesson while this one is still being read.
  ///
  /// Kept subscribed so the provider is not disposed before the pull lands.
  /// Without it the advance waits on a database read at exactly the moment
  /// the movement is meant to be continuous.
  void _warmNext(LessonId? nextId) {
    if (nextId == _warmedId) return;
    _warmedId = nextId;
    _warm?.close();
    _warm = nextId == null
        ? null
        : ref.listenManual(readerContextProvider(nextId), (_, __) {});
  }

  @override
  Widget build(BuildContext context) {
    final lessonId = _lessonId;
    final origin = widget.origin;
    final asyncReader = ref.watch(readerContextProvider(lessonId));
    final loaded = asyncReader.valueOrNull;
    if (loaded != null) _shown = loaded;
    final reader = loaded ?? _shown;

    return Scaffold(
      backgroundColor:
          reader == null ? context.colors.background : context.colors.surface,
      body: switch ((reader, asyncReader)) {
        (_, AsyncError(:final error)) => _ReaderFallback(
            origin: origin,
            child: errorFor(
              'lesson',
              () => ref.invalidate(readerContextProvider(lessonId)),
              error: error,
              message: 'Could not load this lesson.',
              icon: Icon(PantasIcons.studyTab),
              boardLayout: true,
            ),
          ),
        (final ReaderContext reader, _) => Builder(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _warmNext(reader.next?.id),
              );
              return _ReaderBody(
                reader: reader,
                dayContext: _dayContextFor(reader.lesson.id),
                origin: origin,
                resume: widget.resume && reader.lesson.id == widget.lessonId,
                onAdvance: _advanceTo,
              );
            },
          ),
        (_, AsyncLoading()) => _ReaderFallback(
            origin: origin,
            child: SingleChildScrollView(child: loadingFor(asyncReader)),
          ),
        _ => _ReaderFallback(
            origin: origin,
            child: StateView(
              message: 'Lesson not found.',
              boardLayout: true,
              icon: Icon(PantasIcons.studyTab),
            ),
          ),
      },
    );
  }
}

class _ReaderFallback extends StatelessWidget {
  const _ReaderFallback({required this.origin, required this.child});
  final ReaderOrigin origin;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: context.colors.surface,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  ),
                  onPressed: () => origin.leave(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PantasIcons.back,
                        size: 24,
                        color: context.colors.accent,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        origin.backLabel(context),
                        style: context.type.body
                            .copyWith(color: context.colors.accent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
}

class _ReaderBody extends ConsumerStatefulWidget {
  const _ReaderBody({
    required this.reader,
    required this.origin,
    required this.onAdvance,
    this.dayContext,
    this.resume = false,
  });

  final bool resume;
  final ReaderContext reader;
  final ReaderOrigin origin;
  final LessonDayContext? dayContext;

  /// Swaps the lesson in place. Not a navigation: see [LessonPage].
  final void Function(LessonId) onAdvance;

  @override
  ConsumerState<_ReaderBody> createState() => _ReaderBodyState();
}

class _ReaderBodyState extends ConsumerState<_ReaderBody> {
  late final ScrollController _scrollController;
  final _scrollOffset = ValueNotifier<double>(0);
  final _progress = ValueNotifier<double>(0);

  /// Whether the end of the lesson is on screen. Drives the pull handle.
  final _isAtEnd = ValueNotifier<bool>(false);
  ReadMarkingController? _markingController;
  late final ReaderPositionRepository _positions;
  Timer? _positionDelay;
  bool _positionFailed = false;
  bool _resumeFailed = false;
  bool _contentsOpen = false;

  @override
  void initState() {
    super.initState();
    _positions = ref.read(readerPositionRepositoryProvider);
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMarking();
      if (widget.resume) {
        unawaited(_resumePosition());
      } else {
        _syncScrollState();
      }
    });
  }

  Future<void> _resumePosition() async {
    final exam = widget.reader.examId;
    if (exam == null) return _syncScrollState();
    try {
      final offset = await _positions.read(exam, widget.reader.lesson.id);
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
      if (_resumeFailed) setState(() => _resumeFailed = false);
      _syncScrollState();
    } on Exception catch (error) {
      if (mounted) setState(() => _resumeFailed = true);
      // Retain the lesson while the saved position can be retried.
      debugPrint('Reader position could not load: ${error.runtimeType}');
    }
  }

  Future<void> _savePosition(ReaderContext reader, double offset) async {
    final exam = reader.examId;
    if (exam == null) return;
    try {
      await _positions.write(
        exam,
        reader.lesson.id,
        offset.clamp(0.0, double.infinity),
        fraction: _progress.value,
      );
      if (mounted && _positionFailed) setState(() => _positionFailed = false);
    } on Exception {
      if (mounted) setState(() => _positionFailed = true);
    }
  }

  /// A lesson short enough not to scroll never fires a scroll event, so the
  /// end is already on screen and nothing would ever say so.
  void _syncScrollState() {
    if (!mounted || !_scrollController.hasClients) return;
    _onScroll();
  }

  void _initMarking() {
    final progressRepo = ref.read(lessonProgressRepositoryProvider);
    final prefsRepo = ref.read(appPreferencesRepositoryProvider);
    _markingController = ReadMarkingController(
      lessonId: widget.reader.lesson.id,
      examId: widget.reader.examId,
      progressRepository: progressRepo,
      preferencesRepository: prefsRepo,
      onMarked: () => ref.read(roadmapRevisionProvider.notifier).bump(),
    );
    _markingController?.onOpen();
  }

  @override
  void didUpdateWidget(covariant _ReaderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reader.lesson.id != widget.reader.lesson.id) {
      // The body stays mounted across an advance, so the controller keeps
      // the offset the last lesson was left at and the new one opened part
      // way down. A lesson starts at its first line.
      _positionDelay?.cancel();
      unawaited(_savePosition(oldWidget.reader, _scrollOffset.value));
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      _scrollOffset.value = 0;
      _progress.value = 0;
      _isAtEnd.value = false;
      _initMarking();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Again after layout: the offset is clamped against the old lesson's
        // extent until the new one has been measured.
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
        _syncScrollState();
      });
    }
  }

  @override
  void dispose() {
    _positionDelay?.cancel();
    unawaited(_savePosition(widget.reader, _scrollOffset.value));
    _scrollController.dispose();
    _scrollOffset.dispose();
    _progress.dispose();
    _isAtEnd.dispose();
    super.dispose();
  }

  /// Scroll position is published through notifiers, never `setState`.
  ///
  /// `setState` here rebuilt the whole page on **every scroll frame**, and
  /// the whole page includes the lesson body: every block, every formula,
  /// each of which is a laid-out widget. That is the jank in the reader and
  /// nowhere else, because no other screen rebuilds this much this often.
  ///
  /// Only the bar, the rail and the pull handle listen, and each rebuilds
  /// alone.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;

    _scrollOffset.value = offset;
    _positionDelay?.cancel();
    final reader = widget.reader;
    _positionDelay = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(_savePosition(reader, offset)),
    );
    _progress.value =
        maxExtent > 0 ? (offset / maxExtent).clamp(0.0, 1.0) : 1.0;
    // Within a line or so of the bottom, not exactly on it: a reader who
    // has stopped a few pixels short has still reached the end, and
    // rounding in the scroll metrics means exact equality is rare.
    _isAtEnd.value = maxExtent <= 0 || offset >= maxExtent - 24;

    _markingController?.onScroll(offset: offset, maxExtent: maxExtent);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reader = widget.reader;

    return PantasSheet(
      label: 'Contents',
      readerContents: true,
      open: _contentsOpen,
      onDismiss: () => setState(() => _contentsOpen = false),
      page: SafeArea(
        child: Column(
          children: [
            ReaderBar(
              title: reader.lesson.title,
              lessonId: reader.lesson.id,
              dayContext: widget.dayContext,
              origin: widget.origin,
              isBookmarked: reader.isBookmarked,
              onBookmark: () => toggleBookmark(ref, reader.lesson.id),
              onContents: () => setState(() => _contentsOpen = true),
              scrollOffset: _scrollOffset,
            ),
            ValueListenableBuilder<double>(
              valueListenable: _progress,
              builder: (_, progress, __) => ReaderRail(
                progress: progress,
                dayContext: widget.dayContext,
              ),
            ),
            Expanded(
              child: PullToAdvance(
                // The handle belongs to the end of the lesson, so it waits
                // until the end is on screen.
                isAtEnd: _isAtEnd,
                nextTitle: reader.next?.title,
                lessonId: reader.lesson.id,
                onAdvance: reader.next != null
                    ? () => widget.onAdvance(reader.next!.id)
                    : null,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LessonTextScale(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              reader.topicName.toUpperCase(),
                              style: context.type.sectionHeader
                                  .copyWith(letterSpacing: .52),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              reader.lesson.title,
                              style:
                                  context.type.pageTitle.copyWith(height: 1.15),
                            ),
                            const SizedBox(height: 18),
                            ContentRenderer(
                              blocks: reader.lesson.bodyJson,
                              readerFigures: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${reader.lesson.estimatedMinutes} min read',
                        style: context.type.footnote
                            .copyWith(color: colors.secondaryLabel),
                      ),
                      const SizedBox(height: 16),
                      if (_resumeFailed)
                        errorFor('reading position', _resumePosition),
                      if (_positionFailed)
                        saveFailureLine(
                          () => _savePosition(reader, _scrollOffset.value),
                        ),
                      ReaderGap(
                        isRead: reader.isRead,
                        examId: reader.examId,
                        lessonId: reader.lesson.id,
                      ),
                      // No mark-as-read button, deliberately. It is the one
                      // thing this plan changes that everything downstream
                      // depends on: with a button, every coverage figure in the
                      // app counts presses rather than lessons whose end was
                      // actually reached. Read marking is an observer of scroll
                      // position now.
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      child: LessonContentsSheet(
        key: const ValueKey('lesson-contents'),
        reader: reader,
        dayContext: widget.dayContext,
        onSelectLesson: (id) {
          setState(() => _contentsOpen = false);
          if (id != reader.lesson.id) widget.onAdvance(id);
        },
      ),
    );
  }
}
