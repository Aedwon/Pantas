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
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
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
            padding: EdgeInsets.only(
              bottom: wide ? PantasSpace.s12 : PantasSpace.s10,
            ),
            child: _Dim(
              dimmed: _stateOf(c.id, c.isCorrect) == ChoiceRowState.dimmed,
              child: ChoiceRow(
                letter: c.label,
                text: c.text,
                state: _stateOf(c.id, c.isCorrect),
                markInBadge: true,
                onTap: revealed ? null : () => onPick(c.id),
              ),
            ),
          ),
      ],
    );
    final reveal = revealed
        ? AnswerReveal(
            correctLetter: correct.label,
            explanation: question.explanation,
            // The wide card draws its own edge (frame W04).
            ruled: !wide,
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
                  // ds-board: W04 groups 600 + 40 + 488
                  maxWidth: wide ? 1128 : double.infinity,
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ds-board: W04 question column 600, gap 40, aside 488 (440 + 24x2)
        Flexible(
          child: ConstrainedBox(
            // ds-board: W04 question column 600
            constraints: const BoxConstraints(maxWidth: 600),
            child: card,
          ),
        ),
        const SizedBox(width: PantasSpace.s40),
        Flexible(
          child: ConstrainedBox(
            // ds-board: W04 aside 488
            constraints: const BoxConstraints(maxWidth: 488),
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
                      // ds-board: W04 aside gap 18, row margin-top 4
                      const SizedBox(height: PantasSpace.s18 + PantasSpace.s4),
                      _FromLesson(title: lessonTitle, onTap: onFromLesson),
                    ],
                  ],
                ),
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
      // Frames W04 and W05: the compact pill, count, track, then the button.
      return Padding(
        padding: const EdgeInsets.only(bottom: PantasLayout.barBottom),
        child: Center(
          child: WebBottomBar(
            counter: counter,
            compact: true,
            // ds-board: W04 count padding 0 6 0 18
            counterPadding: const EdgeInsets.fromLTRB(
              PantasSpace.s18,
              PantasSpace.s0,
              PantasSpace.s6,
              PantasSpace.s0,
            ),
            state: switch (state) {
              FloatingBarState.neutral => WebBarState.neutral,
              FloatingBarState.right => WebBarState.right,
              FloatingBarState.wrong => WebBarState.wrong,
            },
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Track(outcomes: outcomes),
                // ds-board: W04 Next margin-left 4
                const SizedBox(width: PantasSpace.s4),
                WebButton(
                  label: revealed ? 'Next' : 'Check',
                  pill: true,
                  keyHint: 'Enter',
                  onPressed: revealed || pickedChoiceId != null
                      ? (revealed ? onNext : onCheck)
                      : null,
                ),
              ],
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
                // P04: the right arrow is dark ink on light and dim on dark.
                icon: Icon(
                  PantasIcons.next,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? context.colors.textSecondary
                      : context.colors.textPrimary,
                ),
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
          // ds-board: W04 track padding 0 14 0 8
          const SizedBox(width: PantasSpace.s8),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(width: PantasSpace.s6 / 2),
            Container(
              // ds-board: W04 segments 10x4, gap 3
              width: 10,
              // ds-board: W04 segments 10x4, gap 3
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
          const SizedBox(width: PantasSpace.s14),
        ],
      ),
    );
  }
}

/// "From the lesson" as the board's tinted row: a book, the two lines and a
/// chevron (frame W04).
class _FromLesson extends StatelessWidget {
  const _FromLesson({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: 'From the lesson, $title',
      excludeSemantics: true,
      child: PantasTapArea(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PantasRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            // ds-board: W04 lesson row padding 14 16
            vertical: PantasSpace.s14,
            horizontal: PantasSpace.s16,
          ),
          decoration: BoxDecoration(
            color: colors.bgPage,
            borderRadius: BorderRadius.circular(PantasRadius.lg),
          ),
          child: Row(
            children: [
              Icon(
                PantasIcons.bookOpen,
                size: PantasSize.icon,
                color: colors.accent,
              ),
              const SizedBox(width: PantasSpace.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From the lesson',
                      style: PantasType.phoneCaption
                          .copyWith(color: colors.textSecondary),
                    ),
                    Text(
                      title,
                      style: PantasType.phoneSubhead
                          .copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
              Icon(
                PantasIcons.next,
                size: PantasSpace.s16,
                color: colors.iconChevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unchosen choices fade to .4 once the answer is checked, over .3 s (the
/// boards' `.opt.dim`, `opacity .3s`). The shared rows only change color.
class _Dim extends StatelessWidget {
  const _Dim({required this.dimmed, required this.child});

  final bool dimmed;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        key: const ValueKey('first-run-choice-dim'),
        opacity: dimmed ? .4 : 1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            // ds-board: .opt.dim opacity .3s
            : const Duration(milliseconds: 300),
        child: child,
      );
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
