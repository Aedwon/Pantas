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
import 'package:go_router/go_router.dart';

class LessonPage extends ConsumerWidget {
  const LessonPage({
    required this.lessonId,
    this.origin = ReaderOrigin.study,
    super.key,
  });

  final LessonId lessonId;
  final ReaderOrigin origin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          return _ReaderBody(reader: reader, origin: origin);
        },
      ),
    );
  }
}

class _ReaderBody extends ConsumerStatefulWidget {
  const _ReaderBody({
    required this.reader,
    required this.origin,
  });

  final ReaderContext reader;
  final ReaderOrigin origin;

  @override
  ConsumerState<_ReaderBody> createState() => _ReaderBodyState();
}

class _ReaderBodyState extends ConsumerState<_ReaderBody> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0;
  double _progress = 0;
  ReadMarkingController? _markingController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMarking();
    });
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
      _scrollOffset = 0;
      _progress = 0;
      _initMarking();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;
    setState(() {
      _scrollOffset = offset;
      _progress = maxExtent > 0 ? (offset / maxExtent).clamp(0.0, 1.0) : 1.0;
    });

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
          ReaderRail(progress: _progress),
          Expanded(
            child: PullToAdvance(
              nextTitle: reader.next?.title,
              onAdvance: reader.next != null
                  ? () => context.go(
                        '/lesson/${reader.next!.id}?from=${widget.origin == ReaderOrigin.home ? 'home' : 'study'}',
                      )
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
