import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/answer_reveal.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/portable_text_renderer.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_review_providers.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

class MockReviewPage extends ConsumerStatefulWidget {
  const MockReviewPage({
    required this.attemptId,
    required this.proIsActive,
    super.key,
  });

  final String attemptId;
  final bool proIsActive;

  @override
  ConsumerState<MockReviewPage> createState() => _MockReviewPageState();
}

class _MockReviewPageState extends ConsumerState<MockReviewPage> {
  ReviewFilter _filter = ReviewFilter.wrong;
  int? _viewerIndex;
  bool _noteOpen = false;

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(mockReviewProvider(widget.attemptId));
    final markedAsync =
        ref.watch(mockMarkedQuestionIdsProvider(widget.attemptId));
    final handledAsync = ref.watch(mockOfferHandledProvider(widget.attemptId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_viewerIndex == null ? 'Results' : 'All questions'),
        leading: _viewerIndex == null
            ? null
            : IconButton(
                icon: Icon(PantasIcons.back),
                tooltip: 'Back to questions',
                onPressed: () => setState(() {
                  _viewerIndex = null;
                  _noteOpen = false;
                }),
              ),
      ),
      body: reviewAsync.when(
        data: (entries) {
          final filtered = FilterReviewEntries.call(entries, _filter);
          final viewerIndex = _viewerIndex;
          if (viewerIndex != null && viewerIndex < filtered.length) {
            return _QuestionViewer(
              entries: filtered,
              index: viewerIndex,
              proIsActive: widget.proIsActive,
              noteOpen: _noteOpen,
              onNote: widget.proIsActive
                  ? () => setState(() => _noteOpen = !_noteOpen)
                  : null,
              onPrevious: viewerIndex > 0
                  ? () => setState(() {
                        _viewerIndex = viewerIndex - 1;
                        _noteOpen = false;
                      })
                  : null,
              onNext: viewerIndex + 1 < filtered.length
                  ? () => setState(() {
                        _viewerIndex = viewerIndex + 1;
                        _noteOpen = false;
                      })
                  : null,
              onBlankReason: (reason, note) => _saveBlankReason(
                filtered[viewerIndex],
                reason,
                note,
              ),
              onMissReason: (reason, note) => _saveMissReason(
                filtered[viewerIndex],
                reason,
                note,
              ),
            );
          }

          final markedIds = markedAsync.valueOrNull ?? const <String>{};
          final offerHandled = handledAsync.valueOrNull ?? true;
          return _ReviewListBody(
            entries: entries,
            filter: _filter,
            proIsActive: widget.proIsActive,
            showFlagOffer: _filter == ReviewFilter.flagged &&
                !offerHandled &&
                markedIds.isNotEmpty,
            markedCount: markedIds.length,
            onFilter: (filter) => setState(() {
              _filter = filter;
              _viewerIndex = null;
              _noteOpen = false;
            }),
            onOpen: (entry) {
              final shown = FilterReviewEntries.call(entries, _filter);
              setState(() {
                _viewerIndex = shown.indexOf(entry);
                _noteOpen = false;
              });
            },
            onFinishNotes: () {
              final misses =
                  FilterReviewEntries.call(entries, ReviewFilter.wrong);
              if (misses.isEmpty) return;
              setState(() {
                _filter = ReviewFilter.wrong;
                _viewerIndex = 0;
                _noteOpen = true;
              });
            },
            onKeepFlags: () => _handleFlagOffer(markedIds, keep: true),
            onDismissFlags: () => _handleFlagOffer(markedIds, keep: false),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<void> _handleFlagOffer(
    Set<String> markedIds, {
    required bool keep,
  }) async {
    if (keep) {
      final flagRepo = ref.read(questionFlagsRepositoryProvider);
      for (final questionId in markedIds) {
        await flagRepo.flag(questionId);
      }
    }
    final prefsRepo = ref.read(appPreferencesRepositoryProvider);
    await prefsRepo.setDeviceValue(
      'mock_flag_offer_handled_${widget.attemptId}',
      'true',
    );
    ref.invalidate(mockOfferHandledProvider(widget.attemptId));
  }

  Future<void> _saveBlankReason(
    ReviewEntry entry,
    BlankReason reason,
    String? note,
  ) async {
    await ref.read(mockAttemptRepoProvider).saveReviewReason(
          attemptId: widget.attemptId,
          questionId: entry.question.id,
          savedAt: DateTime.now().toUtc(),
          blankReason: reason,
          reasonNote: note,
        );
    if (mounted) setState(() => _noteOpen = false);
  }

  Future<void> _saveMissReason(
    ReviewEntry entry,
    MissReason reason,
    String? note,
  ) async {
    await ref.read(mockAttemptRepoProvider).saveReviewReason(
          attemptId: widget.attemptId,
          questionId: entry.question.id,
          savedAt: DateTime.now().toUtc(),
          missReason: reason,
          reasonNote: note,
        );
    if (mounted) setState(() => _noteOpen = false);
  }
}

class _ReviewListBody extends StatelessWidget {
  const _ReviewListBody({
    required this.entries,
    required this.filter,
    required this.proIsActive,
    required this.showFlagOffer,
    required this.markedCount,
    required this.onFilter,
    required this.onOpen,
    required this.onFinishNotes,
    required this.onKeepFlags,
    required this.onDismissFlags,
  });

  final List<ReviewEntry> entries;
  final ReviewFilter filter;
  final bool proIsActive;
  final bool showFlagOffer;
  final int markedCount;
  final ValueChanged<ReviewFilter> onFilter;
  final ValueChanged<ReviewEntry> onOpen;
  final VoidCallback onFinishNotes;
  final VoidCallback onKeepFlags;
  final VoidCallback onDismissFlags;

  @override
  Widget build(BuildContext context) {
    final filtered = FilterReviewEntries.call(entries, filter);
    final counts = FilterReviewEntries.count(entries);
    final groups = <String, List<ReviewEntry>>{};
    String groupLabel(List<ReviewEntry> group) {
      if (filter != ReviewFilter.all) return '${group.length}';
      final correct = group.where((entry) => entry.isCorrect).length;
      return '$correct of ${group.length}';
    }

    for (final entry in filtered) {
      groups.putIfAbsent(entry.subjectName, () => []).add(entry);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('All questions', style: context.textStyles.displaySmall),
          const SizedBox(height: 22),
          _MockFilterRow(active: filter, counts: counts, onChanged: onFilter),
          if (proIsActive && filter == ReviewFilter.wrong) ...[
            const SizedBox(height: 16),
            _NotesPrompt(onPressed: onFinishNotes),
          ],
          if (showFlagOffer) ...[
            const SizedBox(height: 16),
            _FlagOffer(
              count: markedCount,
              onKeep: onKeepFlags,
              onDismiss: onDismissFlags,
            ),
          ],
          const SizedBox(height: 14),
          for (final group in groups.entries) ...[
            _PartHeader(
              name: group.key,
              label: groupLabel(group.value),
            ),
            for (final entry in group.value)
              _MockReviewRow(entry: entry, onTap: () => onOpen(entry)),
          ],
        ],
      ),
    );
  }
}

class _MockFilterRow extends StatelessWidget {
  const _MockFilterRow({
    required this.active,
    required this.counts,
    required this.onChanged,
  });

  final ReviewFilter active;
  final ReviewCounts counts;
  final ValueChanged<ReviewFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    String label(ReviewFilter filter) => switch (filter) {
          ReviewFilter.all => 'All ${counts.all}',
          ReviewFilter.wrong => 'Wrong ${counts.wrong}',
          ReviewFilter.flagged => 'Flagged ${counts.flagged}',
        };
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.colors.ruleFaint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final filter in ReviewFilter.values)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(filter),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 32,
                  alignment: Alignment.center,
                  decoration: active == filter
                      ? BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(8),
                        )
                      : null,
                  child: Text(
                    label(filter),
                    style: context.textStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotesPrompt extends StatelessWidget {
  const _NotesPrompt({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tell Pantas why you got each one wrong. The better your notes, '
              'the more every review helps.',
            ),
            const SizedBox(height: 12),
            BoardButton(label: 'Finish the Notes', onPressed: onPressed),
          ],
        ),
      );
}

class _FlagOffer extends StatelessWidget {
  const _FlagOffer({
    required this.count,
    required this.onKeep,
    required this.onDismiss,
  });
  final int count;
  final VoidCallback onKeep;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You flagged $count questions while the clock was running. '
              'Do you want to save them?',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BoardButton(
                    label: 'No Thanks',
                    onPressed: onDismiss,
                    secondary: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BoardButton(
                    label: 'Save All $count',
                    onPressed: onKeep,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _PartHeader extends StatelessWidget {
  const _PartHeader({required this.name, required this.label});
  final String name;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name.toUpperCase(),
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colors.inkMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              label,
              style: context.textStyles.bodySmall
                  .copyWith(color: context.colors.inkMuted),
            ),
          ],
        ),
      );
}

class _MockReviewRow extends StatelessWidget {
  const _MockReviewRow({required this.entry, required this.onTap});
  final ReviewEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outcomeColor =
        entry.isCorrect ? context.colors.board : context.colors.rust;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.colors.ruleFaint,
              width: AppDimensions.hairline,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${entry.number}',
                style: context.textStyles.bodyMedium
                    .copyWith(color: outcomeColor, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PortableTextRenderer(
                    text: entry.label,
                    maxLines: entry.labelIsStem ? 2 : null,
                  ),
                  if (!entry.isAnswered) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Left blank',
                      style: context.textStyles.bodySmall
                          .copyWith(color: context.colors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionViewer extends StatelessWidget {
  const _QuestionViewer({
    required this.entries,
    required this.index,
    required this.proIsActive,
    required this.noteOpen,
    required this.onPrevious,
    required this.onNext,
    required this.onNote,
    required this.onBlankReason,
    required this.onMissReason,
  });

  final List<ReviewEntry> entries;
  final int index;
  final bool proIsActive;
  final bool noteOpen;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onNote;
  final Future<void> Function(BlankReason reason, String? note) onBlankReason;
  final Future<void> Function(MissReason reason, String? note) onMissReason;

  @override
  Widget build(BuildContext context) {
    final entry = entries[index];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PortableTextRenderer(text: entry.question.stem),
          const SizedBox(height: 18),
          for (final choice in entry.question.choices)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 28, child: Text(choice.label)),
                  Expanded(child: PortableTextRenderer(text: choice.text)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          AnswerReveal(
            question: entry.question,
            chosenChoiceId: entry.chosenChoiceId ?? '',
            proIsActive: proIsActive,
          ),
          if (noteOpen && proIsActive && !entry.isCorrect) ...[
            const SizedBox(height: 16),
            _ReasonPanel(
              isBlank: !entry.isAnswered,
              onBlankReason: onBlankReason,
              onMissReason: onMissReason,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: Icon(PantasIcons.back),
                tooltip: 'Previous question',
              ),
              Expanded(
                child: Text(
                  '${index + 1} of ${entries.length}',
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (proIsActive)
                IconButton(
                  onPressed: onNote,
                  icon: Icon(PantasIcons.addNote),
                  tooltip: 'Add note',
                )
              else
                const SizedBox(width: 48),
              IconButton(
                onPressed: onNext,
                icon: Icon(PantasIcons.next),
                tooltip: 'Next question',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReasonPanel extends StatefulWidget {
  const _ReasonPanel({
    required this.isBlank,
    required this.onBlankReason,
    required this.onMissReason,
  });
  final bool isBlank;
  final Future<void> Function(BlankReason reason, String? note) onBlankReason;
  final Future<void> Function(MissReason reason, String? note) onMissReason;

  @override
  State<_ReasonPanel> createState() => _ReasonPanelState();
}

class _ReasonPanelState extends State<_ReasonPanel> {
  final TextEditingController _controller = TextEditingController();
  bool _typing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.isBlank ? 'Why did you leave it blank?' : 'Why did you miss it?';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: context.textStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (widget.isBlank) ...[
            _ReasonChoice(
              label: 'I ran out of time',
              onTap: () => widget.onBlankReason(BlankReason.ranOutOfTime, null),
            ),
            _ReasonChoice(
              label: 'I skipped it to come back later',
              onTap: () =>
                  widget.onBlankReason(BlankReason.skippedToReturn, null),
            ),
            _ReasonChoice(
              label: "I didn't know it",
              onTap: () => widget.onBlankReason(BlankReason.didNotKnow, null),
            ),
          ] else ...[
            _ReasonChoice(
              label: 'I misread it',
              onTap: () => widget.onMissReason(MissReason.misread, null),
            ),
            _ReasonChoice(
              label: 'I knew it, I just slipped',
              onTap: () => widget.onMissReason(MissReason.slipped, null),
            ),
            _ReasonChoice(
              label: "I didn't know it",
              onTap: () => widget.onMissReason(MissReason.unknown, null),
            ),
          ],
          _ReasonChoice(
            label: 'Type my own',
            onTap: () => setState(() => _typing = true),
          ),
          if (_typing) ...[
            const SizedBox(height: 8),
            TextField(controller: _controller, maxLines: 3),
            const SizedBox(height: 8),
            BoardButton(
              label: 'Save Note',
              onPressed: () {
                final note = _controller.text.trim();
                if (note.isEmpty) return;
                if (widget.isBlank) {
                  widget.onBlankReason(BlankReason.other, note);
                } else {
                  widget.onMissReason(MissReason.other, note);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ReasonChoice extends StatelessWidget {
  const _ReasonChoice({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(label),
        ),
      );
}
