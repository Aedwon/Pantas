import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Desktop presentation only. The page owns the draft and validates Save.
class WebCustomMockSetup extends StatelessWidget {
  const WebCustomMockSetup({
    required this.questions,
    required this.minutes,
    required this.available,
    required this.fits,
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
  final bool fits;
  final bool breakdown;
  final bool timedSeparately;
  final bool unset;
  final List<({String id, String name, int? questions, int? minutes})> sections;
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
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final rowStyle = t.style(16);
    final questionHint = '${questionValues.first} to ${questionValues.last}, '
        'in fives. Arrow keys work too.';
    final ceilingMessage = 'Your subjects have $available questions. '
        'A $questions-question mock needs more.';
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () => onSave?.call(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: t.colors.background,
          body: SingleChildScrollView(
            key: const ValueKey('web-custom-setup'),
            padding: const EdgeInsets.fromLTRB(44, 28, 44, 40),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: onBack,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 40),
                        foregroundColor: t.colors.accent,
                        textStyle: t.style(17),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chevron_left, size: 20),
                          Text('Quiz'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Set up your mock', style: t.h1),
                    const SizedBox(height: 6),
                    Text(
                      "We'll build it from what you tell us.",
                      style: t.style(
                        17,
                        height: 1.45,
                        color: t.colors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 28),
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
                                  refused: !fits,
                                  onChanged: onQuestions,
                                  format: (v) => '$v',
                                  helper: questionHint,
                                ),
                                if (!fits)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      14,
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
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: onTickMoreSubjects,
                                          style: TextButton.styleFrom(
                                            foregroundColor: t.colors.accent,
                                            textStyle: t.style(
                                              15,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                          child:
                                              const Text('Tick More Subjects'),
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
                          const SizedBox(height: 24),
                          WebCard(
                            radius: 16,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
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
                          if (!breakdown)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Text(
                                "You'll be timed, so exam day feels familiar.",
                                style: t.sm,
                              ),
                            ),
                          if (breakdown) ...[
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                                      questionValues: questionValues,
                                      minuteValues: minuteValues,
                                      onChanged: (value, {required minutes}) =>
                                          onSection(
                                        section.id,
                                        value,
                                        minutes: minutes,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
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
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Text(
                                'The totals above now add these up.',
                                style: t.sm,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (unset) ...[
                            Text(
                              'Choose questions and minutes for every subject.',
                              style: t.sm,
                            ),
                            const SizedBox(height: 8),
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
          titleStyle: t.style(16),
          divider: widget.divider,
          valueStyle: t.style(
            16,
            color:
                widget.refused ? t.colors.wrongText : t.colors.secondaryLabel,
          ),
          dimmed: !widget.editable,
          onPressed:
              widget.editable ? () => setState(() => _open = !_open) : null,
        ),
        if (_open && widget.editable)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
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
                const SizedBox(height: 8),
                Text(widget.helper, style: t.sm),
              ],
            ),
          ),
      ],
    );
  }
}

class _WideSectionRow extends StatefulWidget {
  const _WideSectionRow({
    required this.name,
    required this.questions,
    required this.minutes,
    required this.questionValues,
    required this.minuteValues,
    required this.onChanged,
  });
  final String name;
  final int? questions;
  final int? minutes;
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
    Widget field(int? value, {required bool minutes}) => SizedBox(
          width: 64,
          height: 36,
          child: OutlinedButton(
            onPressed: () =>
                setState(() => _minutes = _minutes == minutes ? null : minutes),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              side: BorderSide(color: t.colors.separator),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(value == null ? 'Set' : '$value', style: t.style(16)),
          ),
        );
    return Container(
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: t.colors.separator, width: .5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(widget.name, style: t.style(16))),
              field(widget.questions, minutes: false),
              const SizedBox(width: 8),
              Text('items', style: t.sm),
              const SizedBox(width: 8),
              field(widget.minutes, minutes: true),
              const SizedBox(width: 8),
              Text('min', style: t.sm),
            ],
          ),
          if (_minutes != null) ...[
            const SizedBox(height: 12),
            _InlineStepper(
              label: '${widget.name} ${_minutes! ? 'minutes' : 'items'}',
              value: _minutes! ? widget.minutes : widget.questions,
              values: _minutes! ? widget.minuteValues : widget.questionValues,
              format: (v) => '$v',
              onChanged: (v) => widget.onChanged(v, minutes: _minutes!),
            ),
          ],
        ],
      ),
    );
  }
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
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: t.colors.background,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Decrease $label',
                visualDensity: VisualDensity.standard,
                constraints:
                    const BoxConstraints.tightFor(width: 32, height: 32),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: index > 0 ? () => move(-1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              for (final v in values.skip(start).take(5))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TextButton(
                    onPressed: () => onChanged(v),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(54, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      backgroundColor:
                          v == value ? t.colors.accentFill : Colors.transparent,
                      foregroundColor:
                          v == value ? Colors.white : t.colors.secondaryLabel,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      textStyle: t.style(16, weight: FontWeight.w600),
                    ),
                    child: Text(format(v)),
                  ),
                ),
              IconButton(
                tooltip: 'Increase $label',
                visualDensity: VisualDensity.standard,
                constraints:
                    const BoxConstraints.tightFor(width: 32, height: 32),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: index < values.length - 1 ? () => move(1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
