import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/page_title.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/first_run/application/first_run_data.dart';
import 'package:pantas/features/first_run/domain/first_run_lesson_blocks.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_header.dart';
import 'package:pantas/features/lesson/application/reader_providers.dart';

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
      readMetrics: () => _scroll.hasClients
          ? (
              offset: _scroll.offset,
              maxExtent: _scroll.position.maxScrollExtent,
            )
          : null,
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
        ? Align(
            alignment: Alignment.centerRight,
            child: WebButton(
              label: 'Answer 3 Questions',
              keyHint: 'Enter',
              onPressed: widget.onAnswer,
            ),
          )
        : PantasButton(
            label: 'Answer 3 Questions',
            size: PantasButtonSize.phone,
            fullWidth: true,
            onPressed: widget.onAnswer,
          );
    return Column(
      children: [
        FirstRunHeader(onSkip: widget.onSkip),
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
                PantasSpace.s18,
                wide ? PantasSpace.s24 : PantasSpace.s20,
                // ds-board: P03 content padding 22/20/44
                PantasSpace.s44,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: PantasLayout.reader,
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
                            letterSpacing: .5,
                          ),
                        ),
                        const SizedBox(height: PantasSpace.s8),
                        PantasTitle(
                          lesson.title,
                          narrowRule: false,
                          style: context.type.pageTitle.copyWith(
                            height: 1.08,
                            letterSpacing: -.5,
                          ),
                        ),
                        const SizedBox(height: PantasSpace.s24),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
