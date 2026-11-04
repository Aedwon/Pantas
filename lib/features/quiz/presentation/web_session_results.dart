import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/session_entry_motion.dart';

export 'package:pantas/core/ui/web/web_debrief_loading.dart';

class WebSessionResults extends StatelessWidget {
  const WebSessionResults({
    required this.session,
    required this.attempt,
    required this.subjectNames,
    required this.pro,
    required this.onDone,
    required this.onQuestion,
    required this.onAll,
    required this.onMistakes,
    required this.onNotes,
    this.onMistake,
    this.source,
    this.debriefCards,
    this.proPaused = false,
    this.onNext,
    this.nextBusy = false,
    this.failure,
    this.entry,
    super.key,
  });
  final QuizSession session;
  final Attempt attempt;
  final Map<String, String> subjectNames;
  final bool pro;
  final bool proPaused;
  final String? source;
  final Widget? debriefCards;
  final VoidCallback onDone;
  final ValueChanged<int> onQuestion;

  /// A mistake row opens that mistake, among the mistakes only. Without it
  /// the row opens the question like any other.
  final ValueChanged<int>? onMistake;
  final VoidCallback onAll;
  final VoidCallback onMistakes;
  final VoidCallback onNotes;
  final VoidCallback? onNext;
  final bool nextBusy;
  final Widget? failure;

  /// The phone's staggered entrance. Without it the page appears at once.
  final SessionEntryMotion? entry;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    Widget appear(Widget child, int start, int duration, {double rise = 0}) =>
        entry?.appear(child, start, duration, rise: rise) ?? child;
    final (correct, total) = attempt.score;
    final misses = [
      for (var i = 0; i < total; i++)
        if (!attempt.items[i].isCorrect) i,
    ];
    final batch = session.reviewBatch;
    final line = batch == null
        ? source
        : 'Reviews · Session ${batch.ordinal} of ${batch.total}';
    final elapsed = attempt.completedAt?.difference(attempt.startedAt);
    final unit = elapsed?.inMinutes == 1 ? 'minute' : 'minutes';
    final next = onNext != null && batch != null && batch.ordinal < batch.total;
    final mistakeRowTitle = t.style(16, height: 1.3);
    // QS_EndLow: the mistakes link is teal and bold, the all-questions link
    // plain. The phone's link is teal.
    final mistakesLinkTitle = t.style(
      16,
      height: 1.3,
      weight: FontWeight.w600,
      color: t.colors.accent,
    );
    Widget circle(int i) => SizedBox.square(
          dimension: 30,
          child: TextButton(
            onPressed: () => onQuestion(i),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: attempt.items[i].isCorrect
                  ? t.colors.accentTint
                  : t.colors.wrongTint,
              foregroundColor: attempt.items[i].isCorrect
                  ? t.colors.accent
                  : t.colors.wrongText,
              shape: const CircleBorder(),
              textStyle: t.style(13, weight: FontWeight.w600),
            ),
            child: Text('${i + 1}'),
          ),
        );
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onDone},
      child: KeyFocusKeeper(
        // The page's own node only holds its keys: Tab skips it, so the
        // first stop is the Close button.
        skipTraversal: true,
        // Enter runs the control that holds focus; with none, it goes on.
        onKeyEvent: enterKeyHandler(next ? onNext! : onDone),
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: _CloseButton(onPressed: onDone),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(40, 24, 40, 64),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        appear(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                misses.isEmpty
                                    ? 'Perfect!'
                                    : 'Session finished.',
                                style: t.h1,
                                textAlign: TextAlign.center,
                              ),
                              if (line != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  line,
                                  textAlign: TextAlign.center,
                                  style: t.style(
                                    17,
                                    height: 1.45,
                                    color: t.colors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          100,
                          380,
                          rise: 6,
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: SizedBox(
                            width: 320,
                            height: 170,
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: double.infinity,
                              child: HalfRingGauge.quizCount(
                                web: true,
                                correct: correct,
                                total: total,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < total; i++)
                              entry?.pop(i, circle(i)) ?? circle(i),
                          ],
                        ),
                        if (elapsed != null && !elapsed.isNegative) ...[
                          const SizedBox(height: 20),
                          appear(
                            Text(
                              elapsed.inMinutes == 0 && elapsed > Duration.zero
                                  ? 'in under 1 minute'
                                  : 'in ${elapsed.inMinutes} '
                                      '$unit',
                              style: t.sub,
                              textAlign: TextAlign.center,
                            ),
                            1600,
                            300,
                          ),
                        ],
                        const SizedBox(height: 28),
                        // The phone's button bar fades in last. Here it sits
                        // above the lists, so it follows the duration line.
                        appear(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 196,
                                child: WebButton(
                                  label: 'Done',
                                  large: true,
                                  expand: true,
                                  onPressed: nextBusy ? null : onDone,
                                  variant: next
                                      ? WebButtonVariant.white
                                      : WebButtonVariant.primary,
                                ),
                              ),
                              if (next) ...[
                                const SizedBox(width: 12),
                                WebButton(
                                  label: 'Start Session ${batch.ordinal + 1}',
                                  large: true,
                                  keyHint: 'Enter',
                                  busy: nextBusy,
                                  onPressed: onNext,
                                ),
                              ],
                            ],
                          ),
                          1700,
                          300,
                        ),
                        if (failure != null) failure!,
                        if (debriefCards != null) ...[
                          const SizedBox(height: 32),
                          debriefCards!,
                        ],
                        const SizedBox(height: 32),
                        if (misses.isNotEmpty) ...[
                          appear(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                WebText(
                                  'Your mistakes · ${misses.length}',
                                  kind: WebTextKind.eyebrow,
                                ),
                                WebCard(
                                  child: Column(
                                    children: [
                                      for (final (position, i)
                                          in misses.take(3).indexed)
                                        appear(
                                          WebRow(
                                            mathTitle: session
                                                    .questions[i].shortLabel ==
                                                null,
                                            title: session
                                                    .questions[i].shortLabel ??
                                                session.questions[i].stem,
                                            subtitle: subjectNames[
                                                session.questions[i].topicId],
                                            boardMetrics: true,
                                            leading: _MissMark(color: t),
                                            chevron: WebRowChevron.always,
                                            onPressed: () =>
                                                (onMistake ?? onQuestion)(i),
                                          ),
                                          1700 + position * 90,
                                          380,
                                          rise: 6,
                                        ),
                                      if (misses.length > 3)
                                        WebRow(
                                          title: 'See all '
                                              '${misses.length} mistakes',
                                          titleStyle: mistakesLinkTitle,
                                          boardMetrics: true,
                                          chevron: WebRowChevron.always,
                                          onPressed: onMistakes,
                                        ),
                                      appear(
                                        WebRow(
                                          title: 'See all $total questions',
                                          titleStyle: mistakeRowTitle,
                                          boardMetrics: true,
                                          divider: false,
                                          chevron: WebRowChevron.always,
                                          onPressed: onAll,
                                        ),
                                        2000,
                                        380,
                                        rise: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            1620,
                            380,
                            rise: 8,
                          ),
                          if (pro || proPaused) ...[
                            const SizedBox(height: 22),
                            appear(
                              WebCard(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 18, 18, 18),
                                child: proPaused
                                    ? const ProPausedLine()
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Tell Pantas why you got each '
                                              'one wrong. The better your '
                                              'notes, the more every review '
                                              'helps.',
                                              style: t.style(15, height: 1.5),
                                            ),
                                          ),
                                          const SizedBox(width: 18),
                                          _NotesButton(
                                            label: 'Finish the Notes',
                                            onPressed: onNotes,
                                          ),
                                        ],
                                      ),
                              ),
                              2260,
                              300,
                            ),
                          ],
                        ] else
                          appear(
                            WebCard(
                              radius: 16,
                              child: WebRow(
                                title: 'See all $total questions',
                                boardMetrics: true,
                                divider: false,
                                horizontalPadding: 18,
                                chevron: WebRowChevron.always,
                                onPressed: onAll,
                              ),
                            ),
                            2000,
                            380,
                            rise: 10,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Board `.ib`: a 44 px rounded icon button in the top bar.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Semantics(
      button: true,
      label: 'Close',
      excludeSemantics: true,
      child: SizedBox.square(
        key: const ValueKey('results-close'),
        dimension: 44,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            // Board `.ib` on the end screens draws its X in #8E8E93, 22 px.
            foregroundColor:
                t.dark ? t.colors.tertiaryLabel : const Color(0xFF8E8E93),
            overlayColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.close, size: 22),
        ),
      ),
    );
  }
}

class _MissMark extends StatelessWidget {
  const _MissMark({required this.color});
  final WebTokens color;
  @override
  Widget build(BuildContext context) => Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.colors.wrongTint,
        ),
        child: Icon(Icons.close, size: 14, color: color.colors.wrongText),
      );
}

/// Board `.btn2`: 40 px tinted button, radius 11, 15 px label.
class _NotesButton extends StatelessWidget {
  const _NotesButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: t.colors.accentTint,
        foregroundColor: t.tintText,
        overlayColor: Colors.transparent,
        textStyle: t.style(15, weight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(label),
    );
  }
}

class WebQuizQuestionList extends StatelessWidget {
  const WebQuizQuestionList({
    required this.session,
    required this.attempt,
    required this.subjectNames,
    required this.onBack,
    required this.onQuestion,
    this.mistakesOnly = false,
    super.key,
  });
  final QuizSession session;
  final Attempt attempt;
  final Map<String, String> subjectNames;
  final VoidCallback onBack;
  final ValueChanged<int> onQuestion;
  final bool mistakesOnly;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final (correct, total) = attempt.score;
    final indices = [
      for (var i = 0; i < total; i++)
        if (!mistakesOnly || !attempt.items[i].isCorrect) i,
    ];
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): onBack},
      child: KeyFocusKeeper(
        skipTraversal: true,
        child: Column(
          children: [
            WebTopBar(
              leading: Row(
                children: [
                  WebBackLink(
                    label: 'Session',
                    onPressed: onBack,
                    nudge: false,
                  ),
                  // No gap: the link's own right padding is the room.
                  const WebKeyHint('Esc'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(40, 24, 40, 64),
                child: Center(
                  child: SizedBox(
                    width: 720,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WebText(
                          mistakesOnly ? 'Your mistakes' : 'All questions',
                          kind: WebTextKind.h1,
                        ),
                        const SizedBox(height: 4),
                        WebText(
                          '$correct of $total correct',
                          kind: WebTextKind.lead,
                        ),
                        const SizedBox(height: 20),
                        WebCard(
                          child: Column(
                            children: [
                              for (final (position, index) in indices.indexed)
                                WebRow(
                                  boardMetrics: true,
                                  chevron: WebRowChevron.always,
                                  mathTitle:
                                      session.questions[index].shortLabel ==
                                          null,
                                  title: session.questions[index].shortLabel ??
                                      session.questions[index].stem,
                                  subtitle: subjectNames[
                                      session.questions[index].topicId],
                                  leading: CircleAvatar(
                                    radius: 15,
                                    backgroundColor:
                                        attempt.items[index].isCorrect
                                            ? t.colors.accentTint
                                            : t.colors.wrongTint,
                                    child: Text(
                                      '${index + 1}',
                                      style: t.style(
                                        13,
                                        weight: FontWeight.w600,
                                        color: attempt.items[index].isCorrect
                                            ? t.colors.accent
                                            : t.colors.wrongText,
                                      ),
                                    ),
                                  ),
                                  divider: position < indices.length - 1,
                                  onPressed: () => onQuestion(index),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
