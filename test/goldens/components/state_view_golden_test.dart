import 'package:pantas/core/ui/components/state_view.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'state_view',
    [
      const GoldenState(
        'Empty',
        _empty,
        width: 340,
      ),
      GoldenState(
        'Error, Try Again',
        (_) => StateView(
          message: 'Something went wrong.',
          detail: 'Check your connection.',
          onRetry: () {},
        ),
        width: 340,
      ),
    ],
    cellWidth: 340,
    columns: 2,
  );
}

StateView _empty(_) => const StateView(
      message: 'No lessons yet.',
      detail: 'Pick a topic to begin.',
    );
