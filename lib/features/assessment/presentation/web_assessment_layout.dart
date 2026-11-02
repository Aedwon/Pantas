import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/web/web_components.dart';
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
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (chosenId != null) onNext();
        },
        for (final (i, key) in const [
          LogicalKeyboardKey.keyA,
          LogicalKeyboardKey.keyB,
          LogicalKeyboardKey.keyC,
          LogicalKeyboardKey.keyD,
        ].indexed)
          SingleActivator(key): () {
            if (i < question.choices.length) onPick(question.choices[i].id);
          },
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            Column(
              children: [
                WebTopBar(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Leave assessment',
                        onPressed: onLeave,
                        icon: Icon(
                          Icons.close,
                          size: 22,
                          color: t.colors.tertiaryLabel,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const WebKeyHint('Esc'),
                    ],
                  ),
                  title: Text(
                    'Assessment · $examName',
                    textAlign: TextAlign.center,
                    style: t.style(14, color: t.colors.tertiaryLabel),
                  ),
                  // The existing Report action remains available on web.
                  trailing: report ?? const SizedBox(width: 44),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(40, 56, 40, 140),
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
              left: 24,
              right: 24,
              bottom: 28,
              child: Center(
                child: WebBottomBar(
                  compact: true,
                  counter: '${index + 1} of $total',
                  action: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Answers show at the end.', style: t.sm),
                      ),
                      WebButton(
                        label: 'Next',
                        keyHint: 'Enter',
                        pill: true,
                        busy: saving,
                        onPressed: chosenId == null ? null : onNext,
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
}

/// AS_Leave uses the shared surface and natural-width actions.
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
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: SizedBox(
              width: 440,
              child: WebCard(
                radius: 22,
                padding: const EdgeInsets.all(26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Leave the assessment?', style: context.webTokens.h3),
                    const SizedBox(height: 18),
                    Text(
                      "Your answers so far won't be kept. "
                      'You can start again from Home.',
                      style: context.webTokens.sub.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onLeave,
                          style: TextButton.styleFrom(
                            foregroundColor: context.webTokens.colors.wrongText,
                            minimumSize: const Size(0, 44),
                            textStyle: context.webTokens
                                .style(16, weight: FontWeight.w600),
                          ),
                          child: const Text('Leave'),
                        ),
                        const SizedBox(width: 8),
                        WebButton(label: 'Keep Going', onPressed: onKeepGoing),
                      ],
                    ),
                  ],
                ),
              ),
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
    super.key,
  });

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
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (!saving) onAcknowledge();
        },
      },
      child: Focus(
        autofocus: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 56),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
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
                  const SizedBox(height: 4),
                  reveal(
                    sequence?.subtitle,
                    Text(
                      '$examName · $total questions',
                      textAlign: TextAlign.center,
                      style: t.style(
                        17,
                        height: 1.45,
                        color: t.colors.secondaryLabel,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  reveal(
                    sequence?.score,
                    // The mock results' score card: the half ring and score
                    // beside the subject breakdown.
                    WebCard(
                      key: const ValueKey('web-assessment-score'),
                      radius: 20,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 36, 24, 30),
                              child: Column(
                                children: [
                                  AssessmentScoreGauge(
                                    correct: correct,
                                    total: total,
                                    sequence: sequence,
                                    web: true,
                                  ),
                                  if (elapsed != null) ...[
                                    const SizedBox(height: 12),
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
                              padding:
                                  const EdgeInsets.fromLTRB(30, 14, 30, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 14),
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
                  const SizedBox(height: 36),
                  if (weakestTopic != null)
                    reveal(
                      sequence?.plan,
                      WebCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('YOUR PLAN STARTS WITH', style: t.eb),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(weakestTopic!, style: t.h3),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: t.colors.accentTint,
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          'Today',
                                          style: t.style(
                                            12,
                                            weight: FontWeight.w600,
                                            color: t.tintText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$weakestSubject · your weakest topic. '
                                    'Weakest first. It changes as you study.',
                                    style: t.sub,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 18),
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
