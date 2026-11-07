import 'package:flutter/material.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/motion/pantas_durations.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
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
    final style = context.fbText(
      wide ? 16 : 17,
      weight: FontWeight.w600,
      spacing: wide ? 0 : -.204,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, wide ? 12 : 10),
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
                        color: c.secondaryLabel,
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
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ends!.$1,
                  style: context.fbText(13, color: c.secondaryLabel),
                ),
                Text(
                  ends!.$2,
                  style: context.fbText(13, color: c.secondaryLabel),
                ),
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
    final circle = wide ? 28.0 : 30.0;
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
              duration: _dur(context, const Duration(milliseconds: 180)),
              curve: PantasCurves.ease,
              padding: EdgeInsets.symmetric(
                vertical: wide ? 9.5 : 11.5,
                horizontal: wide ? 10.5 : 12.5,
              ),
              decoration: BoxDecoration(
                color: picked ? c.accentTint : c.surface,
                borderRadius: BorderRadius.circular(wide ? 12 : 14),
                border: Border.all(
                  color: picked ? c.accent : c.transparent,
                  width: 1.5,
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
                                color: c.choiceOutline,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: context.fbText(
                                  wide ? 13 : 14,
                                  weight: FontWeight.w600,
                                  color: c.secondaryLabel,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (picked)
                          Positioned.fill(
                            child: FbPop(
                              peak: 1.12,
                              duration: const Duration(milliseconds: 420),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: c.accentFill,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: context.fbText(
                                      wide ? 13 : 14,
                                      weight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      labels[i],
                      style: context.fbText(
                        wide ? 16 : 17,
                        spacing: wide ? 0 : -.204,
                      ),
                    ),
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
        ? surveyGrid(options, 2, 8)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
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
        final cell = (box.maxWidth - 12 - 4 * (n - 1)) / n;
        double left(int i) => 6 + i * (cell + 4);
        return SizedBox(
          height: 44,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.fill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration:
                    _jump ? Duration.zero : _dur(context, PantasDurations.base),
                curve: PantasCurves.shared,
                left: left(picked ?? 0),
                top: 6,
                bottom: 6,
                width: cell,
                child: AnimatedOpacity(
                  key: ValueKey('${widget.id}-thumb'),
                  opacity: picked == null ? 0 : 1,
                  duration: _dur(context, PantasDurations.quick),
                  curve: PantasCurves.ease,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.segmentOn,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: c.segmentedShadow,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    for (var i = 0; i < n; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
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
                                  color:
                                      picked == i ? c.label : c.secondaryLabel,
                                  builder: (context, color, _) => Text(
                                    widget.labels[i],
                                    style: context.fbText(
                                      14,
                                      weight: FontWeight.w600,
                                      color: color,
                                    ),
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
                height: 40,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(99),
                          border: wide && dark
                              ? Border.all(color: c.cardEdge)
                              : null,
                        ),
                        child: Center(
                          child: Text('$i', style: context.fbText(14)),
                        ),
                      ),
                    ),
                    if (selected == i)
                      Positioned.fill(
                        child: FbPop(
                          peak: 1.12,
                          duration: const Duration(milliseconds: 360),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: c.label,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Center(
                              child: Text(
                                '$i',
                                style: context.fbText(
                                  14,
                                  weight: FontWeight.w600,
                                  color: c.surface,
                                ),
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
      wide ? 6 : 8,
    );
  }
}

/// Questions 6 and 7: a text answer. An answer with text takes an accent
/// border (phone 1.5 px; wide 1 px and a 1 px ring), fading in over 160 ms.
class SurveyTextBox extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final wide = context.fbWide;
    final c = context.fb;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final filled = controller.text.trim().isNotEmpty;
        final border = wide ? 1.0 : 1.5;
        final style = wide
            ? context.fbText(16, height: 1.4)
            : context.fbText(17, height: 1.35, spacing: -.204);
        return AnimatedContainer(
          key: ValueKey('$id-box'),
          duration: _dur(context, PantasDurations.quick),
          curve: PantasCurves.ease,
          // The border takes room when it appears, so the text keeps its
          // place by giving that room back while it is absent.
          padding: EdgeInsets.symmetric(
            vertical: (wide ? 12 : 12) - border + (filled ? 0 : border),
            horizontal: (wide ? 15 : 16) - border + (filled ? 0 : border),
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(wide ? 12 : 14),
            border: filled
                ? Border.all(color: c.accent, width: border)
                : wide
                    ? Border.all(color: c.separator)
                    : null,
            boxShadow: wide && filled
                ? [BoxShadow(color: c.accent, spreadRadius: 1)]
                : null,
          ),
          child: Semantics(
            label: label,
            textField: true,
            child: TextField(
              key: ValueKey('$id-field'),
              controller: controller,
              minLines: rows,
              maxLines: rows,
              keyboardType: TextInputType.multiline,
              style: style,
              cursorColor: c.accent,
              decoration: InputDecoration.collapsed(
                hintText: 'Your answer',
                hintStyle: style.copyWith(color: c.tertiaryLabel),
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: 'Questions answered',
              value: '$answered of 7',
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: ColoredBox(
                          color: c.fill,
                          child: SizedBox(
                            height: 4,
                            child: AnimatedFractionallySizedBox(
                              duration: _dur(context, PantasDurations.base),
                              curve: PantasCurves.shared,
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
          const SizedBox(width: 14),
          SizedBox(
            width: 72,
            child: Text(
              '$answered of 7',
              textAlign: TextAlign.right,
              style: context
                  .fbText(13, weight: FontWeight.w500, color: c.secondaryLabel)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
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
    final rowStyle =
        wide ? context.fbText(16) : context.fbText(17, spacing: -.204);
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
                  constraints: BoxConstraints(minHeight: wide ? 0 : 45),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: wide ? 12 : 11,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Your Sent Feedback', style: rowStyle),
                        ),
                        Text(
                          '${items.length}',
                          style: context.fbText(
                            wide ? 15 : 17,
                            color: c.secondaryLabel,
                            spacing: wide ? 0 : -.204,
                          ),
                        ),
                        const SizedBox(width: 12),
                        AnimatedRotation(
                          key: const ValueKey('sent-chevron'),
                          turns: open ? .25 : 0,
                          duration: _dur(context, PantasDurations.base),
                          curve: PantasCurves.shared,
                          child: Icon(
                            PantasIcons.next,
                            size: 16,
                            color: c.chevron,
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
            duration: _dur(context, const Duration(milliseconds: 300)),
            curve: PantasCurves.shared,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(height: .5, color: c.separator),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
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
    const fade = Duration(milliseconds: 200);
    final total = delay + const Duration(milliseconds: 300);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: open ? 1 : 0),
      duration: _dur(context, total),
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: PantasCurves.riseIn,
      ),
      builder: (context, t, child) => Opacity(
        opacity: (t * (300 / fade.inMilliseconds)).clamp(0.0, 1.0),
        child:
            Transform.translate(offset: Offset(0, 6 * (1 - t)), child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Text(
                monthDay(item.createdAt),
                style: context.fbText(15, height: 1.4, color: c.secondaryLabel),
              ),
            ),
            const SizedBox(width: 12),
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
                        style: TextStyle(color: c.secondaryLabel),
                      ),
                  ],
                ),
                style: context.fbText(15, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
