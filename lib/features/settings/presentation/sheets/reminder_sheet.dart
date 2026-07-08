import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_sheet.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_wheel.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/settings/domain/user_settings.dart';
import 'package:flutter/material.dart';

const List<int> _hours12 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
const List<int> _minutes5 = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
const List<String> _amPmValues = ['AM', 'PM'];

Future<SettingsTime?> showReminderSheet({
  required BuildContext context,
  required SettingsTime? current,
}) {
  return showInkSheet<SettingsTime>(
    context: context,
    builder: (sheetContext) {
      return _ReminderSheetBody(current: current);
    },
  );
}

class _ReminderSheetBody extends StatefulWidget {
  const _ReminderSheetBody({required this.current});

  final SettingsTime? current;

  @override
  State<_ReminderSheetBody> createState() => _ReminderSheetBodyState();
}

class _ReminderSheetBodyState extends State<_ReminderSheetBody> {
  late int _hourIndex;
  late int _minuteIndex;
  late int _amPmIndex;

  @override
  void initState() {
    super.initState();
    final current = widget.current ?? const SettingsTime(hour: 20, minute: 0);

    final isPm = current.hour >= 12;
    var h12 = current.hour % 12;
    if (h12 == 0) h12 = 12;

    _hourIndex = _hours12.indexOf(h12).clamp(0, _hours12.length - 1);
    final minStep = (current.minute / 5).round() * 5;
    final minIdx = _minutes5.indexOf(minStep);
    _minuteIndex = minIdx >= 0 ? minIdx : 0;
    _amPmIndex = isPm ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily reminder',
          style: styles.headlineSmall.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: InkWheel.itemHeight * InkWheel.visibleItems,
          child: Stack(
            children: [
              const InkWheelBand(),
              Row(
                children: [
                  Expanded(
                    child: InkWheel<int>(
                      values: _hours12,
                      selectedIndex: _hourIndex,
                      onSelected: (index) {
                        setState(() => _hourIndex = index);
                      },
                      labelBuilder: (h) => '$h',
                    ),
                  ),
                  Expanded(
                    child: InkWheel<int>(
                      values: _minutes5,
                      selectedIndex: _minuteIndex,
                      onSelected: (index) {
                        setState(() => _minuteIndex = index);
                      },
                      labelBuilder: (m) => m.toString().padLeft(2, '0'),
                    ),
                  ),
                  Expanded(
                    child: InkWheel<String>(
                      values: _amPmValues,
                      selectedIndex: _amPmIndex,
                      onSelected: (index) {
                        setState(() => _amPmIndex = index);
                      },
                      labelBuilder: (ap) => ap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BoardButton(
          label: 'Save',
          onPressed: () {
            final h12 = _hours12[_hourIndex];
            final minute = _minutes5[_minuteIndex];
            final isPm = _amPmIndex == 1;

            int hour24;
            if (isPm) {
              hour24 = h12 == 12 ? 12 : h12 + 12;
            } else {
              hour24 = h12 == 12 ? 0 : h12;
            }

            Navigator.of(context).pop(
              SettingsTime(hour: hour24, minute: minute),
            );
          },
        ),
      ],
    );
  }
}
