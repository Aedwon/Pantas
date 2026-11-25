import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

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
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s20,
                PantasSpace.s12,
                PantasSpace.s20,
                PantasSpace.s16,
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
                              keyHint: 'Esc',
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
              style: (wide ? PantasType.webH1 : PantasType.phoneLargeTitle)
                  .copyWith(color: colors.textPrimary),
            ),
          ),
        ),
        const SizedBox(height: PantasSpace.s28),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            // ds-board: W02 card radius 16
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
          const SizedBox(width: PantasSpace.s12),
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
                  const SizedBox(height: PantasSpace.s12),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(PantasRadius.md),
      child: Container(
        width: width,
        height: height,
        color: colors.bgPage,
        padding: const EdgeInsets.all(PantasSpace.s12),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // ds-board: bottom fade mask
            stops: const [0.6, 1],
            colors: [colors.textPrimary, Colors.transparent],
          ).createShader(rect),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxHeight: double.infinity,
            child: child,
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
            'MATHEMATICS · ARITHMETIC',
            style: PantasType.phoneCaption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PantasSpace.s4),
          Text(
            'Fractions, Decimals, and Percentages',
            style: PantasType.phoneHeadline.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PantasSpace.s4),
          Text(
            'Fractions, decimals, and percentages are three ways to '
            'represent the same quantities.',
            style: PantasType.phoneCaption.copyWith(color: colors.textPrimary),
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
    Widget choice(String letter, String text, {required bool picked}) =>
        Opacity(
          opacity: picked ? 1 : .45,
          child: Container(
            margin: const EdgeInsets.only(top: PantasSpace.s6),
            padding: const EdgeInsets.all(PantasSpace.s8),
            decoration: BoxDecoration(
              color: picked ? colors.accentTint : colors.surfaceCard,
              borderRadius: BorderRadius.circular(PantasRadius.md),
              border: picked ? Border.all(color: colors.accent) : null,
            ),
            child: Row(
              children: [
                Text(
                  letter,
                  style: PantasType.phoneCaption.copyWith(
                    color: picked ? colors.accent : colors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: PantasSpace.s8),
                Text(
                  text,
                  style: PantasType.phoneCaption
                      .copyWith(color: colors.textPrimary),
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
            style: PantasType.phoneCaption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PantasSpace.s4),
          Text(
            'What is 3/8 expressed as a percentage?',
            style: PantasType.phoneHeadline.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          choice('A', '3.75%', picked: false),
          choice('B', '37.5%', picked: true),
        ],
      ),
    );
  }
}

/// The wide section slides in 40 px and fades over 0.4 s (frame W02). Off
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
            Transform.translate(offset: Offset(0, 40 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}
