import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/ui/components/half_ring_gauge.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

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
    this.source,
    this.proPaused = false,
    this.onNext,
    this.nextBusy = false,
    this.failure,
    super.key,
  });
  final QuizSession session;
  final Attempt attempt;
  final Map<String, String> subjectNames;
  final bool pro;
  final bool proPaused;
  final String? source;
  final VoidCallback onDone;
  final ValueChanged<int> onQuestion;
  final VoidCallback onAll;
  final VoidCallback onMistakes;
  final VoidCallback onNotes;
  final VoidCallback? onNext;
  final bool nextBusy;
  final Widget? failure;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
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
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): onDone,
        const SingleActivator(LogicalKeyboardKey.enter):
            next ? onNext! : onDone,
      },
      child: Focus(
        autofocus: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 64),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          misses.isEmpty ? 'Perfect!' : 'Session finished.',
                          style: t.h1,
                        ),
                      ),
                      WebButton(
                        label: 'Done',
                        onPressed: nextBusy ? null : onDone,
                        variant: next
                            ? WebButtonVariant.tertiary
                            : WebButtonVariant.primary,
                      ),
                    ],
                  ),
                  if (line != null) ...[
                    const SizedBox(height: 8),
                    WebText(line, kind: WebTextKind.lead),
                  ],
                  const SizedBox(height: 28),
                  WebCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 320,
                          child: HalfRingGauge.quizCount(
                            web: true,
                            correct: correct,
                            total: total,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < total; i++)
                              SizedBox.square(
                                dimension: 30,
                                child: TextButton(
                                  onPressed: () => onQuestion(i),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    backgroundColor: attempt.items[i].isCorrect
                                        ? t.colors.accentTint
                                        : t.colors.wrongTint,
                                    foregroundColor: attempt.items[i].isCorrect
                                        ? t.colors.accent
                                        : t.colors.wrongText,
                                    shape: const CircleBorder(),
                                    textStyle: t.style(
                                      13,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  child: Text('${i + 1}'),
                                ),
                              ),
                          ],
                        ),
                        if (elapsed != null && !elapsed.isNegative) ...[
                          const SizedBox(height: 12),
                          Text(
                            elapsed.inMinutes == 0 && elapsed > Duration.zero
                                ? 'in under 1 minute'
                                : 'in ${elapsed.inMinutes} '
                                    '$unit',
                            style: t.sm,
                          ),
                        ],
                        const SizedBox(height: 20),
                        WebTextLink(
                          label: 'See all $total questions',
                          onPressed: onAll,
                        ),
                        if (next) ...[
                          const SizedBox(height: 20),
                          WebButton(
                            label: 'Start Session ${batch.ordinal + 1}',
                            large: true,
                            keyHint: 'Enter',
                            busy: nextBusy,
                            onPressed: onNext,
                          ),
                        ],
                        if (failure != null) failure!,
                      ],
                    ),
                  ),
                  if (misses.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    WebText(
                      'Your mistakes · ${misses.length}',
                      kind: WebTextKind.eyebrow,
                    ),
                    WebCard(
                      child: Column(
                        children: [
                          for (final i in misses.take(3))
                            WebRow(
                              title: session.questions[i].shortLabel ??
                                  session.questions[i].stem,
                              subtitle:
                                  subjectNames[session.questions[i].topicId],
                              leading: Icon(
                                Icons.close,
                                color: t.colors.wrongText,
                                size: 22,
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                size: 16,
                              ),
                              onPressed: () => onQuestion(i),
                            ),
                          if (misses.length > 3)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: WebTextLink(
                                  label: 'See all ${misses.length} mistakes',
                                  onPressed: onMistakes,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (pro || proPaused) ...[
                      const SizedBox(height: 22),
                      WebCard(
                        padding: const EdgeInsets.all(20),
                        child: proPaused
                            ? const ProPausedLine()
                            : Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Tell Pantas why you got each one wrong. '
                                      'The better your notes, the more every '
                                      'review helps.',
                                      style: t.sub,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  WebButton(
                                    label: 'Finish the Notes',
                                    variant: WebButtonVariant.secondary,
                                    onPressed: onNotes,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
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
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
            WebTopBar(
              leading: Row(
                children: [
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.chevron_left, size: 20),
                    label: const Text('Session'),
                  ),
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
                        const SizedBox(height: 8),
                        Text(
                          '$correct of $total correct',
                          style: t.sub,
                        ),
                        const SizedBox(height: 26),
                        WebCard(
                          child: Column(
                            children: [
                              for (final (position, index) in indices.indexed)
                                WebRow(
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
                                  trailing:
                                      const Icon(Icons.chevron_right, size: 16),
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
