import 'dart:math' as math;

import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

// ds-board: P02 title 30
const double _titlePx = 30;
// ds-board: preview eyebrow 13
const double _eyebrowPx = 13;
// ds-board: preview body 16
const double _bodyPx = 16;
// ds-board: preview stem 21
const double _stemPx = 21;
// ds-board: preview option padding 13
const double _optPadPx = 13;
// ds-board: P02 actions padding-bottom 34 (the home bar)
const double _homeBarPx = 34;

/// What the two previews show. The board draws static crops of today's
/// lesson and question 0001; a test keeps these equal to the content source.
const introPreviewLessonTitle = 'Fractions, Decimals, and Percentages';
const introPreviewLessonLine =
    'Fractions, decimals, and percentages are three ways to represent the '
    'same quantities.';
const introPreviewStem = 'What is 3/8 expressed as a percentage?';
const introPreviewChoices = ['3.75%', '37.5%'];

/// "Try Pantas first" (frames P02, W02): three numbered steps, then Start
/// and Skip.
class FirstRunIntro extends StatelessWidget {
  const FirstRunIntro({
    required this.onStart,
    required this.onSkip,
    super.key,
  });

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) =>
      context.wideWeb ? _wide(context) : _phone(context);

  Widget _phone(BuildContext context) => SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  // P02: top spacer 52 plus body padding 24
                  PantasSpace.s56 + PantasSpace.s20,
                  PantasSpace.s16,
                  PantasSpace.s16,
                ),
                child: _body(context, wide: false),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                PantasSpace.s20,
                PantasSpace.s12,
                PantasSpace.s20,
                // ds-board: P02 actions padding-bottom 34 (the home bar)
                math.max(_homeBarPx, MediaQuery.viewPaddingOf(context).bottom),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PantasButton(
                    label: 'Start',
                    size: PantasButtonSize.phone,
                    fullWidth: true,
                    onPressed: onStart,
                  ),
                  const SizedBox(height: PantasSpace.s6),
                  PantasButton(
                    label: 'Skip',
                    variant: PantasButtonVariant.tertiary,
                    size: PantasButtonSize.phone,
                    fullWidth: true,
                    onPressed: onSkip,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _wide(BuildContext context) => Column(
        children: [
          // Frames W02 and W02D draw the same 64 px logo row as W01.
          const OnboardingTopBar(),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: _SlideIn(
                child: ConstrainedBox(
                  // ds-board: W02 column 640
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: SingleChildScrollView(
                    // ds-board: W02 body padding 40 plus section padding-top 64
                    padding: const EdgeInsets.only(
                      top: PantasSpace.s40 + PantasSpace.s56 + PantasSpace.s8,
                      bottom: PantasSpace.s40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _body(context, wide: true),
                        const SizedBox(height: PantasSpace.s28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            WebButton(
                              label: 'Skip',
                              kind: PantasButtonKind.tertiary,
                              onPressed: onSkip,
                            ),
                            const SizedBox(width: PantasSpace.s8),
                            WebButton(
                              label: 'Start',
                              keyHint: 'Enter',
                              onPressed: onStart,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _body(BuildContext context, {required bool wide}) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
          child: Semantics(
            header: true,
            child: Text(
              'Try Pantas first',
              style: (wide
                      ? PantasType.webH1
                      : PantasType.phoneLargeTitle.copyWith(
                          // ds-board: P02 title 30, tracking -.022em
                          fontSize: _titlePx,
                          // ds-board: P02 title tracking -.022em
                          letterSpacing: -.022 * _titlePx,
                        ))
                  .copyWith(color: colors.textPrimary),
            ),
          ),
        ),
        const SizedBox(height: PantasSpace.s28),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            // ds-geometry: W02 card radius 16
            borderRadius: BorderRadius.circular(wide ? 16 : PantasRadius.lg),
          ),
          child: Column(
            children: [
              _Step(
                number: 1,
                title: 'Read a short lesson',
                wide: wide,
                preview: _LessonPreview(wide: wide),
              ),
              _rule(colors.divider),
              _Step(
                number: 2,
                title: 'Answer 3 questions',
                detail: 'Each answer is explained.',
                wide: wide,
                preview: _QuestionPreview(wide: wide),
              ),
              _rule(colors.divider),
              _Step(
                number: 3,
                title: 'Get your score from the assessment on Home',
                wide: wide,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rule(Color color) => Divider(
        height: PantasBorder.hairline,
        thickness: PantasBorder.hairline,
        color: color,
      );
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.wide,
    this.detail,
    this.preview,
  });

  final int number;
  final String title;
  final String? detail;
  final bool wide;
  final Widget? preview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(
        // ds-board: P02 rows 14/16, W02 18/20
        vertical: wide ? PantasSpace.s18 : PantasSpace.s14,
        horizontal: wide ? PantasSpace.s20 : PantasSpace.s16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: wide ? PantasSize.optBadge : PantasSize.avatar,
            height: wide ? PantasSize.optBadge : PantasSize.avatar,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.accentTint,
            ),
            child: Text(
              '$number',
              style: PantasType.phoneBody.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // ds-board: P02 gap 12, W02 gap 16
          SizedBox(width: wide ? PantasSpace.s16 : PantasSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PantasType.phoneHeadline
                      .copyWith(color: colors.textPrimary),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: PantasType.phoneSubhead
                        .copyWith(color: colors.textSecondary),
                  ),
                if (preview != null) ...[
                  // ds-board: P02 and W02 step gap 10
                  const SizedBox(height: PantasSpace.s10),
                  // The crop is a picture of what the step shows. It adds
                  // nothing for a screen reader.
                  ExcludeSemantics(child: preview),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A picture of what a step shows: the real screen laid out at the board's
/// design width, scaled down and faded at the bottom (frames P02 and W02).
class _Crop extends StatelessWidget {
  const _Crop({required this.wide, required this.tall, required this.child});

  final bool wide;
  final bool tall;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // ds-board: previews 284x120 / 284x160 phone, 360x104 / 360x132 wide
    final width = wide ? 360.0 : 284.0;
    final height = wide ? (tall ? 132.0 : 104.0) : (tall ? 160.0 : 120.0);
    // ds-board: preview laid out 380 wide at .747 phone, 480 at .75 wide
    final design = wide ? 480.0 : 380.0;
    final scale = wide ? .75 : .747;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PantasRadius.md),
      child: Container(
        width: width,
        // ds-board: previews 284x120 / 284x160 phone, 360x104 / 360x132 wide
        height: height,
        color: colors.bgPage,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // ds-board: bottom fade mask, 45% lesson and 60% question
            stops: [if (tall) 0.6 else 0.45, 1],
            colors: [colors.textPrimary, Colors.transparent],
          ).createShader(rect),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: design,
            maxWidth: design,
            maxHeight: double.infinity,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              child: Padding(
                // ds-board: preview padding 16 16 0
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s16,
                  PantasSpace.s16,
                  PantasSpace.s0,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonPreview extends StatelessWidget {
  const _LessonPreview({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Crop(
      wide: wide,
      tall: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MATHEMATICS: ARITHMETIC',
            style: PantasType.phoneSubhead.copyWith(
              // ds-board: preview eyebrow 13/600, tracking .04em
              fontSize: _eyebrowPx,
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              // ds-board: preview eyebrow tracking .04em
              letterSpacing: .04 * _eyebrowPx,
              // ds-board: preview eyebrow line-height 1.35
              height: 1.35,
            ),
          ),
          const SizedBox(height: PantasSpace.s8),
          Text(
            introPreviewLessonTitle,
            style: PantasType.phoneLargeTitle.copyWith(
              // ds-board: preview title 30/700, tracking -.5, line 1.08
              fontSize: _titlePx,
              // ds-board: preview title tracking -.5
              letterSpacing: -.5,
              // ds-board: preview title line-height 1.08
              height: 1.08,
              color: colors.textPrimary,
            ),
          ),
          // ds-board: preview title margin-bottom 14
          const SizedBox(height: PantasSpace.s14),
          Text(
            introPreviewLessonLine,
            style: PantasType.phoneBody.copyWith(
              // ds-board: preview body 16, line 1.6, tracking -.1
              fontSize: _bodyPx,
              // ds-board: preview title line-height 1.08
              height: 1.6,
              // ds-board: preview eyebrow line-height 1.35
              letterSpacing: -.1,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionPreview extends StatelessWidget {
  const _QuestionPreview({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget choice(String text, String letter, {required bool picked}) =>
        Opacity(
          opacity: picked ? 1 : .45,
          child: Container(
            // ds-board: preview option padding 13/14, radius 14, gap 12
            padding: const EdgeInsets.symmetric(
              vertical: _optPadPx,
              horizontal: PantasSpace.s14,
            ),
            decoration: BoxDecoration(
              color: picked ? colors.accentTint : colors.surfaceCard,
              borderRadius: BorderRadius.circular(PantasRadius.lg),
              border:
                  picked ? Border.all(color: colors.accent, width: 1.5) : null,
            ),
            child: Row(
              children: [
                Container(
                  // ds-board: preview mark 30
                  width: 30,
                  // ds-board: preview mark 30
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: picked ? colors.accentFill : null,
                    border: picked
                        ? null
                        : Border.all(color: colors.borderControl, width: 1.5),
                  ),
                  child: picked
                      ? Icon(
                          PantasIcons.check,
                          // ds-board: preview check 15
                          size: 15,
                          color: colors.onAccent,
                        )
                      : Text(
                          letter,
                          style: PantasType.phoneSubhead.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                ),
                const SizedBox(width: PantasSpace.s12),
                Text(
                  text,
                  style: PantasType.phoneHeadline.copyWith(
                    fontWeight: picked ? FontWeight.w600 : FontWeight.w400,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
    return _Crop(
      wide: wide,
      tall: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MATHEMATICS',
            style: PantasType.phoneSubhead.copyWith(
              // ds-board: preview eyebrow 13/600, tracking .02em
              fontSize: _eyebrowPx,
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
              // ds-board: preview eyebrow tracking .02em
              letterSpacing: .02 * _eyebrowPx,
              // ds-board: preview eyebrow line-height 1.35
              height: 1.35,
            ),
          ),
          const SizedBox(height: PantasSpace.s8),
          Text(
            introPreviewStem,
            style: PantasType.phoneLargeTitle.copyWith(
              // ds-board: preview stem 21/600, tracking -.012em, line 1.35
              fontSize: _stemPx,
              fontWeight: FontWeight.w600,
              // ds-board: preview stem tracking -.012em
              letterSpacing: -.012 * _stemPx,
              // ds-board: preview stem line-height 1.35
              height: 1.35,
              color: colors.textPrimary,
            ),
          ),
          // ds-board: preview gap 14 between the stem and the choices
          const SizedBox(height: PantasSpace.s14),
          choice(introPreviewChoices[0], 'A', picked: false),
          const SizedBox(height: PantasSpace.s10),
          choice(introPreviewChoices[1], 'B', picked: true),
        ],
      ),
    );
  }
}

/// The wide section slides in 24 px from the right and fades over 0.4 s
/// (frame W02). Off
/// under Reduce Motion.
class _SlideIn extends StatelessWidget {
  const _SlideIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      // ds-board: W02 `push .4s cubic-bezier(.2,.9,.3,1)`
      duration: const Duration(milliseconds: 400),
      curve: PantasCurves.enter,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child:
            Transform.translate(offset: Offset(24 * (1 - t), 0), child: child),
      ),
      child: child,
    );
  }
}
