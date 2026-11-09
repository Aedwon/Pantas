import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/components/new_design/passage_card.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_field.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_tooltip.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/figures/question_figure.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_question.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/mock_exam/application/mock_review_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_providers.dart';
import 'package:pantas/features/mock_exam/application/server_mock_results_providers.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_tap.dart';

/// The width of the question filter (board width; the system sets no token).
const _filterWidth = 464.0;

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
    firstScreenReady(
      context,
      ref,
      ready: !reviewAsync.isLoading &&
          !markedAsync.isLoading &&
          !handledAsync.isLoading &&
          !savedFlags.isLoading &&
          !savedAnswers.isLoading,
    );
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
        leavePage(
          context,
          fallback: '/mock/results/${widget.attemptId}',
        );
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
                leading: Transform.translate(
                  offset: const Offset(-6, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WebBackLink(
                        label:
                            _viewerIndex == null ? 'Results' : 'All questions',
                        onPressed: back,
                        nudge: false,
                      ),
                      // No gap: the link's own right padding is the room.
                      const WebKeyHint('Esc'),
                    ],
                  ),
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
              // MK_Review*: the list page has a green "< Results" text link
              // instead of a centered title.
              // The route's own back arrow stays out; the green link is the
              // back control (MK_ReviewAll).
              // MK_ReviewQ: the viewer has the same green link as the list
              // (QN_*): "< All questions" with the flag at the end.
              automaticallyImplyLeading: false,
              toolbarHeight: 46,
              leadingWidth: 0,
              titleSpacing: 4,
              centerTitle: false,
              title: Padding(
                // MK_ReviewAll: the link sits 5 px lower.
                padding: const EdgeInsets.only(top: PantasSpace.s8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _viewerIndex == null
                      ? WebBackLink(
                          label: 'Results',
                          onPressed: back,
                          nudge: false,
                        )
                      : PantasTooltip(
                          message: 'Back to questions',
                          child: WebBackLink(
                            label: 'All questions',
                            onPressed: back,
                            nudge: false,
                          ),
                        ),
                ),
              ),
              actions: [
                if (viewed != null && savedFlags.hasValue)
                  Padding(
                    // MK_ReviewQ: the icon sits level with the link.
                    padding: const EdgeInsets.only(top: PantasSpace.s10),
                    child: PantasIconButton(
                      tooltip:
                          savedFlags.requireValue.contains(viewed.question.id)
                              ? 'Unflag question'
                              : 'Flag question',
                      glyph: PantasIcons.flag,
                      toggled:
                          savedFlags.requireValue.contains(viewed.question.id),
                      onPressed: () => _toggleFlag(viewed.question.id),
                    ),
                  ),
                if (viewed != null && savedFlags.hasValue)
                  const SizedBox(width: PantasSpace.s8),
              ],
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
        loading: () => const SafeArea(child: SkeletonQuestionPage()),
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
    return LetterShortcuts(
      also: {const SingleActivator(LogicalKeyboardKey.escape): back},
      bindings: {
        if (viewed != null && savedFlags.hasValue)
          'f': () => _toggleFlag(viewed.question.id),
      },
      child: KeyFocusKeeper(child: page),
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
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s40,
          PantasSpace.s16,
          PantasSpace.s40,
          PantasSpace.s56,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('All questions', style: t.h1),
                const SizedBox(height: PantasSpace.s20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: _filterWidth,
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
                  const SizedBox(height: PantasSpace.s20),
                  WebCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PantasSpace.s20,
                      vertical: PantasSpace.s18,
                    ),
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
                        const SizedBox(width: PantasSpace.s24),
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
                  const SizedBox(height: PantasSpace.s20),
                  WebCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PantasSpace.s20,
                      vertical: PantasSpace.s18,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'You flagged $markedCount '
                            "${markedCount == 1 ? 'question' : 'questions'} "
                            'while the clock was running. Do you want to '
                            'save them?',
                            style: t.sub.copyWith(color: t.colors.label),
                          ),
                        ),
                        const SizedBox(width: PantasSpace.s18),
                        WebButton(
                          label: 'No Thanks',
                          variant: WebButtonVariant.tertiary,
                          onPressed: onDismissFlags,
                        ),
                        const SizedBox(width: PantasSpace.s8),
                        WebButton(
                          label: 'Save All $markedCount',
                          onPressed: onKeepFlags,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: PantasSpace.s20),
                for (final group in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PantasSpace.s4,
                      PantasSpace.s0,
                      PantasSpace.s4,
                      PantasSpace.s10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(group.key.toUpperCase(), style: t.eb),
                        ),
                        Text(
                          groupLabel(group.value),
                          style: t.sm.copyWith(
                            fontFeatures: [const FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  WebCard(
                    child: Column(
                      children: [
                        for (final entry in group.value)
                          WebRow(
                            mathTitle: entry.labelIsStem,
                            title: entry.label,
                            compact: true,
                            chevron: WebRowChevron.always,
                            trailing: entry.isAnswered
                                ? null
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: PantasSpace.s8,
                                      vertical: PantasSpace.s2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.disabledBackground,
                                      borderRadius: BorderRadius.circular(
                                        PantasRadius.full,
                                      ),
                                    ),
                                    child: Text(
                                      'Left blank',
                                      style: PantasType.webCaption.copyWith(
                                        color: t.colors.secondaryLabel,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                            titleStyle: PantasType.webBody
                                .copyWith(color: t.colors.textPrimary),
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
                                style: (filter == ReviewFilter.wrong
                                        ? PantasType.webSub
                                        : PantasType.webCaption)
                                    .copyWith(
                                  fontWeight: filter == ReviewFilter.wrong
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: entry.isCorrect
                                      ? t.colors.accent
                                      : t.colors.dangerText,
                                ),
                              ),
                            ),
                            onPressed: () => onOpen(entry),
                            divider: entry != group.value.last,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s24),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s16,
        PantasSpace.s8,
        PantasSpace.s16,
        PantasSpace.s24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
            child: Text(
              'All questions',
              style: PantasType.phoneTitle1
                  .copyWith(color: context.colors.textPrimary),
            ),
          ),
          const SizedBox(height: PantasSpace.s20),
          _MockFilterRow(active: filter, counts: counts, onChanged: onFilter),
          if (proIsActive && filter == ReviewFilter.wrong) ...[
            const SizedBox(height: PantasSpace.s24),
            _NotesPrompt(onPressed: onFinishNotes),
          ],
          if (showFlagOffer) ...[
            const SizedBox(height: PantasSpace.s24),
            _FlagOffer(
              count: markedCount,
              onKeep: onKeepFlags,
              onDismiss: onDismissFlags,
            ),
          ],
          for (final group in groups.entries) ...[
            const SizedBox(height: PantasSpace.s24),
            _PartHeader(
              name: group.key,
              label: groupLabel(group.value),
            ),
            // MK_Review*: one white card per section.
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(PantasRadius.lg),
              ),
              child: Column(
                children: [
                  for (final entry in group.value)
                    _MockReviewRow(
                      entry: entry,
                      onTap: () => onOpen(entry),
                      divider: entry != group.value.last,
                    ),
                ],
              ),
            ),
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
    const filters = ReviewFilter.values;
    return SegmentedSwitch(
      labels: [for (final filter in filters) label(filter)],
      selected: filters.indexOf(active),
      onChanged: (index) => onChanged(filters[index]),
    );
  }
}

class _NotesPrompt extends StatelessWidget {
  const _NotesPrompt({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s16,
          PantasSpace.s16,
          PantasSpace.s16,
          PantasSpace.s14,
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(PantasRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // MK_ReviewWrong: 15 px text on 22 px lines, a 44 px tinted pill.
            Text(
              'Tell Pantas why you got each one wrong. The better your notes, '
              'the more every review helps.',
              style: context.type.subhead.copyWith(height: 22 / 15),
            ),
            const SizedBox(height: PantasSpace.s10),
            PantasButton(
              label: 'Finish the Notes',
              onPressed: onPressed,
              variant: PantasButtonVariant.secondary,
              height: PantasSize.btn,
              radius: PantasRadius.full,
              fontSize: PantasType.webButton.fontSize,
            ),
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
        padding: const EdgeInsets.all(PantasSpace.s16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(PantasRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You flagged $count '
              "${count == 1 ? 'question' : 'questions'} while the clock "
              'was running. Do you want to save them?',
              style: context.type.subhead.copyWith(
                fontWeight: FontWeight.w500,
                height: 22 / 15,
              ),
            ),
            const SizedBox(height: PantasSpace.s12),
            Row(
              children: [
                Expanded(
                  child: PantasButton(
                    label: 'No Thanks',
                    onPressed: onDismiss,
                    variant: PantasButtonVariant.neutral,
                    height: PantasSize.btnSm,
                    radius: PantasRadius.full,
                    fontSize: PantasType.webButton.fontSize,
                  ),
                ),
                const SizedBox(width: PantasSpace.s10),
                Expanded(
                  child: PantasButton(
                    label: 'Save All $count',
                    onPressed: onKeep,
                    variant: PantasButtonVariant.secondary,
                    height: PantasSize.btnSm,
                    radius: PantasRadius.full,
                    fontSize: PantasType.webButton.fontSize,
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
  Widget build(BuildContext context) {
    final style = PantasType.phoneSectionHeader.copyWith(
      color: context.colors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s16,
        PantasSpace.s0,
        PantasSpace.s16,
        PantasSpace.s8,
      ),
      child: Row(
        children: [
          Expanded(child: Text(name.toUpperCase(), style: style)),
          Text(
            label,
            style: style.copyWith(
              letterSpacing: 0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MockReviewRow extends StatelessWidget {
  const _MockReviewRow({
    required this.entry,
    required this.onTap,
    required this.divider,
  });
  final ReviewEntry entry;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final outcomeColor =
        entry.isCorrect ? context.colors.accent : context.colors.wrongText;
    return MockTap(
      onTap: onTap,
      radius: PantasRadius.sm,
      child: Padding(
        padding: const EdgeInsets.only(left: PantasSpace.s16),
        child: Row(
          children: [
            SizedBox(
              width: PantasSpace.s44,
              child: Text(
                '${entry.number}',
                style: context.type.subheadStrong.copyWith(
                  color: outcomeColor,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s0,
                  PantasSpace.s10,
                  PantasSpace.s16,
                  PantasSpace.s10,
                ),
                constraints: const BoxConstraints(minHeight: 46),
                decoration: BoxDecoration(
                  border: divider
                      ? Border(
                          bottom: BorderSide(
                            color: context.colors.separator,
                            width: .5,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (entry.labelIsStem)
                            PantasTooltip(
                              message: ContentRenderer.plainText(entry.label),
                              child: ContentRenderer(
                                text: entry.label,
                                questionStem: true,
                                maxLines: 1,
                              ),
                            )
                          else
                            ContentRenderer(text: entry.label),
                          if (!entry.isAnswered) ...[
                            const SizedBox(height: PantasSpace.s4),
                            Text(
                              'Left blank',
                              style: context.type.footnote.copyWith(
                                color: context.colors.secondaryLabel,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: PantasSpace.s8),
                    Icon(
                      PantasIcons.next,
                      size: 16,
                      color: context.colors.tertiaryLabel,
                    ),
                  ],
                ),
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
        child: KeyFocusKeeper(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s40,
                  PantasSpace.s56,
                  PantasSpace.s40,
                  PantasLayout.reserveBar,
                ),
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
                              child: PantasIconButton(
                                onPressed: onNote,
                                glyph: PantasIcons.addNote,
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
                    gap: 6,
                    counterPadding:
                        const EdgeInsets.symmetric(horizontal: PantasSpace.s14),
                    state:
                        entry.isCorrect ? WebBarState.right : WebBarState.wrong,
                    counter: '${index + 1} of ${entries.length}',
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        WebBarArrow(
                          tooltip: 'Previous question',
                          onPressed: onPrevious,
                          icon: Icons.chevron_left,
                        ),
                        const SizedBox(width: PantasSpace.s6),
                        const WebKeyHint('←'),
                      ],
                    ),
                    action: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const WebKeyHint('→'),
                        const SizedBox(width: PantasSpace.s6),
                        WebBarArrow(
                          tooltip: 'Next question',
                          onPressed: onNext,
                          icon: Icons.chevron_right,
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
    // MK_ReviewQ: the same page as the quiz viewer (QN_*): 16 px sides and
    // a floating bar with the arrows, counter and note icon.
    Widget arrow(String tooltip, IconData icon, VoidCallback? onPressed) =>
        PantasIconButton(
          tooltip: tooltip,
          glyph: icon,
          onPressed: onPressed,
        );
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s16,
            PantasSpace.s16,
            PantasSpace.s16,
            PantasLayout.reserveBarPhone,
          ),
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
              const SizedBox(height: PantasSpace.s20),
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
                const SizedBox(height: PantasSpace.s16),
                _ReasonPanel(
                  key: ValueKey(entry.question.id),
                  savedAnswer: savedAnswer,
                  isBlank: !entry.isAnswered,
                  onBlankReason: onBlankReason,
                  onMissReason: onMissReason,
                ),
              ],
            ],
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 26,
          child: FloatingBar.content(
            state: entry.isCorrect
                ? FloatingBarState.right
                : FloatingBarState.wrong,
            inset: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s4,
                PantasSpace.s8,
                PantasSpace.s8,
                PantasSpace.s8,
              ),
              child: Row(
                children: [
                  arrow('Previous question', PantasIcons.back, onPrevious),
                  const SizedBox(width: PantasSpace.s14),
                  Text(
                    '${index + 1} of ${entries.length}',
                    style: PantasType.webLink.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (proIsActive)
                    PantasIconButton(
                      tooltip: 'Add note',
                      glyph: PantasIcons.addNote,
                      onPressed: onNote,
                    ),
                  arrow('Next question', PantasIcons.next, onNext),
                ],
              ),
            ),
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(PantasSpace.s16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(PantasRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: context.type.subhead.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: PantasSpace.s10),
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
              label: "I didn't know",
              selected:
                  widget.savedAnswer?.blankReason == BlankReason.didNotKnow,
              onTap: () => _save(
                () => widget.onBlankReason(BlankReason.didNotKnow, null),
              ),
            ),
          ] else ...[
            _ReasonChoice(
              label: 'I misread',
              selected: widget.savedAnswer?.missReason == MissReason.misread,
              onTap: () =>
                  _save(() => widget.onMissReason(MissReason.misread, null)),
            ),
            _ReasonChoice(
              label: 'I forgot',
              selected: widget.savedAnswer?.missReason == MissReason.slipped,
              onTap: () =>
                  _save(() => widget.onMissReason(MissReason.slipped, null)),
            ),
            _ReasonChoice(
              label: "I didn't know",
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
            const SizedBox(height: PantasSpace.s8),
            PantasField.unlabeled(
              semanticLabel: 'Type my own',
              controller: _controller,
              multiline: true,
              maxLines: 3,
            ),
            const SizedBox(height: PantasSpace.s8),
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
            "I didn't know",
            'Type my own',
          ]
        : [
            'I misread',
            'I forgot',
            "I didn't know",
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

    return LetterShortcuts(
      bindings: {
        for (final (i, key) in const ['1', '2', '3', '4'].indexed)
          key: () {
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
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s20,
            PantasSpace.s20,
            PantasSpace.s20,
            PantasSpace.s18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CustomPaint(
                    size: const Size.square(20),
                    painter: _NoteGlyphPainter(t.colors.accent),
                  ),
                  const SizedBox(width: PantasSpace.s10),
                  Expanded(
                    child: Text(
                      widget.isBlank
                          ? 'Why did you leave it blank?'
                          : 'Why did you miss it?',
                      style: PantasType.webLead.copyWith(
                        color: t.colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PantasSpace.s14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = (constraints.maxWidth - 8) / 2;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (i, label) in labels.indexed)
                        SizedBox(
                          width: width,
                          child: MockTap(
                            onTap: _saving ? null : () => choose(i),
                            selectedFill:
                                _selected == i ? t.colors.accentTint : null,
                            restFill: t.colors.background,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: PantasSize.field,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PantasSpace.s12,
                                  vertical: PantasSpace.s8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    WebKeyHint('${i + 1}'),
                                    const SizedBox(width: PantasSpace.s10),
                                    Flexible(
                                      child: Text(
                                        label,
                                        style: PantasType.webSub.copyWith(
                                          color: t.colors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (_typing) ...[
                const SizedBox(height: PantasSpace.s14),
                PantasField.unlabeled(
                  semanticLabel: 'Type my own',
                  hint: 'In your own words',
                  controller: _controller,
                  multiline: true,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                ),
              ],
              if (_retry != null) saveFailureLine(() => _save(_retry!)),
              const SizedBox(height: PantasSpace.s14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  WebButton(
                    label: 'Not Now',
                    variant: WebButtonVariant.tertiary,
                    onPressed: _saving ? null : widget.onCancel,
                  ),
                  const SizedBox(width: PantasSpace.s8),
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
  Widget build(BuildContext context) => RadioRow(
        title: label,
        selected: selected,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: PantasSpace.s10),
      );
}

/// The note icon beside the reason question (board, 20 px, teal).
class _NoteGlyphPainter extends CustomPainter {
  const _NoteGlyphPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(
        Path()
          ..moveTo(4.5 * k, 4.5 * k)
          ..lineTo(19.5 * k, 4.5 * k)
          ..lineTo(19.5 * k, 14.5 * k)
          ..lineTo(14.5 * k, 19.5 * k)
          ..lineTo(4.5 * k, 19.5 * k)
          ..close(),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(14.5 * k, 19.5 * k)
          ..lineTo(14.5 * k, 14.5 * k)
          ..lineTo(19.5 * k, 14.5 * k),
        paint,
      );
  }

  @override
  bool shouldRepaint(_NoteGlyphPainter old) => old.color != color;
}
