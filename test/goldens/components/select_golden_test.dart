import 'package:pantas/core/ui/components/pantas_select.dart';

import '../golden_harness.dart';

const _options = [
  PantasSelectOption(1, 'UPCAT'),
  PantasSelectOption(2, 'ACET'),
  PantasSelectOption(3, 'DCAT'),
];

PantasSelect<int> _select({
  int? value,
  String? placeholder,
  String? errorText,
  bool enabled = true,
  bool large = false,
}) =>
    PantasSelect<int>(
      label: 'Exam',
      options: _options,
      value: value,
      placeholder: placeholder,
      errorText: errorText,
      enabled: enabled,
      large: large,
      onChanged: (_) {},
    );

void main() {
  goldenSheet(
    'select',
    [
      ...interactionStates(
        'Value',
        (_) => _select(value: 1),
        disabled: (_) => _select(value: 1, enabled: false),
        width: 280,
      ),
      GoldenState(
        'Placeholder',
        (_) => _select(placeholder: 'Choose an exam'),
        width: 280,
      ),
      GoldenState(
        'Invalid',
        (_) => _select(value: 1, errorText: 'Choose your exam.'),
        width: 280,
      ),
      GoldenState('Large', (_) => _select(value: 1, large: true), width: 280),
    ],
    cellWidth: 280,
  );
}
