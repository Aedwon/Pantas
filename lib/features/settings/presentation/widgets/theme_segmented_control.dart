import 'package:cse_cet_reviewer/features/settings/domain/theme_preference.dart';
import 'package:flutter/material.dart';

class ThemeSegmentedControl extends StatelessWidget {
  const ThemeSegmentedControl({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ThemePreference value;
  final ValueChanged<ThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemePreference>(
      segments: const [
        ButtonSegment(value: ThemePreference.light, label: Text('Light')),
        ButtonSegment(value: ThemePreference.dark, label: Text('Dark')),
        ButtonSegment(value: ThemePreference.system, label: Text('System')),
      ],
      selected: {value},
      onSelectionChanged: (selected) => onChanged(selected.single),
    );
  }
}
