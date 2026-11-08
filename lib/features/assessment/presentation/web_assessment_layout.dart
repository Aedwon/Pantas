import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_question.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/assessment/presentation/assessment_results_motion.dart';

/// AS_Question and AS_Picked. The owning page still records every answer.
class WebAssessmentLayout extends StatelessWidget {
  const WebAssessmentLayout({
    required this.question,
    required this.subject,
    required this.examName,
    required this.index,
    required this.total,
    required this.onPick,
    required this.onNext,
    required this.onLeave,
    this.chosenId,
    this.passage,
    this.report,
    this.saving = false,
    super.key,
  });

  /// True while the last answer is still being saved for long enough to show.
  final bool saving;
  final Question question;
  final String subject;
  final String examName;
  final int index;
  final int total;
  final String? chosenId;
  final Passage? passage;
  final ValueChanged<String> onPick;
  final VoidCallback onNext;
  final VoidCallback onLeave;
  final Widget? report;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): onLeave,
        for (final (i, key) in const [
          LogicalKeyboardKey.keyA,
          LogicalKeyboardKey.keyB,
          LogicalKeyboardKey.keyC,
          LogicalKeyboardKey.keyD,
          // Some questions have five choices, and the letter must work for
          // each one the page shows.
          LogicalKeyboardKey.keyE,
          LogicalKeyboardKey.keyF,
        ].indexed)
          SingleActivator(key): () {
            if (i < question.choices.length) onPick(question.choices[i].id);
          },
      },
      child: KeyFocusKeeper(
        // Enter runs the control that holds focus (Report, Leave, a choice).
        // On the page, or on a choice that is already picked, it goes next.
        onKeyEvent: enterKeyHandler(
          () {
            if (chosenId != null) onNext();
          },
          keepsEnter: (focused) =>
              focused.findAncestorWidgetOfExactType<WebAnswerOption>()?.state ==
              WebOptionState.selected,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // The title is centered on the page, as the quiz's is.
                WebCenteredTopBar(
                  titleKey: const ValueKey('assessment-top-title'),
                  title: 'Assessment · $examName',
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WebTopBarButton(
                        tooltip: 'Leave assessment',
                        onPressed: onLeave,
                        icon: Icon(
                          Icons.close,
                          size: PantasSize.icon,
                          color: t.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: PantasSpace.s10),
                      const WebKeyHint('Esc'),
                    ],
                  ),
                  // The existing Report action remains available on web.
                  trailing: report ?? const SizedBox(width: PantasSpace.s44),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      PantasSpace.s40,
                      PantasSpace.s56,
                      PantasSpace.s40,
                      PantasLayout.reserveBar,
                    ),
                    child: WebQuizQuestion(
                      question: question,
                      subject: subject,
                      chosenId: chosenId,
                      passage: passage,
                      onPick: onPick,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: PantasSpace.s24,
              right: PantasSpace.s24,
              bottom: PantasLayout.barBottom,
              child: Center(
                child: WebBottomBar(
                  compact: true,
                  counter: '${index + 1} of $total',
                  action: WebButton(
                    label: index + 1 == total ? 'Finish' : 'Next',
                    keyHint: 'Enter',
                    pill: true,
                    busy: saving,
                    onPressed: chosenId == null ? null : onNext,
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

/// AS_Leave: the system Dialog. Keep Going is the main action and the safe
/// one: Esc and Enter both choose it, and Leave needs a click or Tab.
class WebAssessmentLeaveDialog extends StatelessWidget {
  const WebAssessmentLeaveDialog({
    required this.onKeepGoing,
    required this.onLeave,
    super.key,
  });
  final VoidCallback onKeepGoing;
  final VoidCallback onLeave;
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): onKeepGoing,
        },
        child: Focus(
          autofocus: true,
          // Enter is Keep Going, as in the quiz's Leave dialog, unless a
          // button in it holds focus, which then runs itself.
          onKeyEvent: enterKeyHandler(onKeepGoing),
          // Leaving loses the answers, so this is a destructive confirm: the
          // safe Keep Going first, the critical Leave last, an alertdialog.
          child: Semantics(
            role: SemanticsRole.alertDialog,
            child: CenteredDialog(
              title: 'Leave the assessment?',
              message: "Your answers so far won't be kept. "
                  'You can start again from Home.',
              primaryLabel: 'Leave',
              secondaryLabel: 'Keep Going',
              destructive: true,
              allowEscape: false,
              onConfirm: onLeave,
              onCancel: onKeepGoing,
            ),
          ),
        ),
      );
}

/// AS_Results takes measured results from the existing results provider.
class WebAssessmentResults extends StatelessWidget {
  const WebAssessmentResults({
    required this.examName,
    required this.correct,
    required this.total,
    required this.subjects,
    required this.onAcknowledge,
    this.elapsed,
    this.weakestTopic,
    this.weakestSubject,
    this.saving = false,
    this.failure,
    this.sequence,
    this.focusNode,
    super.key,
  });

  /// The node that holds the page's keys, when the page puts focus back
  /// by hand.
  final FocusNode? focusNode;

  /// The entrance timeline. Without one, everything shows at once.
  final AssessmentResultsSequence? sequence;
  final String examName;
  final int correct;
  final int total;
  final List<({String name, int correct, int total})> subjects;
  final Duration? elapsed;
  final String? weakestTopic;
  final String? weakestSubject;
  final bool saving;
  final Widget? failure;
  final VoidCallback onAcknowledge;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final sequence = this.sequence;
    Widget reveal(Animation<double>? animation, Widget child) =>
        animation == null
            ? child
            : ResultsReveal(animation: animation, child: child);
    final button = WebButton(
      label: 'Go to Today',
      large: true,
      keyHint: 'Enter',
      busy: saving,
      onPressed: saving ? null : onAcknowledge,
    );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.enter,
          includeRepeats: false,
        ): () {
          if (!saving) onAcknowledge();
        },
      },
      child: KeyFocusKeeper(
        focusNode: focusNode,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s40,
            vertical: PantasSpace.s56,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: PantasLayout.contentMax),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  reveal(
                    sequence?.title,
                    Text(
                      "Where you're starting",
                      textAlign: TextAlign.center,
                      style: t.h1,
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s4),
                  reveal(
                    sequence?.subtitle,
                    Text(
                      '$examName · $total questions',
                      textAlign: TextAlign.center,
                      style: PantasType.webLead
                          .copyWith(color: t.colors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s32),
                  reveal(
                    sequence?.score,
                    // The mock results' score card: the half ring and score
                    // beside the subject breakdown.
                    WebCard(
                      key: const ValueKey('web-assessment-score'),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                PantasSpace.s24,
                                PantasSpace.s32,
                                PantasSpace.s24,
                                PantasSpace.s28,
                              ),
                              child: Column(
                                children: [
                                  AssessmentScoreGauge(
                                    correct: correct,
                                    total: total,
                                    sequence: sequence,
                                    web: true,
                                  ),
                                  if (elapsed != null) ...[
                                    const SizedBox(height: PantasSpace.s12),
                                    Text(
                                      switch (elapsed!.inMinutes) {
                                        0 => 'in under a minute',
                                        1 => 'in 1 minute',
                                        final minutes => 'in $minutes minutes',
                                      },
                                      style: t.sub,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 13,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                PantasSpace.s28,
                                PantasSpace.s14,
                                PantasSpace.s28,
                                PantasSpace.s20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: PantasSpace.s14,
                                    ),
                                    child: Text(
                                      'BY SUBJECT · WEAKEST FIRST',
                                      style: t.eb,
                                    ),
                                  ),
                                  for (final (i, subject) in subjects.indexed)
                                    AssessmentSubjectRow(
                                      name: subject.name,
                                      correct: subject.correct,
                                      total: subject.total,
                                      divider: i < subjects.length - 1,
                                      bar: sequence?.bar(i),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s32),
                  if (weakestTopic != null)
                    reveal(
                      sequence?.plan,
                      WebCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PantasSpace.s24,
                          vertical: PantasSpace.s20,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('WEAKEST TOPIC', style: t.eb),
                                  const SizedBox(height: PantasSpace.s4),
                                  // No "Today" tag: the plan does not start
                                  // with this topic (it ranks by overall
                                  // accuracy), so the tag would claim it.
                                  Text(weakestTopic!, style: t.h3),
                                  Text(
                                    '$weakestSubject · '
                                    'lowest score in this check. '
                                    'It changes as you study.',
                                    style: t.sub,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: PantasSpace.s18),
                            button,
                          ],
                        ),
                      ),
                    )
                  else
                    Align(alignment: Alignment.centerRight, child: button),
                  if (failure != null) failure!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
