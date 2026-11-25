import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/rolling_digits.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/presentation/session_entry_motion.dart';

/// "You finished the lesson" (frames P06, P06_EndRM, W06). The score once,
/// as a count over "/3", the three dots, one line, and the mistakes. No arc,
/// diagnosis, rating or notes card.
class FirstRunEnd extends StatefulWidget {
  const FirstRunEnd({
    required this.outcomes,
    required this.stems,
    required this.subjectName,
    required this.onDone,
    required this.onOpenMistake,
    super.key,
  });

  /// True for a right answer, in question order.
  final List<bool> outcomes;

  /// Each question's stem, in question order.
  final List<String> stems;
  final String subjectName;
  final VoidCallback onDone;
  final ValueChanged<int> onOpenMistake;

  @override
  State<FirstRunEnd> createState() => _FirstRunEndState();
}

class _FirstRunEndState extends State<FirstRunEnd>
    with SingleTickerProviderStateMixin {
  // ds-board: P06 timeline ends with Done at 2500 ms; W06 ends with the
  // mistakes block at 1600 ms.
  static const _phoneTimeline = Duration(milliseconds: 2600);
  static const _wideTimeline = Duration(milliseconds: 1600);

  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: _phoneTimeline,
  );
  late final _motion = SessionEntryMotion(_entry);
  bool? _still;
  bool? _wide;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    final wide = context.wideWeb;
    if (still == _still && wide == _wide) return;
    _still = still;
    _wide = wide;
    _entry.duration = wide ? _wideTimeline : _phoneTimeline;
    if (still) {
      _entry
        ..stop()
        ..value = 1;
    } else {
      _entry.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  int get _score => widget.outcomes.where((o) => o).length;

  List<int> get _misses => [
        for (var i = 0; i < widget.outcomes.length; i++)
          if (!widget.outcomes[i]) i,
      ];

  /// The count rolls up a strip of rows from 0 to the score. P06: 400 ms
  /// wait, then 1200 ms on the gauge ease. W06: 300 ms, then 1200 ms on the
  /// enter ease. Both end by 1600 ms of their own timeline.
  Widget _count(TextStyle numeral, TextStyle unit, {required bool wide}) {
    final total = _entry.duration!.inMilliseconds;
    final start = wide ? 300 : 400;
    final roll = _entry.drive(
      Tween<double>(begin: 0, end: _score.toDouble()).chain(
        CurveTween(
          curve: Interval(
            start / total,
            (start + 1200) / total,
            curve: wide ? PantasCurves.enter : PantasCurves.gauge,
          ),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RollingDigits(
          count: roll,
          last: _score,
          style: numeral,
          // ds-board: P06 rows 64, W06 80
          rowHeight: wide ? 80 : 64,
          fade: true,
        ),
        SizedBox(width: wide ? PantasSpace.s2 : PantasSpace.s4),
        Padding(
          // ds-board: P06 `padding-bottom: 9px`
          padding: EdgeInsets.only(bottom: wide ? PantasSpace.s8 : 9),
          child: Text('/3', style: unit),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final colors = context.colors;
    // W06 draws the title, the line and Done at once; P06 staggers them.
    Widget phoneOnly(
      Widget child,
      int start,
      int duration, {
      double rise = 0,
    }) =>
        wide ? child : _motion.appear(child, start, duration, rise: rise);
    final title = phoneOnly(
      Semantics(
        header: true,
        child: Text(
          'You finished the lesson',
          textAlign: TextAlign.center,
          style: (wide ? PantasType.webH1 : PantasType.phoneLargeTitle)
              .copyWith(color: colors.textPrimary),
        ),
      ),
      100,
      380,
      rise: 6,
    );
    // ds-board: P06 count 60, W06 76, letter spacing -.03em
    final numeralSize = wide ? 76.0 : 60.0;
    final numeral = PantasType.phoneDisplayM.copyWith(
      fontSize: numeralSize,
      letterSpacing: -.03 * numeralSize,
      color: colors.textPrimary,
    );
    final unit = PantasType.phoneTitle2.copyWith(
      // ds-board: P06 total 24, W06 28
      fontSize: wide ? 28 : 24,
      color: colors.textSecondary,
      fontWeight: FontWeight.w600,
    );
    final summary = Column(
      children: [
        Semantics(
          label: '$_score of 3 correct',
          excludeSemantics: true,
          child: Column(
            children: [
              _count(numeral, unit, wide: wide),
              Text(
                'correct',
                style: PantasType.phoneBody.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PantasSpace.s20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.outcomes.length; i++) ...[
              if (i > 0) const SizedBox(width: PantasSpace.s10),
              _dot(i, wide: wide),
            ],
          ],
        ),
        const SizedBox(height: PantasSpace.s20),
        phoneOnly(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s12),
            child: Text(
              'Take the assessment on Home for your score and study plan.',
              textAlign: TextAlign.center,
              style: PantasType.phoneBody
                  .copyWith(color: colors.textSecondary, height: 1.4),
            ),
          ),
          1710,
          315,
        ),
        if (_misses.isNotEmpty) ...[
          const SizedBox(height: PantasSpace.s32),
          _mistakesBlock(context, wide: wide),
        ],
      ],
    );
    final done = phoneOnly(
      wide
          ? WebButton(label: 'Done', keyHint: 'Enter', onPressed: widget.onDone)
          : PantasButton(
              label: 'Done',
              size: PantasButtonSize.phone,
              fullWidth: true,
              onPressed: widget.onDone,
            ),
      2200,
      300,
    );
    if (wide) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s24,
              PantasSpace.s24,
              PantasSpace.s24,
              PantasSpace.s0,
            ),
            child: Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                title,
                Expanded(
                  child: Align(alignment: Alignment.centerRight, child: done),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(PantasSpace.s24),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: PantasLayout.qcolNarrow),
                  child: summary,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                PantasLayout.gutterPhone,
                // ds-board: P06 title top
                PantasSpace.s56,
                PantasLayout.gutterPhone,
                PantasSpace.s24,
              ),
              child: Column(
                children: [
                  title,
                  const SizedBox(height: PantasSpace.s24),
                  summary,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s20,
              PantasSpace.s12,
              PantasSpace.s20,
              PantasSpace.s16,
            ),
            child: done,
          ),
        ],
      ),
    );
  }

  Widget _mistakesBlock(BuildContext context, {required bool wide}) {
    final block = _mistakes(context, wide: wide);
    // ds-board: W06 `up .5s 1.1s cubic-bezier(.2,.9,.3,1)`, 10 px
    if (wide) {
      return _motion.appear(
        block,
        1100,
        500,
        rise: 10,
        curve: PantasCurves.enter,
      );
    }
    return _motion.appear(block, 1620, 380, rise: 8);
  }

  Widget _dot(int i, {required bool wide}) {
    final dot = _Dot(
      key: ValueKey('end-dot-${i + 1}'),
      number: i + 1,
      right: widget.outcomes[i],
    );
    // ds-board: W06 `pop .4s` at .30, .38 and .46 s on the spring ease
    return wide
        ? _motion.pop(
            i,
            dot,
            start: 300,
            step: 80,
            grow: 240,
            curve: PantasCurves.spring,
          )
        : _motion.pop(i, dot);
  }

  Widget _mistakes(BuildContext context, {required bool wide}) {
    final colors = context.colors;
    final misses = _misses;
    return Column(
      key: const ValueKey('end-mistakes'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'YOUR MISTAKES',
                style: PantasType.phoneSectionHeader
                    .copyWith(color: colors.textSecondary),
              ),
            ),
            Text(
              '${misses.length}',
              style: PantasType.phoneSectionHeader
                  .copyWith(color: colors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: PantasSpace.s8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceCard,
            borderRadius: BorderRadius.circular(PantasRadius.lg),
          ),
          child: Column(
            children: [
              for (final i in misses)
                _MistakeRow(
                  stem: widget.stems[i],
                  subject: widget.subjectName,
                  onTap: () => widget.onOpenMistake(i),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.number, required this.right, super.key});

  final int number;
  final bool right;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'Question $number, ${right ? 'correct' : 'wrong'}',
      excludeSemantics: true,
      child: Container(
        // ds-board: P06 dots 28, W06 30
        width: context.wideWeb ? 30 : 28,
        height: context.wideWeb ? 30 : 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: right ? colors.accentTint : colors.dangerTint,
        ),
        child: Text(
          '$number',
          style: PantasType.phoneCaption.copyWith(
            color: right ? colors.accent : colors.dangerText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MistakeRow extends StatelessWidget {
  const _MistakeRow({
    required this.stem,
    required this.subject,
    required this.onTap,
  });

  final String stem;
  final String subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final plain = ContentRenderer.plainText(stem);
    return Semantics(
      button: true,
      label: '$plain, $subject',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PantasRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s16,
            vertical: PantasSpace.s12,
          ),
          child: Row(
            children: [
              SizedBox(
                // ds-board: P06 mark column 22
                width: PantasSpace.s20 + PantasSpace.s2,
                child: Icon(
                  PantasIcons.close,
                  size: PantasSpace.s16,
                  color: colors.dangerText,
                ),
              ),
              const SizedBox(width: PantasSpace.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plain,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PantasType.phoneHeadline.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      subject,
                      style: PantasType.phoneCaption
                          .copyWith(color: colors.textSecondary),
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
