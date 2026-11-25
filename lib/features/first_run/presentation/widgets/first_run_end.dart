import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
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
  // ds-board: P06 timeline: Done ends at 2500 ms
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final _motion = SessionEntryMotion(_entry);
  bool? _still;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still == _still) return;
    _still = still;
    if (still) {
      _entry
        ..stop()
        ..value = 1;
    } else {
      _entry.forward();
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

  /// The count rolls from 0 to the score from 400 ms to 1600 ms.
  Widget _count(TextStyle numeral, TextStyle unit) => AnimatedBuilder(
        animation: _entry,
        builder: (context, _) {
          final ms = _entry.value * _entry.duration!.inMilliseconds;
          final t = ((ms - 400) / 1200).clamp(0.0, 1.0);
          final shown = (_score * PantasCurves.house.transform(t)).round();
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$shown', style: numeral),
              Text('/3', style: unit),
            ],
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final wide = context.wideWeb;
    final colors = context.colors;
    final title = _motion.appear(
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
    final numeral = (wide ? PantasType.webBigNumeral : PantasType.phoneDisplayL)
        .copyWith(color: colors.textPrimary);
    final unit = PantasType.phoneTitle2.copyWith(
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
              _count(numeral, unit),
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
              _motion.pop(i, _Dot(number: i + 1, right: widget.outcomes[i])),
            ],
          ],
        ),
        const SizedBox(height: PantasSpace.s20),
        _motion.appear(
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
          _motion.appear(_mistakes(context, wide: wide), 1620, 380, rise: 8),
        ],
      ],
    );
    final done = _motion.appear(
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
                56,
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

  Widget _mistakes(BuildContext context, {required bool wide}) {
    final colors = context.colors;
    final misses = _misses;
    return Column(
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
  const _Dot({required this.number, required this.right});

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
                width: 22,
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
