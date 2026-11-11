import 'package:pantas/core/ui/components/avatar.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'avatar',
    [
      const GoldenState('Initial, phone', _initial),
      GoldenState(
        'Initial, small',
        (_) => const Avatar(name: 'Maria', size: Avatar.small),
      ),
      GoldenState('No name', (_) => const Avatar()),
    ],
    cellWidth: 100,
  );
}

Avatar _initial(_) => const Avatar(name: 'Maria');
