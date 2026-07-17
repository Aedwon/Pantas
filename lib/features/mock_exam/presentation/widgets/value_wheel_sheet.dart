import 'dart:async';

import 'package:cse_cet_reviewer/core/ui/components/ink_sheet.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/corpus_ceiling.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ten to the ceiling, in fives. No published paper is 117 items long.
final questionValues = [
  for (var i = 10; i <= questionWheelCeiling; i += 5) i,
];

/// Fifteen minutes to six hours, in fives.
final minuteValues = [for (var i = 15; i <= 360; i += 5) i];

/// `2h 00m`. One column renders it, because two columns for a single
/// duration means two gestures to say "two hours".
String formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return '${hours}h ${rest.toString().padLeft(2, '0')}m';
}

/// A vertical wheel over an arbitrary list of values.
///
/// Deliberately not the quiz tab's `LengthWheel`. That one is horizontal,
/// sits in the picker's footer and takes its values from the practice unit
/// mode rather than from a caller. Passing a value list, a formatter and a
/// second column through it would be a parameter that lies about what it
/// is, so this is a second wheel and the plan sanctions saying so.
class ValueWheel extends StatefulWidget {
  const ValueWheel({
    required this.values,
    required this.value,
    required this.onChanged,
    this.format,
    super.key,
  });

  final List<int> values;
  final int value;
  final ValueChanged<int> onChanged;
  final String Function(int)? format;

  @override
  State<ValueWheel> createState() => _ValueWheelState();
}

class _ValueWheelState extends State<ValueWheel> {
  late FixedExtentScrollController _controller;

  static const double _itemExtent = 38;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: widget.values
          .indexOf(widget.value)
          .clamp(0, widget.values.length - 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // A tint marks the choice rather than a fourth kind of rule, the
          // same treatment the practice picker's wheel uses.
          Container(height: _itemExtent, color: colors.boardTint),
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: _itemExtent,
            perspective: 0.002,
            diameterRatio: 100,
            physics: const FixedExtentScrollPhysics(),
            // Whatever sits inside the band is the value: it commits on
            // scroll, not only on tap.
            onSelectedItemChanged: (index) {
              if (!reduceMotion) unawaited(HapticFeedback.selectionClick());
              widget.onChanged(widget.values[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.values.length,
              builder: (context, index) {
                final candidate = widget.values[index];
                final isSelected = candidate == widget.value;
                return Center(
                  child: Text(
                    widget.format?.call(candidate) ?? '$candidate',
                    style: isSelected
                        ? styles.displaySmall.copyWith(
                            fontFamily: 'SourceSerif4',
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          )
                        : styles.bodyMedium.copyWith(
                            fontSize: 19,
                            color: colors.inkMuted,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The sheet's title and its one board control.
class _WheelFrame extends StatelessWidget {
  const _WheelFrame(
      {required this.title, required this.onDone, required this.child});

  final String title;
  final VoidCallback onDone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: styles.bodyMedium.copyWith(
                  fontFamily: 'SourceSerif4',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            InkWell(
              onTap: onDone,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Text(
                  'Done',
                  style: styles.bodySmall.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colors.board,
                  ),
                ),
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}

Future<int?> showValueWheelSheet({
  required BuildContext context,
  required String title,
  required List<int> values,
  required int initial,
  String Function(int)? format,
}) {
  var chosen = initial;
  return showInkSheet<int>(
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (builderContext, setState) => _WheelFrame(
        title: title,
        onDone: () => Navigator.of(builderContext).pop(chosen),
        child: ValueWheel(
          values: values,
          value: chosen,
          format: format,
          onChanged: (value) => setState(() => chosen = value),
        ),
      ),
    ),
  );
}

/// Two columns, because questions and minutes are two different quantities
/// rather than one.
Future<(int, int)?> showTwoColumnWheelSheet({
  required BuildContext context,
  required String title,
  required int initialQuestions,
  required int initialMinutes,
}) {
  var questions = initialQuestions;
  var minutes = initialMinutes;

  return showInkSheet<(int, int)>(
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (builderContext, setState) {
        final styles = builderContext.textStyles;
        final colors = builderContext.colors;
        Widget label(String text) => Text(
              text,
              textAlign: TextAlign.center,
              style: styles.labelSmall.copyWith(color: colors.inkMuted),
            );

        return _WheelFrame(
          title: title,
          onDone: () => Navigator.of(builderContext).pop((questions, minutes)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    label('Questions'),
                    ValueWheel(
                      values: questionValues,
                      value: questions,
                      onChanged: (value) => setState(() => questions = value),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    label('Minutes'),
                    ValueWheel(
                      values: minuteValues,
                      value: minutes,
                      onChanged: (value) => setState(() => minutes = value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
