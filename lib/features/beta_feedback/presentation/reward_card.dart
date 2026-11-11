import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/theme_names.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';

/// The whole turn-on motion runs on one clock of this length (the crown's
/// swing is the last thing to finish: 550 ms in, then 1.3 s).
const _clockMs = 1900.0;

/// "You earned 1 year of Pro", the month strip and the Activate button.
///
/// Turning it on rolls the title, swings the crown, fills the twelve months
/// with gold, collapses the button and writes the "Turned on" line. A reward
/// that is already on shows its final state with no motion.
class RewardCard extends ConsumerStatefulWidget {
  const RewardCard({required this.reward, required this.now, super.key});
  final BetaReward reward;
  final DateTime now;

  @override
  ConsumerState<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends ConsumerState<RewardCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );
  BetaRewardActivation? _result;
  bool _working = false;

  bool get _on => _result != null || widget.reward.activated;

  @override
  void initState() {
    super.initState();
    if (_on) _clock.value = 1;
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    if (_working || _on) return;
    setState(() => _working = true);
    final BetaRewardActivation result;
    try {
      result = await ref.read(betaFeedbackApiProvider).activate();
    } on Exception {
      if (!mounted) return;
      setState(() => _working = false);
      showPantasToast(context, 'Could not turn it on. Try again.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _result = result;
      _working = false;
    });
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock.value = 1;
    } else {
      unawaited(_clock.forward(from: 0));
    }
    ref.invalidate(betaRewardProvider);
  }

  /// Progress, 0 to 1, of a piece that starts [start] ms in and takes [ms].
  double _seg(double start, double ms, Curve curve) {
    final elapsed = _clock.value * _clockMs;
    return curve.transform(((elapsed - start) / ms).clamp(0.0, 1.0));
  }

  /// The crown's lean in radians: 0, 11, -8, 5, -2.5, 0 degrees at 0, 18, 38,
  /// 56, 74 and 100 percent, easing between each pair.
  double _swing() {
    const stops = [0.0, .18, .38, .56, .74, 1.0];
    const degrees = [0.0, 11.0, -8.0, 5.0, -2.5, 0.0];
    final t = ((_clock.value * _clockMs - 550) / 1300).clamp(0.0, 1.0);
    for (var i = 0; i < stops.length - 1; i++) {
      if (t <= stops[i + 1]) {
        final u = PantasBoardCurves.shake
            .transform((t - stops[i]) / (stops[i + 1] - stops[i]));
        return (degrees[i] + (degrees[i + 1] - degrees[i]) * u) * math.pi / 180;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    final reward = widget.reward;
    final on = _on;
    final startsAt =
        _result?.startsAt ?? reward.rewardStartsAt ?? reward.activatedAt;
    final endsAt = _result?.endsAt ?? reward.rewardEndsAt;
    final activatedAt = reward.activatedAt ?? _result?.startsAt ?? startsAt;
    final firstMonth = phTime(on ? (startsAt ?? widget.now) : widget.now).month;
    final deadline = monthDayYear(
      reward.activationDeadline.subtract(const Duration(milliseconds: 1)),
    );
    final endText = endsAt == null ? '' : monthDayYear(endsAt);
    final turnedOn = activatedAt == null ? '' : monthDayYear(activatedAt);

    final titleStyle = (wide ? PantasType.webH3Lg : PantasType.phoneTitle2)
        .copyWith(color: c.textPrimary);
    final subline = on
        ? 'Thank you for testing Pantas.'
        : 'Thank you for testing Pantas. Turn it on whenever you are ready.';
    final footnote = on
        ? 'After $endText, your account goes back to Free.'
        : wide
            ? 'Activate by $deadline. If you have paid Pro, the year starts '
                'when it ends.'
            : 'Activate by $deadline. The year covers every exam. If you have '
                'paid Pro, the year starts when it ends.';

    return AnimatedBuilder(
      animation: _clock,
      builder: (context, _) {
        final crown = Transform.rotate(
          key: const ValueKey('crown'),
          angle: on ? _swing() : 0,
          alignment: const Alignment(0, .7),
          child: FbGlyph(
            FbGlyphKind.crown,
            size: wide ? 26 : 24,
            color: c.pro,
          ),
        );
        final pOld = on ? _seg(0, 360, PantasCurves.draw) : 0.0;
        final pNew = on ? _seg(80, 360, PantasCurves.enter) : 0.0;
        final pNewFade = on ? _seg(80, 360, PantasCurves.fade) : 0.0;
        final title = SizedBox(
          height: PantasSpace.s28,
          child: ClipRect(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    key: const ValueKey('title-earned'),
                    opacity: 1 - (on ? _seg(0, 360, PantasCurves.fade) : 0.0),
                    child: Transform.translate(
                      offset: Offset(0, -PantasSpace.s28 * pOld),
                      child: Text(
                        'You earned 1 year of Pro',
                        maxLines: 1,
                        style: titleStyle,
                      ),
                    ),
                  ),
                ),
                if (on)
                  Positioned.fill(
                    child: Opacity(
                      key: const ValueKey('title-on'),
                      opacity: pNewFade,
                      child: Transform.translate(
                        offset: Offset(0, PantasSpace.s28 * (1 - pNew)),
                        child: Text(
                          'Pro is on until $endText',
                          maxLines: 1,
                          style: titleStyle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
        final titleRow = Row(
          children: [
            crown,
            SizedBox(width: wide ? PantasSpace.s10 : PantasSpace.s8),
            Expanded(child: title),
          ],
        );
        final sublineText = Text(
          subline,
          style: context.fbSub,
        );
        final strip = _MonthStrip(
          firstMonth: firstMonth,
          on: on,
          seg: _seg,
          label: on && startsAt != null && endsAt != null
              ? 'Pro for 12 months, ${monthAbbr(phTime(startsAt).month)} '
                  '${phTime(startsAt).year} to '
                  '${monthAbbr(phTime(endsAt).month)} ${phTime(endsAt).year}'
              : '12 months of Pro, not turned on yet',
        );
        final collapse = on ? _seg(0, 320, PantasCurves.move) : 0.0;
        final fadeOut = on ? _seg(0, 200, PantasCurves.fade) : 0.0;
        final button = collapse >= 1
            ? const SizedBox.shrink()
            : ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1 - collapse,
                  child: Opacity(
                    opacity: 1 - fadeOut,
                    child: FbButton(
                      key: const ValueKey('activate-button'),
                      onPressed: _activate,
                      busy: _working,
                      child: _working
                          ? const FbSpinner()
                          : const Text('Activate 1 Year of Pro'),
                    ),
                  ),
                ),
              );
        final lineRise = on ? _seg(500, 400, PantasCurves.enter) : 0.0;
        final line = !on
            ? const SizedBox.shrink()
            : Opacity(
                opacity: lineRise,
                child: Transform.translate(
                  offset: Offset(0, 14 * (1 - lineRise)),
                  child: Row(
                    children: [
                      FbGlyph(
                        FbGlyphKind.check,
                        size: 18,
                        color: c.accent,
                        stroke: 2.6,
                        progress: _seg(600, 350, PantasCurves.draw),
                      ),
                      const SizedBox(width: PantasSpace.s8),
                      Expanded(
                        child: Text(
                          'Turned on $turnedOn. Every exam is included.',
                          style: context.fbSub,
                        ),
                      ),
                    ],
                  ),
                ),
              );

        final Widget card;
        if (wide) {
          card = FbRise(
            dy: 14,
            duration: PantasDurations.long1,
            child: FbCard(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s20,
                PantasSpace.s20,
                PantasSpace.s20,
                PantasSpace.s20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  titleRow,
                  Padding(
                    padding: const EdgeInsets.only(
                      left: PantasSpace.s32,
                      top: PantasSpace.s6,
                    ),
                    child: sublineText,
                  ),
                  const SizedBox(height: PantasSpace.s20),
                  strip,
                  const SizedBox(height: PantasSpace.s20),
                  button,
                  line,
                ],
              ),
            ),
          );
        } else {
          card = FbCard(
            radius: 18,
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s18,
              PantasSpace.s18,
              PantasSpace.s18,
              PantasSpace.s20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FbRise(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: titleRow,
                ),
                const SizedBox(height: PantasSpace.s4),
                FbRise(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 260),
                  child: sublineText,
                ),
                const SizedBox(height: PantasSpace.s16),
                strip,
                const SizedBox(height: PantasSpace.s18),
                FbRise(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 320),
                  child: button,
                ),
                line,
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [card, FbFootnote(footnote)],
        );
      },
    );
  }
}

/// Twelve bars, one per month of Pro, each with its month under it. Turning
/// the reward on fills them gold from the left (420 ms, 45 ms apart).
class _MonthStrip extends StatelessWidget {
  const _MonthStrip({
    required this.firstMonth,
    required this.on,
    required this.seg,
    required this.label,
  });
  final int firstMonth;
  final bool on;
  final double Function(double start, double ms, Curve curve) seg;
  final String label;

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    final gap = wide ? PantasSpace.s6 : PantasSpace.s4;
    final cells = <Widget>[];
    for (var j = 0; j < 12; j++) {
      final start = 120.0 + 45 * j;
      final fill = on ? seg(start, 420, PantasCurves.move) : 0.0;
      final name = monthAbbr(firstMonth + j);
      cells.add(
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(PantasRadius.full),
              child: ColoredBox(
                color: c.fill,
                child: SizedBox(
                  height: wide ? PantasSpace.s8 : PantasSpace.s6,
                  width: double.infinity,
                  child: Transform(
                    key: ValueKey('month-fill-$j'),
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.diagonal3Values(fill, 1, 1),
                    child: ColoredBox(color: c.pro),
                  ),
                ),
              ),
            ),
            SizedBox(height: wide ? 7 : 6),
            Text(
              wide ? name : name.substring(0, 1),
              key: ValueKey('month-label-$j'),
              style: (wide
                      ? PantasType.webKeyHintSm
                      : PantasType.phoneCaptionSmall)
                  .copyWith(
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    return Semantics(
      label: label,
      image: true,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var j = 0; j < 12; j++) ...[
            if (j > 0) SizedBox(width: gap),
            Expanded(child: cells[j]),
          ],
        ],
      ),
    );
  }
}
