import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pantas_icon_button.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/row_tap_target.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Desktop presentation only. The page owns the draft and validates Save.
class WebCustomMockSetup extends StatelessWidget {
  const WebCustomMockSetup({
    required this.questions,
    required this.minutes,
    required this.available,
    required this.fits,
    required this.overLimit,
    required this.failed,
    required this.breakdown,
    required this.timedSeparately,
    required this.unset,
    required this.sections,
    required this.questionValues,
    required this.minuteValues,
    required this.onQuestions,
    required this.onMinutes,
    required this.onBreakdown,
    required this.onTiming,
    required this.onSection,
    this.onSave,
    this.onBack,
    this.onTickMoreSubjects,
    super.key,
  });
  final int questions;
  final int minutes;
  final int available;

  /// False while the total passes what the subjects hold and no section is
  /// over to explain it. Then the card shows the ceiling line.
  final bool fits;

  /// The total is past what one mock can hold.
  final bool overLimit;

  /// The last save did not go through.
  final bool failed;
  final bool breakdown;
  final bool timedSeparately;
  final bool unset;

  /// `held` is what the subject's topics hold. `over` is a section that asks
  /// for more than that.
  final List<
      ({
        String id,
        String name,
        int? questions,
        int? minutes,
        int held,
        bool over,
      })> sections;
  final List<int> questionValues;
  final List<int> minuteValues;
  final ValueChanged<int> onQuestions;
  final ValueChanged<int> onMinutes;
  final ValueChanged<bool> onBreakdown;
  final ValueChanged<bool> onTiming;
  final void Function(String id, int value, {required bool minutes}) onSection;
  final VoidCallback? onSave;
  final VoidCallback? onBack;
  final VoidCallback? onTickMoreSubjects;

  String _duration(int value) =>
      '${value ~/ 60}h ${(value % 60).toString().padLeft(2, '0')}m';
  Widget _breakdownContent(WebTokens t, TextStyle rowStyle) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!breakdown)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s8,
                PantasSpace.s16,
                PantasSpace.s0,
              ),
              child: Text(
                "You'll be timed, so exam day feels familiar.",
                style: t.sm,
              ),
            ),
          if (breakdown) ...[
            const SizedBox(height: PantasSpace.s24),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s0,
                PantasSpace.s16,
                PantasSpace.s8,
              ),
              child: Text('SECTION BREAKDOWN', style: t.eb),
            ),
            WebCard(
              radius: 16,
              child: Column(
                children: [
                  for (final section in sections)
                    _WideSectionRow(
                      name: section.name,
                      questions: section.questions,
                      minutes: section.minutes,
                      over: section.over,
                      questionValues: questionValues,
                      minuteValues: minuteValues,
                      onChanged: (value, {required minutes}) =>
                          onSection(section.id, value, minutes: minutes),
                    ),
                  RowTapTarget(
                    onTap: () => onTiming(!timedSeparately),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PantasSpace.s16,
                        vertical: PantasSpace.s6,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Time each section separately',
                              style: rowStyle,
                            ),
                          ),
                          PantasSwitch(
                            value: timedSeparately,
                            label: 'Time each section separately',
                            onChanged: onTiming,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s16,
                PantasSpace.s8,
                PantasSpace.s16,
                PantasSpace.s0,
              ),
              child: Text('The totals above now add these up.', style: t.sm),
            ),
            if (timedSeparately && sections.length >= 2)
              _note(t, customPartByPartRule),
            if (overLimit)
              _note(
                t,
                'Mocks go up to 300 questions. This one adds up to '
                '$questions.',
                color: t.colors.wrongText,
              ),
            for (final section in sections)
              if (section.over)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    PantasSpace.s8,
                    PantasSpace.s16,
                    PantasSpace.s0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Your ${section.name} topics have ${section.held} '
                          'questions. A ${section.questions}-question '
                          'section needs more.',
                          style: t.sm.copyWith(color: t.colors.wrongText),
                        ),
                      ),
                      const SizedBox(width: PantasSpace.s8),
                      WebTextLink(
                        label: 'Tick More Subjects',
                        arrow: false,
                        onPressed: onTickMoreSubjects,
                      ),
                    ],
                  ),
                ),
          ],
        ],
      );

  Widget _note(WebTokens t, String text, {Color? color}) => Padding(
        padding: const EdgeInsets.fromLTRB(
          PantasSpace.s16,
          PantasSpace.s4,
          PantasSpace.s16,
          PantasSpace.s0,
        ),
        child: Text(text, style: t.sm.copyWith(color: color)),
      );

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final rowStyle = PantasType.webBody.copyWith(color: t.colors.textPrimary);
    final questionHint = '${questionValues.first} to ${questionValues.last}, '
        'in fives. Arrow keys work too.';
    final ceilingMessage = 'Your subjects have $available questions. '
        'A $questions-question mock needs more.';
    return Focus(
      onKeyEvent: enterKeyHandler(() => onSave?.call()),
      autofocus: true,
      child: Scaffold(
        backgroundColor: t.colors.background,
        body: SingleChildScrollView(
          key: const ValueKey('web-custom-setup'),
          // The page ends clear of the floating navigation on a landscape
          // tablet, as Mock setup does (3K-9).
          padding: EdgeInsets.fromLTRB(
            PantasSpace.s44,
            PantasSpace.s28,
            PantasSpace.s44,
            context.webPageBottomInset,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WebBackLink(
                    label: 'Quiz',
                    onPressed: onBack ?? () {},
                    nudge: false,
                  ),
                  const SizedBox(height: PantasSpace.s6),
                  Text('Set up your mock', style: t.h1),
                  const SizedBox(height: PantasSpace.s6),
                  Text(
                    "We'll build it from what you tell us.",
                    style: PantasType.webLead.copyWith(
                      color: t.colors.secondaryLabel,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: PantasSpace.s28),
                  SizedBox(
                    key: const ValueKey('web-custom-fields'),
                    width: 640,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WebCard(
                          radius: 16,
                          child: Column(
                            children: [
                              _WideNumberRow(
                                label: 'Questions',
                                value: questions,
                                display: '$questions',
                                values: questionValues,
                                editable: !breakdown,
                                refused: !fits || overLimit,
                                onChanged: onQuestions,
                                format: (v) => '$v',
                                helper: questionHint,
                              ),
                              if (!fits)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    PantasSpace.s16,
                                    PantasSpace.s0,
                                    PantasSpace.s16,
                                    PantasSpace.s14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ceilingMessage,
                                          style: t.sm.copyWith(
                                            color: t.colors.wrongText,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: PantasSpace.s8),
                                      WebButton(
                                        label: 'Tick More Subjects',
                                        kind: PantasButtonKind.tertiary,
                                        tone: PantasButtonTone.accent,
                                        size: PantasButtonSize.sm,
                                        onPressed: onTickMoreSubjects,
                                      ),
                                    ],
                                  ),
                                ),
                              _WideNumberRow(
                                label: 'Time',
                                value: minutes,
                                display: _duration(minutes),
                                values: minuteValues,
                                editable: !breakdown,
                                divider: false,
                                onChanged: onMinutes,
                                format: _duration,
                                helper: '15 minutes to 6 hours, in fives. '
                                    'Arrow keys work too.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: PantasSpace.s24),
                        RowTapTarget(
                          onTap: () => onBreakdown(!breakdown),
                          child: WebCard(
                            radius: 16,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: PantasSpace.s16,
                                vertical: PantasSpace.s6,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'I know the section breakdown',
                                      style: rowStyle,
                                    ),
                                  ),
                                  PantasSwitch(
                                    value: breakdown,
                                    label: 'I know the section breakdown',
                                    onChanged: onBreakdown,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // The hint and the breakdown trade places over
                        // 300 ms, as the row editors do.
                        _breakdownReveal(
                          context,
                          _breakdownContent(t, rowStyle),
                        ),
                        const SizedBox(height: PantasSpace.s24),
                        if (unset) ...[
                          Text(
                            'Choose questions and minutes for every subject.',
                            style: t.sm,
                          ),
                          const SizedBox(height: PantasSpace.s8),
                        ],
                        if (failed) ...[
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              'Could not save. Please try again.',
                              style: t.sm,
                            ),
                          ),
                          const SizedBox(height: PantasSpace.s8),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: WebButton(
                            label: 'Save',
                            large: true,
                            keyHint: 'Enter',
                            onPressed: onSave,
                          ),
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
    );
  }
}

class _WideNumberRow extends StatefulWidget {
  const _WideNumberRow({
    required this.label,
    required this.value,
    required this.display,
    required this.values,
    required this.onChanged,
    required this.format,
    required this.helper,
    this.editable = true,
    this.refused = false,
    this.divider = true,
  });
  final String label;
  final int value;
  final String display;
  final List<int> values;
  final ValueChanged<int> onChanged;
  final String Function(int) format;
  final String helper;
  final bool editable;
  final bool refused;
  final bool divider;
  @override
  State<_WideNumberRow> createState() => _WideNumberRowState();
}

class _WideNumberRowState extends State<_WideNumberRow> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebRow(
          title: widget.label,
          value: widget.display,
          compact: true,
          horizontalPadding: 16,
          titleStyle: PantasType.webBody.copyWith(color: t.colors.textPrimary),
          divider: widget.divider,
          valueStyle: PantasType.webBody.copyWith(
            color:
                widget.refused ? t.colors.wrongText : t.colors.secondaryLabel,
          ),
          dimmed: !widget.editable && !widget.refused,
          onPressed:
              widget.editable ? () => setState(() => _open = !_open) : null,
        ),
        _editorReveal(
          context,
          _open && widget.editable
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    PantasSpace.s4,
                    PantasSpace.s16,
                    PantasSpace.s16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InlineStepper(
                        label: widget.label,
                        value: widget.value,
                        values: widget.values,
                        format: widget.format,
                        onChanged: widget.onChanged,
                      ),
                      const SizedBox(height: PantasSpace.s8),
                      Text(widget.helper, style: t.sm),
                    ],
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

/// The width of a section's items or minutes field (board width; the system
/// sets no token).
const _fieldWidth = 64.0;

class _WideSectionRow extends StatefulWidget {
  const _WideSectionRow({
    required this.name,
    required this.questions,
    required this.minutes,
    required this.over,
    required this.questionValues,
    required this.minuteValues,
    required this.onChanged,
  });
  final String name;
  final int? questions;
  final int? minutes;

  /// The items value passes what the subject holds.
  final bool over;
  final List<int> questionValues;
  final List<int> minuteValues;
  final void Function(int value, {required bool minutes}) onChanged;
  @override
  State<_WideSectionRow> createState() => _WideSectionRowState();
}

class _WideSectionRowState extends State<_WideSectionRow> {
  bool? _minutes;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    Widget field(int? value, {required bool minutes}) {
      // The bad field: a 1.5 px red edge drawn over the system button.
      final bad = widget.over && !minutes;
      return SizedBox(
        width: _fieldWidth,
        height: PantasSize.btnXs,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PantasRadius.sm),
            border:
                bad ? Border.all(color: t.colors.wrongText, width: 1.5) : null,
          ),
          child: WebButton(
            label: value == null ? 'Set' : '$value',
            kind: PantasButtonKind.white,
            size: PantasButtonSize.xs,
            expand: true,
            onPressed: () =>
                setState(() => _minutes = _minutes == minutes ? null : minutes),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: t.colors.separator, width: .5),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: PantasSpace.s16,
        vertical: PantasSpace.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.name,
                  style: PantasType.webBody.copyWith(
                    color: t.colors.textPrimary,
                  ),
                ),
              ),
              field(widget.questions, minutes: false),
              const SizedBox(width: PantasSpace.s8),
              Text('items', style: t.sm),
              const SizedBox(width: PantasSpace.s8),
              field(widget.minutes, minutes: true),
              const SizedBox(width: PantasSpace.s8),
              Text('min', style: t.sm),
            ],
          ),
          _editorReveal(
            context,
            _minutes == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: PantasSpace.s12),
                    child: _InlineStepper(
                      label:
                          '${widget.name} ${_minutes! ? 'minutes' : 'items'}',
                      value: _minutes! ? widget.minutes : widget.questions,
                      values: _minutes!
                          ? widget.minuteValues
                          : widget.questionValues,
                      format: (v) => '$v',
                      onChanged: (v) => widget.onChanged(v, minutes: _minutes!),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// The breakdown block growing in under its switch and shrinking away, over
/// the same 300 ms as the row editors. It grows from its top edge.
Widget _breakdownReveal(BuildContext context, Widget child) {
  if (MediaQuery.disableAnimationsOf(context)) return child;
  return AnimatedSize(
    duration: const Duration(milliseconds: 300),
    alignment: Alignment.topCenter,
    child: child,
  );
}

/// The phone's row editor: the row grows and shrinks over 300 ms. A null
/// [editor] is a closed row.
Widget _editorReveal(BuildContext context, Widget? editor) {
  final child = editor ?? const SizedBox(width: double.infinity);
  if (MediaQuery.disableAnimationsOf(context)) return child;
  return AnimatedSize(
    duration: const Duration(milliseconds: 300),
    child: child,
  );
}

/// CM_Wheel: five adjacent values and arrow keys, with no scrolling wheel.
class _InlineStepper extends StatefulWidget {
  const _InlineStepper({
    required this.label,
    required this.value,
    required this.values,
    required this.format,
    required this.onChanged,
  });
  final String label;
  final int? value;
  final List<int> values;
  final String Function(int) format;
  final ValueChanged<int> onChanged;
  @override
  State<_InlineStepper> createState() => _InlineStepperState();
}

class _InlineStepperState extends State<_InlineStepper> {
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final value = widget.value;
    final values = widget.values;
    final format = widget.format;
    final onChanged = widget.onChanged;
    final t = context.webTokens;
    final index = math.max(0, values.indexOf(value ?? values.first));
    final start = (index - 2).clamp(0, math.max(0, values.length - 5)).toInt();
    void move(int delta) =>
        onChanged(values[(index + delta).clamp(0, values.length - 1)]);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => move(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => move(1),
      },
      child: Focus(
        focusNode: _focus,
        child: Container(
          padding: const EdgeInsets.all(PantasSpace.s4),
          decoration: BoxDecoration(
            color: t.colors.background,
            borderRadius: BorderRadius.circular(PantasRadius.back),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PantasIconButton(
                tooltip: 'Decrease $label',
                size: PantasIconButtonSize.sm,
                glyph: PantasIcons.back,
                onPressed: index > 0 ? () => move(-1) : null,
              ),
              for (final v in values.skip(start).take(5))
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PantasSpace.s2,
                  ),
                  child: WebButton(
                    label: format(v),
                    kind: v == value
                        ? PantasButtonKind.primary
                        : PantasButtonKind.tertiary,
                    size: PantasButtonSize.xs,
                    onPressed: () => onChanged(v),
                  ),
                ),
              PantasIconButton(
                tooltip: 'Increase $label',
                size: PantasIconButtonSize.sm,
                glyph: PantasIcons.next,
                onPressed: index < values.length - 1 ? () => move(1) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the boards say under the breakdown while parts are timed apart.
const String customPartByPartRule =
    "This paper runs part by part. Once a part ends, you can't go back to it.";
