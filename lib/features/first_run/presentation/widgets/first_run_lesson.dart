import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/page_title.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/first_run/application/first_run_data.dart';
import 'package:pantas/features/first_run/domain/first_run_lesson_blocks.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_header.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';

// ds-board: W03 page bottom padding 120
const double _wideBottomPx = 120;

/// The lesson step (frames P03, W03): the real lesson body, limited to Core
/// Concept, Mnemonics and Memory Aids, and Example 1 with its solution open.
/// It counts as read under the reader's own rule: open for 15 seconds and the
/// end of the shown text reached (plan ruling 4).
class FirstRunLesson extends ConsumerStatefulWidget {
  const FirstRunLesson({
    required this.data,
    required this.onSkip,
    required this.onAnswer,
    super.key,
  });

  final FirstRunData data;
  final VoidCallback onSkip;
  final VoidCallback onAnswer;

  @override
  ConsumerState<FirstRunLesson> createState() => _FirstRunLessonState();
}

class _FirstRunLessonState extends ConsumerState<FirstRunLesson> {
  final ScrollController _scroll = ScrollController();
  late final ReadMarkingController _marking;

  /// The lesson counts as read: the wide end row shows the Read chip then.
  bool _read = false;

  @override
  void initState() {
    super.initState();
    _marking = ReadMarkingController(
      lessonId: widget.data.lesson.id,
      // No exam id: the run leaves "recently opened" alone.
      examId: null,
      progressRepository: ref.read(lessonProgressRepositoryProvider),
      preferencesRepository: ref.read(appPreferencesRepositoryProvider),
      dwellFloor: ref.read(firstRunReadDwellProvider),
      onMarked: () {
        if (mounted) setState(() => _read = true);
      },
      readMetrics: () => _scroll.hasClients
          ? (
              offset: _scroll.offset,
              maxExtent: _scroll.position.maxScrollExtent,
            )
          : null,
    );
    unawaited(
      ref
          .read(lessonProgressRepositoryProvider)
          .isRead(widget.data.lesson.id)
          .then((read) {
        if (mounted && read) setState(() => _read = true);
      }),
    );
    _scroll.addListener(_measure);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _marking.onOpen();
      _measure();
    });
  }

  void _measure() {
    if (!_scroll.hasClients) return;
    _marking.onScroll(
      offset: _scroll.offset,
      maxExtent: _scroll.position.maxScrollExtent,
    );
  }

  @override
  void dispose() {
    _marking.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final colors = context.colors;
    final lesson = widget.data.lesson;
    final answer = wide
        ? _WideEnd(read: _read, onAnswer: widget.onAnswer)
        : PantasButton(
            label: 'Answer 3 Questions',
            size: PantasButtonSize.phone,
            fullWidth: true,
            onPressed: widget.onAnswer,
          );
    return Column(
      children: [
        FirstRunHeader(onSkip: widget.onSkip, divider: !wide),
        Expanded(
          child: NotificationListener<ReaderResizedNotification>(
            onNotification: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _measure();
              });
              return false;
            },
            child: SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.fromLTRB(
                wide ? PantasSpace.s24 : PantasSpace.s20,
                // ds-board: W03 page top 56, P03 content top 22
                wide ? PantasSpace.s56 : PantasSpace.s18,
                wide ? PantasSpace.s24 : PantasSpace.s20,
                // ds-board: P03 content padding 22/20/44, W03 bottom 120
                wide ? _wideBottomPx : PantasSpace.s44,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // ds-board: W03 page 1096, its head 1000 and column 640
                    maxWidth: wide ? 1096 : PantasLayout.reader,
                  ),
                  child: LessonTextScale(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.data.eyebrow.toUpperCase(),
                          style: PantasType.phoneSubhead.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                            // ds-board: eyebrow tracking .5
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: PantasSpace.s8),
                        PantasTitle(
                          lesson.title,
                          narrowRule: false,
                          style: wide
                              ? PantasType.webH1.copyWith(
                                  color: colors.textPrimary,
                                  // ds-board: lesson title line-height 1.08
                                  height: 1.08,
                                )
                              : context.type.pageTitle.copyWith(
                                  // ds-board: lesson title line-height 1.08
                                  height: 1.08,
                                  // ds-board: lesson title tracking -.5
                                  letterSpacing: -.5,
                                ),
                        ),
                        const SizedBox(height: PantasSpace.s24),
                        Align(
                          alignment: Alignment.topLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              // ds-board: W03 column 640
                              maxWidth: wide ? 640 : double.infinity,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ContentRenderer(
                                  blocks: firstRunLessonBlocks(lesson.bodyJson),
                                  readerFigures: true,
                                  openSolutions: true,
                                ),
                                const SizedBox(height: PantasSpace.s32),
                                answer,
                              ],
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
        ),
      ],
    );
  }
}

/// The wide end of the lesson (frame W03): a hairline, the Read chip at the
/// left once the lesson is read, and the button at the right.
class _WideEnd extends StatelessWidget {
  const _WideEnd({required this.read, required this.onAnswer});

  final bool read;
  final VoidCallback onAnswer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    return Container(
      // ds-board: W03 end margin-top 56 over the 32 above
      margin: const EdgeInsets.only(top: PantasSpace.s24),
      // ds-board: W03 end padding-top 28
      padding: const EdgeInsets.only(top: PantasSpace.s28),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.divider),
        ),
      ),
      child: Row(
        children: [
          if (read)
            TweenAnimationBuilder<double>(
              key: const ValueKey('first-run-read-chip'),
              tween: Tween(begin: still ? 1 : 0, end: 1),
              duration:
                  // ds-board: read chip pops in 350 ms, as the live reader
                  still ? Duration.zero : const Duration(milliseconds: 350),
              curve: PantasCurves.popB,
              builder: (_, value, child) => Transform.scale(
                alignment: Alignment.centerLeft,
                scale: .6 + .4 * value,
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    // ds-board: W03 tick 26
                    width: 26,
                    // ds-board: W03 tick 26
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.accentFill,
                    ),
                    child: Icon(
                      PantasIcons.check,
                      // ds-board: W03 tick check 15
                      size: 15,
                      color: colors.onAccent,
                    ),
                  ),
                  const SizedBox(width: PantasSpace.s10),
                  Text(
                    'Read',
                    style: PantasType.phoneHeadline.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          WebButton(label: 'Answer 3 Questions', onPressed: onAnswer),
        ],
      ),
    );
  }
}
