import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_question.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_review_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
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

  int _flagEpoch = 0;

  @override
  void initState() {
    super.initState();
    String? actor(AsyncValue<AuthState>? state) => switch (state?.valueOrNull) {
          SignedInAuthState(:final user) => user.uid,
          AnonymousAuthState(:final uid) => uid,
          _ => null,
        };
    ref.listenManual(authStateProvider, (previous, next) {
      if (actor(previous) != actor(next)) _flagEpoch++;
    });
  }

  bool _flagContextCurrent(int epoch, String? uid, String? Function() actor) =>
      mounted && _flagEpoch == epoch && actor() == uid;

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(mockReviewProvider(widget.attemptId));
    final markedAsync =
        ref.watch(mockMarkedQuestionIdsProvider(widget.attemptId));
    final handledAsync = ref.watch(mockOfferHandledProvider(widget.attemptId));
    final savedFlags = ref.watch(mockSavedFlagIdsProvider);
    final savedAnswers = widget.proIsActive
        ? ref.watch(mockReviewAnswersProvider(widget.attemptId))
        : const AsyncData<Map<String, MockAnswer>>({});
    final shown = reviewAsync.valueOrNull;
    final filtered =
        shown == null ? null : FilterReviewEntries.call(shown, _filter);
    final index = _viewerIndex;
    final viewed = index != null &&
            filtered != null &&
            index >= 0 &&
            index < filtered.length
        ? filtered[index]
        : null;

    void back() {
      if (_viewerIndex == null) {
        Navigator.maybePop(context);
      } else {
        setState(() {
          _viewerIndex = null;
          _noteOpen = false;
        });
      }
    }

    final wide = context.wideWeb;
    final page = Scaffold(
      appBar: wide
          ? PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: WebTopBar(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: back,
                      icon: const Icon(Icons.chevron_left),
                      label: Text(
                        _viewerIndex == null ? 'Results' : 'All questions',
                      ),
                    ),
                    const WebKeyHint('Esc'),
                  ],
                ),
                trailing: viewed == null
                    ? null
                    : WebButton(
                        label: savedFlags.valueOrNull
                                    ?.contains(viewed.question.id) ??
                                false
                            ? 'Flagged'
                            : 'Flag',
                        keyHint: 'F',
                        variant: WebButtonVariant.tertiary,
                        onPressed: savedFlags.hasValue
                            ? () => _toggleFlag(viewed.question.id)
                            : null,
                      ),
              ),
            )
          : AppBar(
              title: Text(_viewerIndex == null ? 'Results' : 'All questions'),
              actions: [
                if (viewed != null && savedFlags.hasValue)
                  IconButton(
                    tooltip:
                        savedFlags.requireValue.contains(viewed.question.id)
                            ? 'Unflag question'
                            : 'Flag question',
                    icon: Icon(
                      PantasIcons.flag,
                      size: 21,
                      color:
                          savedFlags.requireValue.contains(viewed.question.id)
                              ? context.colors.accent
                              : context.colors.secondaryLabel,
                    ),
                    onPressed: () => _toggleFlag(viewed.question.id),
                  ),
              ],
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
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
        data: (entries) {
          final filtered = FilterReviewEntries.call(entries, _filter);
          final viewerIndex = _viewerIndex;
          if (viewerIndex != null &&
              viewerIndex >= 0 &&
              viewerIndex < filtered.length) {
            return _QuestionViewer(
              entries: filtered,
              index: viewerIndex,
              proIsActive: widget.proIsActive,
              noteOpen: _noteOpen && savedAnswers.hasValue,
              savedAnswer:
                  savedAnswers.valueOrNull?[filtered[viewerIndex].question.id],
              onNote: widget.proIsActive && savedAnswers.hasValue
                  ? () => setState(() => _noteOpen = !_noteOpen)
                  : null,
              onPrevious: viewerIndex > 0
                  ? () => setState(() {
                        _viewerIndex = viewerIndex - 1;
                        _noteOpen = wide && widget.proIsActive;
                      })
                  : null,
              onNext: viewerIndex + 1 < filtered.length
                  ? () => setState(() {
                        _viewerIndex = viewerIndex + 1;
                        _noteOpen = wide && widget.proIsActive;
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
              _noteOpen = wide && widget.proIsActive;
            }),
            onOpen: (entry) {
              final shown = FilterReviewEntries.call(entries, _filter);
              setState(() {
                _viewerIndex = shown.indexOf(entry);
                _noteOpen = wide && widget.proIsActive;
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
        error: (err, st) => errorFor(
          'mock review',
          () {
            if (ref.read(mockUsesServerProvider)) {
              ref.invalidate(serverMockResultProvider(widget.attemptId));
            }
            ref.invalidate(mockReviewProvider(widget.attemptId));
          },
          error: err,
        ),
      ),
    );
    if (!wide) return page;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): back,
        if (viewed != null && savedFlags.hasValue)
          const SingleActivator(LogicalKeyboardKey.keyF): () =>
              _toggleFlag(viewed.question.id),
      },
      child: Focus(autofocus: true, child: page),
    );
  }

  Future<void> _handleFlagOffer(
    Set<String> markedIds, {
    required bool keep,
  }) async {
    final epoch = _flagEpoch;
    final actor = ref.read(serverMockActorProvider);
    final uid = actor();
    final ids = Set<String>.of(markedIds);
    if (keep) {
      final flagRepo = ref.read(questionFlagsRepositoryProvider);
      for (final questionId in ids) {
        if (!_flagContextCurrent(epoch, uid, actor)) return;
        await flagRepo.flag(questionId);
      }
    }
    if (!_flagContextCurrent(epoch, uid, actor)) return;
    final prefsRepo = ref.read(appPreferencesRepositoryProvider);
    await prefsRepo.setDeviceValue(
      'mock_flag_offer_handled_${widget.attemptId}',
      'true',
    );
    if (!mounted) return;
    ref
      ..invalidate(mockOfferHandledProvider(widget.attemptId))
      ..invalidate(mockSavedFlagIdsProvider);
  }

  Future<void> _toggleFlag(String questionId) async {
    final epoch = _flagEpoch;
    final actor = ref.read(serverMockActorProvider);
    final uid = actor();
    final repo = ref.read(questionFlagsRepositoryProvider);
    final flagged = await repo.isFlagged(questionId);
    if (!_flagContextCurrent(epoch, uid, actor)) return;
    if (flagged) {
      await repo.unflag(questionId);
    } else {
      await repo.flag(questionId);
    }
    if (mounted) ref.invalidate(mockSavedFlagIdsProvider);
  }

  Future<void> _saveBlankReason(
    ReviewEntry entry,
    BlankReason reason,
    String? note,
  ) async {
    if (ref.read(mockUsesServerProvider)) {
      final uid = ref.read(serverMockIdentityProvider);
      if (uid == null || ref.read(serverMockActorProvider)() != uid) {
        throw const ServerMockException(code: 'cancelled');
      }
      await ref.read(serverMockApiProvider).saveReview(
            mockId: widget.attemptId,
            questionId: entry.question.id,
            blankReason: reason.name,
            reasonNote: note,
          );
      if (!mounted || ref.read(serverMockActorProvider)() != uid) return;
      ref.invalidate(serverMockResultProvider(widget.attemptId));
    } else {
      await ref.read(mockAttemptRepoProvider).saveReviewReason(
            attemptId: widget.attemptId,
            questionId: entry.question.id,
            savedAt: DateTime.now().toUtc(),
            blankReason: reason,
            reasonNote: note,
          );
    }
    if (mounted) {
      ref.invalidate(mockReviewAnswersProvider(widget.attemptId));
      setState(() => _noteOpen = false);
    }
  }

  Future<void> _saveMissReason(
    ReviewEntry entry,
    MissReason reason,
    String? note,
  ) async {
    if (ref.read(mockUsesServerProvider)) {
      final uid = ref.read(serverMockIdentityProvider);
      if (uid == null || ref.read(serverMockActorProvider)() != uid) {
        throw const ServerMockException(code: 'cancelled');
      }
      await ref.read(serverMockApiProvider).saveReview(
            mockId: widget.attemptId,
            questionId: entry.question.id,
            missReason: reason.name,
            reasonNote: note,
          );
      if (!mounted || ref.read(serverMockActorProvider)() != uid) return;
      ref.invalidate(serverMockResultProvider(widget.attemptId));
    } else {
      await ref.read(mockAttemptRepoProvider).saveReviewReason(
            attemptId: widget.attemptId,
            questionId: entry.question.id,
            savedAt: DateTime.now().toUtc(),
            missReason: reason,
            reasonNote: note,
          );
    }
    if (mounted) {
      ref.invalidate(mockReviewAnswersProvider(widget.attemptId));
      setState(() => _noteOpen = false);
    }
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

    if (context.wideWeb) {
      final t = context.webTokens;
      return SingleChildScrollView(
        key: const ValueKey('web-mock-review'),
        padding: const EdgeInsets.fromLTRB(40, 24, 40, 56),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('All questions', style: t.h1),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 460,
                    child: WebSegmentedControl(
                      labels: [
                        'All ${counts.all}',
                        'Wrong ${counts.wrong}',
                        'Flagged ${counts.flagged}',
                      ],
                      selected: ReviewFilter.values.indexOf(filter),
                      onChanged: (index) =>
                          onFilter(ReviewFilter.values[index]),
                    ),
                  ),
                ),
                if (proIsActive && filter == ReviewFilter.wrong) ...[
                  const SizedBox(height: 20),
                  WebCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tell Pantas why you got each one wrong. The '
                            'better your notes, the more every review '
                            'helps.',
                            style: t.sub,
                          ),
                        ),
                        const SizedBox(width: 24),
                        WebButton(
                          label: 'Finish the Notes',
                          variant: WebButtonVariant.secondary,
                          onPressed: onFinishNotes,
                        ),
                      ],
                    ),
                  ),
                ],
                if (showFlagOffer) ...[
                  const SizedBox(height: 20),
                  WebCard(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'You flagged $markedCount questions while the '
                          'clock was running. Do you want to save them?',
                          style: t.sub,
                        ),
                        WebButton(
                          label: 'No Thanks',
                          variant: WebButtonVariant.tertiary,
                          onPressed: onDismissFlags,
                        ),
                        WebButton(
                          label: 'Save All $markedCount',
                          onPressed: onKeepFlags,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                for (final group in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 9),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.key,
                            style: t.style(
                              17,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(groupLabel(group.value), style: t.sub),
                      ],
                    ),
                  ),
                  WebCard(
                    child: Column(
                      children: [
                        for (final entry in group.value)
                          WebRow(
                            title: entry.label,
                            subtitle: entry.isAnswered ? null : 'Left blank',
                            titleStyle: t.style(16),
                            leading: Container(
                              width: filter == ReviewFilter.wrong ? 34 : 30,
                              height: filter == ReviewFilter.wrong ? null : 30,
                              alignment: filter == ReviewFilter.wrong
                                  ? Alignment.centerLeft
                                  : Alignment.center,
                              decoration: filter == ReviewFilter.wrong
                                  ? null
                                  : BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: entry.isCorrect
                                          ? t.colors.accentTint
                                          : t.colors.wrongTint,
                                    ),
                              child: Text(
                                '${entry.number}',
                                style: t.style(
                                  filter == ReviewFilter.wrong ? 15 : 12,
                                  weight: FontWeight.w600,
                                  color: entry.isCorrect
                                      ? t.colors.accent
                                      : t.colors.wrongText,
                                ),
                              ),
                            ),
                            onPressed: () => onOpen(entry),
                            divider: entry != group.value.last,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('All questions', style: context.type.sectionHero),
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
        color: context.colors.fill,
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
                    style: context.type.subhead
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
            PantasButton(label: 'Finish the Notes', onPressed: onPressed),
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
                  child: PantasButton(
                    label: 'No Thanks',
                    onPressed: onDismiss,
                    variant: PantasButtonVariant.tertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PantasButton(
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
                style: context.type.subhead.copyWith(
                  color: context.colors.secondaryLabel,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              label,
              style: context.type.subhead
                  .copyWith(color: context.colors.secondaryLabel),
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
        entry.isCorrect ? context.colors.accent : context.colors.destructive;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.colors.fill,
              width: 0.5,
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
                style: context.type.subhead
                    .copyWith(color: outcomeColor, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContentRenderer(
                    text: entry.label,
                    maxLines: entry.labelIsStem ? 2 : null,
                  ),
                  if (!entry.isAnswered) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Left blank',
                      style: context.type.subhead
                          .copyWith(color: context.colors.secondaryLabel),
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
    this.savedAnswer,
  });

  final MockAnswer? savedAnswer;
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
    if (context.wideWeb) {
      return CallbackShortcuts(
        bindings: {
          if (onPrevious != null)
            const SingleActivator(LogicalKeyboardKey.arrowLeft): onPrevious!,
          if (onNext != null)
            const SingleActivator(LogicalKeyboardKey.arrowRight): onNext!,
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(40, 32, 40, 140),
                child: WebQuizQuestion(
                  question: entry.question,
                  subject: entry.subjectName,
                  passage: entry.passage,
                  chosenId: entry.chosenChoiceId,
                  checked: true,
                  pro: proIsActive,
                  notes: noteOpen && proIsActive && !entry.isCorrect
                      ? _ReasonPanel(
                          key: ValueKey(entry.question.id),
                          savedAnswer: savedAnswer,
                          isBlank: !entry.isAnswered,
                          onBlankReason: onBlankReason,
                          onMissReason: onMissReason,
                          onCancel: onNote,
                        )
                      : proIsActive && !entry.isCorrect
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: onNote,
                                icon: Icon(PantasIcons.addNote),
                                tooltip: 'Add note',
                              ),
                            )
                          : null,
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 28,
                child: Center(
                  child: WebBottomBar(
                    compact: true,
                    state:
                        entry.isCorrect ? WebBarState.right : WebBarState.wrong,
                    counter: '${index + 1} of ${entries.length}',
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Previous question',
                          onPressed: onPrevious,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        const WebKeyHint('←'),
                      ],
                    ),
                    action: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const WebKeyHint('→'),
                        IconButton(
                          tooltip: 'Next question',
                          onPressed: onNext,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QuestionCard(
            subject: entry.subjectName,
            stem: entry.question.stem,
            passage: entry.passage == null
                ? null
                : PassageCard(
                    title: entry.passage!.title,
                    text: entry.passage!.body,
                  ),
            figure: entry.question.figureSpecJson == null
                ? null
                : QuestionFigure(specJson: entry.question.figureSpecJson),
            choices: [
              for (final choice in entry.question.choices)
                ChoiceRow(
                  letter: choice.label,
                  text: choice.text,
                  state: choice.isCorrect
                      ? ChoiceRowState.right
                      : choice.id == entry.chosenChoiceId
                          ? ChoiceRowState.wrong
                          : ChoiceRowState.dimmed,
                ),
            ],
          ),
          const SizedBox(height: 16),
          AnswerReveal(
            correctLetter: entry.question.correctChoice.label,
            explanation: entry.question.explanation,
            pickedLetter: entry.question.choices
                .where((c) => c.id == entry.chosenChoiceId)
                .firstOrNull
                ?.label,
            wrongPick: proIsActive && !entry.isCorrect
                ? entry.question.choices
                    .where((c) => c.id == entry.chosenChoiceId)
                    .firstOrNull
                    ?.rationale
                : null,
          ),
          if (noteOpen && proIsActive && !entry.isCorrect) ...[
            const SizedBox(height: 16),
            _ReasonPanel(
              key: ValueKey(entry.question.id),
              savedAnswer: savedAnswer,
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
                  style: context.type.subhead
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
    super.key,
    this.savedAnswer,
    this.onCancel,
  });
  final VoidCallback? onCancel;
  final bool isBlank;
  final MockAnswer? savedAnswer;
  final Future<void> Function(BlankReason reason, String? note) onBlankReason;
  final Future<void> Function(MissReason reason, String? note) onMissReason;

  @override
  State<_ReasonPanel> createState() => _ReasonPanelState();
}

class _ReasonPanelState extends State<_ReasonPanel> {
  final _shortcutFocus = FocusNode();
  late final TextEditingController _controller;
  late bool _typing;
  int? _selected;
  bool _saving = false;
  Future<void> Function()? _retry;

  Future<void> _save(Future<void> Function() operation) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _retry = null;
    });
    try {
      await operation();
    } on Object {
      if (mounted) setState(() => _retry = operation);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.savedAnswer?.reasonNote ?? '');
    _typing = widget.savedAnswer?.blankReason == BlankReason.other ||
        widget.savedAnswer?.missReason == MissReason.other;
    final saved = widget.savedAnswer;
    if (saved != null) {
      _selected = widget.isBlank
          ? switch (saved.blankReason) {
              BlankReason.ranOutOfTime => 0,
              BlankReason.skippedToReturn => 1,
              BlankReason.didNotKnow => 2,
              BlankReason.other => 3,
              null => null
            }
          : switch (saved.missReason) {
              MissReason.misread => 0,
              MissReason.slipped => 1,
              MissReason.unknown => 2,
              MissReason.other => 3,
              null => null
            };
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.wideWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _shortcutFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _shortcutFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) return _wide(context);
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
            style: context.type.subhead.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (widget.isBlank) ...[
            _ReasonChoice(
              label: 'I ran out of time',
              selected:
                  widget.savedAnswer?.blankReason == BlankReason.ranOutOfTime,
              onTap: () => _save(
                () => widget.onBlankReason(BlankReason.ranOutOfTime, null),
              ),
            ),
            _ReasonChoice(
              label: 'I skipped it to come back later',
              selected: widget.savedAnswer?.blankReason ==
                  BlankReason.skippedToReturn,
              onTap: () => _save(
                () => widget.onBlankReason(BlankReason.skippedToReturn, null),
              ),
            ),
            _ReasonChoice(
              label: "I didn't know it",
              selected:
                  widget.savedAnswer?.blankReason == BlankReason.didNotKnow,
              onTap: () => _save(
                () => widget.onBlankReason(BlankReason.didNotKnow, null),
              ),
            ),
          ] else ...[
            _ReasonChoice(
              label: 'I misread it',
              selected: widget.savedAnswer?.missReason == MissReason.misread,
              onTap: () =>
                  _save(() => widget.onMissReason(MissReason.misread, null)),
            ),
            _ReasonChoice(
              label: 'I knew it, I just slipped',
              selected: widget.savedAnswer?.missReason == MissReason.slipped,
              onTap: () =>
                  _save(() => widget.onMissReason(MissReason.slipped, null)),
            ),
            _ReasonChoice(
              label: "I didn't know it",
              selected: widget.savedAnswer?.missReason == MissReason.unknown,
              onTap: () =>
                  _save(() => widget.onMissReason(MissReason.unknown, null)),
            ),
          ],
          _ReasonChoice(
            label: 'Type my own',
            selected: _typing,
            onTap: () => setState(() => _typing = true),
          ),
          if (_retry != null) saveFailureLine(() => _save(_retry!)),
          if (_typing) ...[
            const SizedBox(height: 8),
            TextField(controller: _controller, maxLines: 3),
            const SizedBox(height: 8),
            PantasButton(
              label: 'Save Note',
              onPressed: () {
                final note = _controller.text.trim();
                if (note.isEmpty) return;
                if (widget.isBlank) {
                  _save(() => widget.onBlankReason(BlankReason.other, note));
                } else {
                  _save(() => widget.onMissReason(MissReason.other, note));
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _wide(BuildContext context) {
    final t = context.webTokens;
    final labels = widget.isBlank
        ? [
            'I ran out of time',
            'I skipped it to come back later',
            "I didn't know it",
            'Type my own',
          ]
        : [
            'I misread it',
            'I knew it, I just slipped',
            "I didn't know it",
            'Type my own',
          ];
    void choose(int index) {
      if (!_saving) {
        setState(() {
          _selected = index;
          _typing = index == 3;
        });
      }
    }

    void commit() {
      final selected = _selected;
      if (selected == null || _saving) return;
      final note = _typing ? _controller.text.trim() : null;
      if (_typing && note!.isEmpty) return;
      if (widget.isBlank) {
        const reasons = [
          BlankReason.ranOutOfTime,
          BlankReason.skippedToReturn,
          BlankReason.didNotKnow,
          BlankReason.other,
        ];
        _save(() => widget.onBlankReason(reasons[selected], note));
      } else {
        const reasons = [
          MissReason.misread,
          MissReason.slipped,
          MissReason.unknown,
          MissReason.other,
        ];
        _save(() => widget.onMissReason(reasons[selected], note));
      }
    }

    return CallbackShortcuts(
      bindings: {
        for (final (i, key) in [
          LogicalKeyboardKey.digit1,
          LogicalKeyboardKey.digit2,
          LogicalKeyboardKey.digit3,
          LogicalKeyboardKey.digit4,
        ].indexed)
          SingleActivator(key): () {
            if (FocusManager.instance.primaryFocus?.context?.widget
                is EditableText) {
              return;
            }
            choose(i);
          },
      },
      child: Focus(
        focusNode: _shortcutFocus,
        autofocus: true,
        child: WebCard(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isBlank
                    ? 'Why did you leave it blank?'
                    : 'Why did you miss it?',
                style: t.style(17, weight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (i, label) in labels.indexed)
                    TextButton(
                      onPressed: _saving ? null : () => choose(i),
                      style: TextButton.styleFrom(
                        backgroundColor: _selected == i
                            ? t.colors.accentTint
                            : t.colors.fill,
                        foregroundColor:
                            _selected == i ? t.tintText : t.colors.label,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WebKeyHint('${i + 1}'),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(label, style: t.style(14)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (_typing) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'In your own words',
                  ),
                ),
              ],
              if (_retry != null) saveFailureLine(() => _save(_retry!)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  WebButton(
                    label: 'Not Now',
                    variant: WebButtonVariant.tertiary,
                    onPressed: _saving ? null : widget.onCancel,
                  ),
                  const SizedBox(width: 8),
                  WebButton(
                    label: 'Add Note',
                    busy: _saving,
                    onPressed: _selected == null ||
                            (_typing && _controller.text.trim().isEmpty)
                        ? null
                        : commit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReasonChoice extends StatelessWidget {
  const _ReasonChoice({
    required this.label,
    required this.onTap,
    this.selected = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
        selected: selected,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(label)),
              ],
            ),
          ),
        ),
      );
}
