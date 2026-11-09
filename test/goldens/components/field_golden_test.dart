import 'package:pantas/core/ui/components/pantas_field.dart';

import '../golden_harness.dart';

PantasField _field({
  String? errorText,
  bool enabled = true,
  bool readOnly = false,
  String? helpText,
}) =>
    PantasField(
      label: 'Full name',
      hint: 'Maria Santos',
      helpText: helpText,
      errorText: errorText,
      enabled: enabled,
      readOnly: readOnly,
    );

void main() {
  goldenSheet(
    'field',
    [
      ...interactionStates(
        'Default',
        (_) => _field(),
        disabled: (_) => _field(enabled: false),
        width: 280,
      ),
      GoldenState(
        'Help text',
        (_) => _field(helpText: 'As on your ID.'),
        width: 280,
      ),
      GoldenState(
        'Invalid',
        (_) => _field(errorText: 'Enter your name.'),
        width: 280,
      ),
      GoldenState('Read only', (_) => _field(readOnly: true), width: 280),
    ],
    cellWidth: 280,
    columns: 4,
  );
}
