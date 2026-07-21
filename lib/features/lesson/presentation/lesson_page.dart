import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/lesson/application/reader_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/lesson_contents_sheet.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/pull_to_advance.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/reader_bar.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/reader_gap.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/reader_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    super.key,
  });

  final LessonId lessonId;
  final ReaderOrigin origin;

  @override
  ConsumerState<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<LessonPage> {
  late LessonId _lessonId = widget.lessonId;

  @override
  void didUpdateWidget(covariant LessonPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new route for the same page, so follow it.
    if (oldWidget.lessonId != widget.lessonId) {
      _lessonId = widget.lessonId;
    }
  }

  void _advanceTo(LessonId next) => setState(() => _lessonId = next);

  @override
  Widget build(BuildContext context) {
    final lessonId = _lessonId;
    final origin = widget.origin;
    final asyncReader = ref.watch(readerContextProvider(lessonId));

    return Scaffold(
      backgroundColor: context.colors.background,
      body: asyncReader.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: 'Failed to load lesson.',
            actionLabel: 'Retry',
            onAction: () => ref.refresh(readerContextProvider(lessonId)),
          ),
        ),
        data: (reader) {
          if (reader == null) {
            return Center(
              child: Text(
                'Lesson not found.',
                style: context.textStyles.bodyMedium
                    .copyWith(color: context.colors.inkMuted),
              ),
            );
          }
          return _ReaderBody(
            reader: reader,
            origin: origin,
            onAdvance: _advanceTo,
          );
        },
      ),
    );
  }
}

class _ReaderBody extends ConsumerStatefulWidget {
  const _ReaderBody({
    required this.reader,
    required this.origin,
    required this.onAdvance,
  });

  final ReaderContext reader;
  final ReaderOrigin origin;

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMarking();
      _syncScrollState();
    });
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
    );
    _markingController?.onOpen();
  }

  @override
  void didUpdateWidget(covariant _ReaderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reader.lesson.id != widget.reader.lesson.id) {
      _scrollOffset.value = 0;
      _progress.value = 0;
      _isAtEnd.value = false;
      _initMarking();
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollState());
    }
  }

  @override
  void dispose() {
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
    final textStyles = context.textStyles;
    final reader = widget.reader;

    return SafeArea(
      child: Column(
        children: [
          ReaderBar(
            title: reader.lesson.title,
            origin: widget.origin,
            isBookmarked: reader.isBookmarked,
            onBookmark: () => toggleBookmark(ref, reader.lesson.id),
            onContents: () => showLessonContentsSheet(context, reader: reader),
            scrollOffset: _scrollOffset,
          ),
          ValueListenableBuilder<double>(
            valueListenable: _progress,
            builder: (_, progress, __) => ReaderRail(progress: progress),
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reader.lesson.title,
                      style: textStyles.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    PortableTextRenderer(blocks: reader.lesson.bodyJson),
                    const SizedBox(height: 24),
                    Text(
                      '${reader.lesson.estimatedMinutes} min read',
                      style:
                          textStyles.bodySmall.copyWith(color: colors.inkMuted),
                    ),
                    const SizedBox(height: 16),
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
    );
  }
}
