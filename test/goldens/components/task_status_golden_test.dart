import 'package:pantas/core/ui/components/task_status.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'task_status',
    [
      for (final phone in [false, true])
        for (final state in TaskState.values)
          GoldenState(
            '${phone ? 'Phone' : 'Wide'} ${state.name}',
            (_) => TaskStatus(state: state, phone: phone, animate: false),
          ),
    ],
    cellWidth: 80,
    columns: 4,
  );
}
