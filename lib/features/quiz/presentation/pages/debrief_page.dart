import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_checkbox.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/spaced_repetition_note.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_providers.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/debrief/miss_cause.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/debrief/session_debrief.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/debrief_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DebriefPage extends ConsumerWidget {
  const DebriefPage({
    required this.attemptId,
    this.proIsActive,
    this.sessionOverride,
    this.attemptOverride,
    super.key,
  });

  final String attemptId;
  final bool? proIsActive;
  final QuizSession? sessionOverride;
  final Attempt? attemptOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement =
        ref.watch(entitlementProvider).valueOrNull ?? const Entitlement.free();
    final effectiveProIsActive = proIsActive ?? entitlement.proIsActive;

    final debriefAsync = ref.watch(
      sessionDebriefProvider(
        (
          attemptId: attemptId,
          proIsActive: effectiveProIsActive,
          sessionOverride: sessionOverride,
          attemptOverride: attemptOverride,
        ),
      ),
    );

    return Scaffold(
      // No app bar. It carried the close control, and with that gone it was
      // an empty 56px band above a screen that opens with its own heading.
      // The quiz page's bar sits above this when a session completes, and
      // `Done` at the foot is the way out.
      body: debriefAsync.when(
        data: (debrief) => _DebriefBody(
          debrief: debrief,
          attemptId: attemptId,
          proIsActive: effectiveProIsActive,
        ),
        loading: () => const Center(child: FaintBars()),
        error: (err, _) => Center(child: Text('Error loading debrief: $err')),
      ),
    );
  }

  static void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quiz');
    }
  }
}

class _DebriefBody extends ConsumerStatefulWidget {
  const _DebriefBody({
    required this.debrief,
    required this.attemptId,
    required this.proIsActive,
  });

  final SessionDebrief debrief;
  final String attemptId;
  final bool proIsActive;

  @override
  ConsumerState<_DebriefBody> createState() => _DebriefBodyState();
}

class _DebriefBodyState extends ConsumerState<_DebriefBody> {
  bool _isArmed = false;
  final Map<QuestionId, MistakeTag?> _tags = {};

  @override
  void initState() {
    super.initState();
    for (final miss in widget.debrief.misses) {
      if (miss.tag != null) {
        _tags[miss.questionId] = miss.tag;
      }
    }
  }

  void _onTagSelected(QuestionId questionId, MistakeTag tag) {
    final current = _tags[questionId];
    final next = current == tag ? null : tag;
    setState(() {
      _tags[questionId] = next;
    });
    ref.read(attemptsRepositoryProvider).tagItem(
          attemptId: widget.attemptId,
          questionId: questionId,
          tag: next,
        );
  }

  String _noteCounter(int noted, int total) {
    if (noted == total) {
      return total == 3
          ? 'All three noted. Progress can use them now.'
          : 'All $total noted. Progress can use them now.';
    }
    return '$noted of $total noted. Leave any of them blank, it costs nothing.';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final debrief = widget.debrief;

    final notedCount = _tags.values.where((t) => t != null).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(debrief.headline, style: styles.headlineMedium),
              const SizedBox(height: 16),
              StatsBand(
                figures: [
                  StatFigure(
                    value: '${debrief.correct}',
                    label: 'correct',
                  ),
                  StatFigure(
                    value: '${debrief.minutes} m',
                    label: 'taken',
                  ),
                ],
                centred: true,
                compact: true,
              ),
              const SizedBox(height: 12),
              Text(
                debrief.sourceLine,
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
              if (!debrief.isClean) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'To come back to',
                  trailing: Text(
                    '${debrief.misses.length}',
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ),
                const SizedBox(height: 8),
                for (final miss in debrief.misses)
                  _MissRow(
                    miss: miss,
                    proIsActive: widget.proIsActive,
                    isArmed: _isArmed,
                    selectedTag: _tags[miss.questionId],
                    onTagSelected: (tag) =>
                        _onTagSelected(miss.questionId, tag),
                  ),
                if (debrief.returnPromise.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    debrief.returnPromise,
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ],
                if (widget.proIsActive) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colors.rule,
                        ),
                      ),
                    ),
                    child: !_isArmed
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'These are the notes Pantas could write on '
                                'its own. '
                                "You're the only one who knows the rest.",
                                style: styles.bodyMedium
                                    .copyWith(color: colors.inkMuted),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => setState(() => _isArmed = true),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusButton,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  constraints: const BoxConstraints(
                                    minHeight: AppDimensions.minTapTarget,
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colors.rule,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusButton,
                                    ),
                                  ),
                                  child: Text(
                                    'Finish the notes',
                                    style: styles.labelLarge
                                        .copyWith(color: colors.ink),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _noteCounter(notedCount, debrief.misses.length),
                            style: styles.bodySmall
                                .copyWith(color: colors.inkMuted),
                          ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colors.rule,
                      ),
                    ),
                  ),
                  // A secondary action rather than a navigation row: it
                  // does something, and board belongs to `Done`, which is
                  // this screen's one primary action.
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: BoardButton(
                      label: 'Go through all ${debrief.total}',
                      secondary: true,
                      onPressed: () =>
                          context.push('/review?attemptId=${widget.attemptId}'),
                    ),
                  ),
                ),
              ],
              // Here rather than in How you work, which is about the
              // student's own habits. This explains what the app just did
              // with their answers, at the moment it has done it.
              const SizedBox(height: 20),
              const SpacedRepetitionNote(),
              const SizedBox(height: 16),
              BoardButton(
                label: 'Done',
                onPressed: () => DebriefPage._leave(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissRow extends StatelessWidget {
  const _MissRow({
    required this.miss,
    required this.proIsActive,
    required this.isArmed,
    required this.onTagSelected,
    this.selectedTag,
  });

  final DebriefMiss miss;
  final bool proIsActive;
  final bool isArmed;
  final MistakeTag? selectedTag;
  final void Function(MistakeTag tag) onTagSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '✕',
              style: styles.bodyMedium.copyWith(color: colors.rust),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PortableTextRenderer(
                  text: miss.label,
                  maxLines: miss.labelIsStem ? 2 : null,
                ),
                const SizedBox(height: 2),
                Text(
                  '${miss.topicName} · you picked ${miss.pickedLabel}, '
                  'answer was ${miss.answerLabel}',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
                if (proIsActive && miss.cause != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _causeLine(miss.cause!),
                    style: styles.bodySmall.copyWith(
                      color: colors.inkMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (isArmed) ...[
                  const SizedBox(height: 8),
                  _TagOptionRow(
                    label: 'I misread it',
                    isSelected: selectedTag == MistakeTag.misread,
                    onTap: () => onTagSelected(MistakeTag.misread),
                  ),
                  _TagOptionRow(
                    label: 'I knew this, I just slipped',
                    isSelected: selectedTag == MistakeTag.slipped,
                    onTap: () => onTagSelected(MistakeTag.slipped),
                  ),
                  _TagOptionRow(
                    label: "I didn't know it",
                    isSelected: selectedTag == MistakeTag.unknown,
                    onTap: () => onTagSelected(MistakeTag.unknown),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _causeLine(MissCause cause) {
    return switch (cause) {
      RushedCause(
        :final responseSeconds,
        :final usualSeconds,
        :final topicName
      ) =>
        'You answered in $responseSeconds seconds. '
            'You usually take $usualSeconds on $topicName.',
      SlippedCause(:final lastCorrectAt) =>
        'You had this right on ${_formatDay(lastCorrectAt)}.',
      NewCause() => "It's the first time you've seen this one.",
    };
  }

  String _formatDay(DateTime dt) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${dt.day} ${months[dt.month]}';
  }
}

class _TagOptionRow extends StatelessWidget {
  const _TagOptionRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            InkCheckbox.binary(
              isSelected: isSelected,
              onTap: onTap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: styles.bodyMedium.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
