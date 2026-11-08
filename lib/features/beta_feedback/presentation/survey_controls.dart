import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/fb_kit.dart';

Duration _dur(BuildContext context, Duration d) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;

/// A numbered question: its title, then [child].
class SurveyQuestion extends StatelessWidget {
  const SurveyQuestion({
    required this.title,
    required this.child,
    this.optional = false,
    this.ends,
    super.key,
  });
  final String title;
  final bool optional;
  final Widget child;

  /// The captions under the two ends of a scale.
  final (String, String)? ends;

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    final style = context.fbTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            PantasSpace.s4,
            PantasSpace.s0,
            PantasSpace.s4,
            wide ? PantasSpace.s12 : PantasSpace.s10,
          ),
          child: Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                text: title,
                children: [
                  if (optional)
                    TextSpan(
                      text: ' Optional',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: c.textSecondary,
                      ),
                    ),
                ],
              ),
              style: style,
            ),
          ),
        ),
        child,
        if (ends != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PantasSpace.s4,
              PantasSpace.s6,
              PantasSpace.s4,
              PantasSpace.s0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ends!.$1, style: context.fbSmall),
                Text(ends!.$2, style: context.fbSmall),
              ],
            ),
          ),
      ],
    );
  }
}

/// Lays [children] out in rows of [columns] equal cells.
Widget surveyGrid(List<Widget> children, int columns, double gap) {
  final rows = <Widget>[];
  for (var i = 0; i < children.length; i += columns) {
    final cells = <Widget>[];
    for (var j = 0; j < columns; j++) {
      if (j > 0) cells.add(SizedBox(width: gap));
      cells.add(
        Expanded(
          child: i + j < children.length
              ? children[i + j]
              : const SizedBox.shrink(),
        ),
      );
    }
    if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
    rows.add(Row(children: cells));
  }
  return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
}

/// Question 1: the lettered options. The picked one gets an accent border and
/// tint (180 ms, ease) and its filled letter pops.
class LetterOptions extends StatelessWidget {
  const LetterOptions({
    required this.labels,
    required this.selected,
    required this.onPick,
    super.key,
  });
  final List<String> labels;
  final int? selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    final circle = wide ? PantasSize.optBadge : PantasSize.optBadgePhone;
    Widget option(int i) {
      final picked = selected == i;
      final letter = String.fromCharCode(65 + i);
      return Semantics(
        button: true,
        selected: picked,
        label: labels[i],
        excludeSemantics: true,
        child: GestureDetector(
          key: ValueKey('q1-$i'),
          behavior: HitTestBehavior.opaque,
          onTap: () => onPick(i),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: _dur(context, PantasDurations.short3),
              curve: PantasCurves.fade,
              padding: EdgeInsets.symmetric(
                vertical: wide ? PantasSpace.s10 : PantasSpace.s12,
                horizontal: wide ? PantasSpace.s10 : PantasSpace.s12,
              ),
              decoration: BoxDecoration(
                color: picked ? c.accentTint : c.surfaceCard,
                borderRadius: BorderRadius.circular(
                  wide ? PantasRadius.md : PantasRadius.lg,
                ),
                border: Border.all(
                  color: picked ? c.accent : Colors.transparent,
                  width: PantasBorder.ringStrong,
                ),
              ),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: circle,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: c.borderControl,
                                width: PantasBorder.ringStrong,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: PantasType.webFieldLabel
                                    .copyWith(color: c.textSecondary),
                              ),
                            ),
                          ),
                        ),
                        if (picked)
                          Positioned.fill(
                            child: FbPop(
                              peak: 1.12,
                              duration: PantasDurations.medium3,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: c.accentFill,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: PantasType.webFieldLabel
                                        .copyWith(color: c.onAccent),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: PantasSpace.s12),
                  Expanded(
                    child: Text(labels[i], style: context.fbBody),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final options = [for (var i = 0; i < labels.length; i++) option(i)];
    return wide
        ? surveyGrid(options, 2, PantasSpace.s8)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(height: PantasSpace.s8),
                options[i],
              ],
            ],
          );
  }
}

/// Questions 2 to 4: a 44 px track with a thumb that slides to the pick
/// (240 ms, shared ease) and fades in on the first pick (160 ms).
class SurveySegmented extends StatefulWidget {
  const SurveySegmented({
    required this.id,
    required this.labels,
    required this.selected,
    required this.onPick,
    this.firstValue = 0,
    super.key,
  });

  /// `q2`, `q3` or `q4`: the prefix of every key in the control.
  final String id;
  final List<String> labels;
  final int? selected;
  final ValueChanged<int> onPick;

  /// The value of the first segment, used in its key (ratings start at 1).
  final int firstValue;

  @override
  State<SurveySegmented> createState() => _SurveySegmentedState();
}

class _SurveySegmentedState extends State<SurveySegmented> {
  /// The first pick puts the thumb in place while it fades in; it does not
  /// slide in from the first segment.
  bool _jump = false;

  @override
  void didUpdateWidget(SurveySegmented old) {
    super.didUpdateWidget(old);
    _jump = old.selected == null && widget.selected != null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    final n = widget.labels.length;
    final picked = widget.selected;
    return LayoutBuilder(
      builder: (context, box) {
        const inset = PantasSpace.s6;
        const gap = PantasSpace.s4;
        final cell = (box.maxWidth - inset * 2 - gap * (n - 1)) / n;
        double left(int i) => inset + i * (cell + gap);
        return SizedBox(
          height: PantasSize.btn,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.fill,
                    borderRadius: BorderRadius.circular(PantasRadius.md),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _jump
                    ? Duration.zero
                    : _dur(context, PantasDurations.medium1),
                curve: PantasCurves.move,
                left: left(picked ?? 0),
                top: inset,
                bottom: inset,
                width: cell,
                child: AnimatedOpacity(
                  key: ValueKey('${widget.id}-thumb'),
                  opacity: picked == null ? 0 : 1,
                  duration: _dur(context, PantasDurations.short2),
                  curve: PantasCurves.fade,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.surfaceSegmentOn,
                      borderRadius: BorderRadius.circular(PantasRadius.sm),
                      boxShadow: context.shadows.segment,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(PantasSpace.s6),
                child: Row(
                  children: [
                    for (var i = 0; i < n; i++) ...[
                      if (i > 0) const SizedBox(width: PantasSpace.s4),
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: picked == i,
                          label: widget.labels[i],
                          excludeSemantics: true,
                          child: GestureDetector(
                            key: ValueKey(
                              '${widget.id}-${widget.firstValue + i}',
                            ),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.onPick(i),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Center(
                                child: FadingColor(
                                  color: picked == i
                                      ? c.textPrimary
                                      : c.textSecondary,
                                  builder: (context, color, _) => Text(
                                    widget.labels[i],
                                    style: PantasType.webLabel
                                        .copyWith(color: color),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Question 5: the 0 to 10 pills. The picked one fills with the label color
/// and pops (360 ms).
class SurveyPills extends StatelessWidget {
  const SurveyPills({required this.selected, required this.onPick, super.key});
  final int? selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    final dark = Theme.of(context).brightness == Brightness.dark;
    Widget pill(int i) => Semantics(
          button: true,
          selected: selected == i,
          label: '$i',
          excludeSemantics: true,
          child: GestureDetector(
            key: ValueKey('q5-$i'),
            behavior: HitTestBehavior.opaque,
            onTap: () => onPick(i),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                height: PantasSize.iconBtnMd,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.surfaceCard,
                          borderRadius:
                              BorderRadius.circular(PantasRadius.full),
                          border: wide && dark
                              ? Border.all(color: c.edgeCard)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$i',
                            style: PantasType.webRowSub
                                .copyWith(color: c.textPrimary),
                          ),
                        ),
                      ),
                    ),
                    if (selected == i)
                      Positioned.fill(
                        child: FbPop(
                          peak: 1.12,
                          duration: PantasDurations.switchDuration,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.textPrimary,
                              borderRadius:
                                  BorderRadius.circular(PantasRadius.full),
                            ),
                            child: Center(
                              child: Text(
                                '$i',
                                style: PantasType.webLabel
                                    .copyWith(color: c.surfaceCard),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
    return surveyGrid(
      [for (var i = 0; i <= 10; i++) pill(i)],
      wide ? 11 : 6,
      wide ? PantasSpace.s6 : PantasSpace.s8,
    );
  }
}

/// Questions 6 and 7: a text answer, drawn as the design system Field: a
/// `surface-card` well, `radius-md`, a 1 `border-control` ring, and a 2
/// `accent` ring on focus. An answer with text keeps the accent ring, fading
/// in over `dur-short-2`.
class SurveyTextBox extends StatefulWidget {
  const SurveyTextBox({
    required this.id,
    required this.label,
    required this.controller,
    required this.rows,
    super.key,
  });
  final String id;
  final String label;
  final TextEditingController controller;
  final int rows;

  @override
  State<SurveyTextBox> createState() => _SurveyTextBoxState();
}

class _SurveyTextBoxState extends State<SurveyTextBox> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final filled = widget.controller.text.trim().isNotEmpty;
        final lit = filled || _focus.hasFocus;
        final style = context.fbBody;
        return FbFieldWell(
          boxKey: ValueKey('${widget.id}-box'),
          lit: lit,
          child: Semantics(
            label: widget.label,
            textField: true,
            child: TextField(
              key: ValueKey('${widget.id}-field'),
              controller: widget.controller,
              focusNode: _focus,
              minLines: widget.rows,
              maxLines: widget.rows,
              keyboardType: TextInputType.multiline,
              style: style,
              cursorColor: c.accent,
              decoration: InputDecoration.collapsed(
                hintText: 'Your answer',
                hintStyle: style.copyWith(color: c.textSecondary),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The 7 segment progress bar and "{n} of 7" (wide web only).
class SurveyProgress extends StatelessWidget {
  const SurveyProgress({required this.answered, super.key});
  final int answered;

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PantasSpace.s4),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: 'Questions answered',
              value: '$answered of 7',
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: PantasSpace.s6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(PantasRadius.full),
                        child: ColoredBox(
                          color: c.fill,
                          child: SizedBox(
                            height: PantasSize.sliderTrack,
                            child: AnimatedFractionallySizedBox(
                              duration: _dur(context, PantasDurations.medium1),
                              curve: PantasCurves.move,
                              alignment: Alignment.centerLeft,
                              widthFactor: i < answered ? 1 : 0,
                              heightFactor: 1,
                              child: ColoredBox(color: c.accentFill),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: PantasSpace.s14),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: PantasSpace.s56),
            child: Text(
              '$answered of 7',
              textAlign: TextAlign.right,
              style: PantasType.webSmall.copyWith(
                color: c.textSecondary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Your Sent Feedback", a row that opens the list inline (300 ms, shared
/// ease). The chevron turns 90 degrees (240 ms); the items fade in and rise
/// 6 px one after another.
class SentFeedbackExpander extends StatelessWidget {
  const SentFeedbackExpander({
    required this.items,
    required this.open,
    required this.onToggle,
    super.key,
  });
  final List<SentFeedback> items;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    final rowStyle = context.fbBody;
    return FbCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: open,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: wide ? 0 : PantasSize.rowMinPhone,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: PantasSpace.s16,
                      vertical: wide ? PantasSpace.s12 : PantasSpace.s10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Your Sent Feedback', style: rowStyle),
                        ),
                        Text(
                          '${items.length}',
                          style: rowStyle.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(width: PantasSpace.s12),
                        AnimatedRotation(
                          key: const ValueKey('sent-chevron'),
                          turns: open ? .25 : 0,
                          duration: _dur(context, PantasDurations.medium1),
                          curve: PantasCurves.move,
                          child: Icon(
                            PantasIcons.next,
                            size: PantasSpace.s16,
                            color: c.iconChevron,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(end: open ? 1 : 0),
            duration: _dur(context, PantasDurations.flip),
            curve: PantasCurves.move,
            builder: (context, v, _) {
              if (v == 0) return const SizedBox.shrink();
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: v.clamp(0.0, 1.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PantasSpace.s16,
                        ),
                        child: Container(
                          height: PantasBorder.hairline,
                          color: c.divider,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          PantasSpace.s16,
                          PantasSpace.s6,
                          PantasSpace.s16,
                          PantasSpace.s14,
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              _SentItem(
                                item: items[i],
                                open: open,
                                delay: Duration(milliseconds: 60 + 40 * i),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SentItem extends StatelessWidget {
  const _SentItem({
    required this.item,
    required this.open,
    required this.delay,
  });
  final SentFeedback item;
  final bool open;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final c = context.fb;
    final images = item.attachments.length;
    final hasText = item.text.trim().isNotEmpty;
    const fade = PantasDurations.nudge;
    final total = delay + PantasDurations.flip;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: open ? 1 : 0),
      duration: _dur(context, total),
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: PantasCurves.enter,
      ),
      builder: (context, t, child) => Opacity(
        opacity:
            (t * (total.inMilliseconds / fade.inMilliseconds)).clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, PantasSpace.s6 * (1 - t)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PantasSpace.s8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: PantasSpace.s56,
              child: Text(monthDay(item.createdAt), style: context.fbSub),
            ),
            const SizedBox(width: PantasSpace.s12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: hasText ? item.text.trim() : '',
                  children: [
                    if (images > 0)
                      TextSpan(
                        text: hasText
                            ? ' ${imageCount(images)}'
                            : imageCount(images),
                        style: TextStyle(color: c.textSecondary),
                      ),
                  ],
                ),
                style: context.fbSub.copyWith(color: c.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
