import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/new_design/answer_reveal.dart';
import 'package:pantas/core/ui/components/new_design/question_card.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_tap_area.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/first_run/presentation/widgets/first_run_header.dart';

/// One question of the run (frames P04, P05, W04, W05). It is controlled:
/// the page owns the pick, whether the answer is checked and where the
/// arrows go. No flag, report, leave dialog or wrong-choice notes.
class FirstRunQuestion extends StatelessWidget {
  const FirstRunQuestion({
    required this.question,
    required this.index,
    required this.subject,
    required this.eyebrow,
    required this.lessonTitle,
    required this.pickedChoiceId,
    required this.revealed,
    required this.outcomes,
    required this.onPick,
    required this.onCheck,
    required this.onPrevious,
    required this.onNext,
    required this.onSkip,
    required this.onFromLesson,
    super.key,
  });

  final Question question;

  /// 0 to 2.
  final int index;

  /// "Mathematics", the phone eyebrow.
  final String subject;

  /// "Mathematics · Arithmetic", the wide eyebrow.
  final String eyebrow;
  final String lessonTitle;
  final String? pickedChoiceId;

  /// The answer is checked: the choices and the explanation show.
  final bool revealed;

  /// Per question: true right, false wrong, null not answered yet.
  final List<bool?> outcomes;
  final ValueChanged<String> onPick;
  final VoidCallback onCheck;

  /// Null on the first question.
  final VoidCallback? onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onFromLesson;

  bool get _right =>
      revealed &&
      pickedChoiceId != null &&
      question.choices.any((c) => c.id == pickedChoiceId && c.isCorrect);

  ChoiceRowState _stateOf(String id, bool correct) {
    if (!revealed) {
      return id == pickedChoiceId
          ? ChoiceRowState.picked
          : ChoiceRowState.plain;
    }
    if (correct) return ChoiceRowState.right;
    if (id == pickedChoiceId) return ChoiceRowState.wrong;
    return ChoiceRowState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final correct = question.choices.firstWhere((c) => c.isCorrect);
    final card = QuestionCard(
      subject: wide ? eyebrow : subject,
      stem: question.stem,
      choices: [
        for (final c in question.choices)
          Padding(
            padding: const EdgeInsets.only(bottom: PantasSpace.s10),
            child: ChoiceRow(
              letter: c.label,
              text: c.text,
              state: _stateOf(c.id, c.isCorrect),
              onTap: revealed ? null : () => onPick(c.id),
            ),
          ),
      ],
    );
    final reveal = revealed
        ? AnswerReveal(
            correctLetter: correct.label,
            explanation: question.explanation,
          )
        : null;
    final body = wide
        ? _wideBody(context, card, reveal)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              card,
              if (reveal != null) ...[
                const SizedBox(height: PantasSpace.s8),
                reveal,
              ],
            ],
          );
    return Column(
      children: [
        FirstRunHeader(
          onSkip: onSkip,
          // ds-board: P04 header row 44, W04 64
          height: wide ? null : 44,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              wide ? PantasSpace.s24 : PantasLayout.gutterPhone,
              PantasSpace.s8,
              wide ? PantasSpace.s24 : PantasLayout.gutterPhone,
              PantasSpace.s24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: wide ? PantasLayout.contentMax : double.infinity,
                ),
                child: body,
              ),
            ),
          ),
        ),
        _bar(context),
      ],
    );
  }

  Widget _wideBody(BuildContext context, Widget card, Widget? reveal) {
    if (reveal == null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PantasLayout.qcol),
        child: card,
      );
    }
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: card),
        const SizedBox(width: PantasSpace.s24),
        SizedBox(
          // ds-board: W04 aside card width
          width: PantasLayout.colListMax,
          child: _Slide(
            child: Container(
              padding: const EdgeInsets.all(PantasSpace.s24),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                // ds-board: W04 aside radius 20
                borderRadius:
                    BorderRadius.circular(PantasRadius.xl + PantasSpace.s2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  reveal,
                  if (_right) ...[
                    const SizedBox(height: PantasSpace.s16),
                    _FromLesson(title: lessonTitle, onTap: onFromLesson),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bar(BuildContext context) {
    final wide = context.wideWeb;
    final state = !revealed
        ? FloatingBarState.neutral
        : _right
            ? FloatingBarState.right
            : FloatingBarState.wrong;
    final counter = '${index + 1} of 3';
    const inset = PantasLayout.gutterPhone;
    if (wide) {
      return Padding(
        padding: const EdgeInsets.only(bottom: PantasLayout.barBottom),
        child: Center(
          child: WebBottomBar(
            counter: counter,
            center: _Track(outcomes: outcomes),
            state: switch (state) {
              FloatingBarState.neutral => WebBarState.neutral,
              FloatingBarState.right => WebBarState.right,
              FloatingBarState.wrong => WebBarState.wrong,
            },
            action: WebButton(
              label: revealed ? 'Next' : 'Check',
              keyHint: 'Enter',
              onPressed: revealed || pickedChoiceId != null
                  ? (revealed ? onNext : onCheck)
                  : null,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
        inset,
        PantasSpace.s0,
        inset,
        // ds-board: P04 bar bottom 26
        PantasSpace.s24 +
            PantasSpace.s2 +
            MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: FloatingBar(
        state: state,
        counter: counter,
        left: PantasIconButton(
          tooltip: 'Previous question',
          glyph: PantasIcons.back,
          accent: true,
          onPressed: onPrevious,
        ),
        right: revealed
            ? PantasIconButton(
                tooltip: 'Next question',
                glyph: PantasIcons.next,
                accent: true,
                onPressed: onNext,
              )
            : PantasButton(
                label: 'Check',
                variant: PantasButtonVariant.tertiary,
                onPressed: pickedChoiceId == null ? null : onCheck,
              ),
      ),
    );
  }
}

/// Three segments: teal right, red wrong, gray not yet (frame W04).
class _Track extends StatelessWidget {
  const _Track({required this.outcomes});

  final List<bool?> outcomes;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: PantasSpace.s6 / 2),
            Container(
              // ds-board: W04 segments 10x4, gap 3
              width: 10,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PantasRadius.full),
                color: switch (outcomes[i]) {
                  true => colors.accent,
                  false => colors.danger,
                  null => colors.dividerStrong,
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FromLesson extends StatelessWidget {
  const _FromLesson({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PantasTapArea(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PantasRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PantasSpace.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From the lesson',
              style: PantasType.phoneFootnote
                  .copyWith(color: colors.textSecondary),
            ),
            Text(
              title,
              style: PantasType.phoneBody.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wide explanation card slides in from 28 px over 0.5 s (frame W04).
class _Slide extends StatelessWidget {
  const _Slide({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      // ds-board: W04 `slidein .5s cubic-bezier(.2,.9,.3,1)`
      duration: const Duration(milliseconds: 500),
      curve: PantasCurves.enter,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(28 * (1 - t), 0),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
