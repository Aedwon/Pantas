import 'package:pantas/core/ui/components/exam_name_line.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'exam_chip',
    [
      GoldenState(
        'With a date',
        (_) => const ExamChip(
          name: 'UPCAT',
          day: '14',
          month: 'Aug',
          daysLeft: '97 days',
        ),
        width: 320,
      ),
      GoldenState(
        'No exam date',
        (_) => ExamChip.empty(
          trailing: WebTextLink(label: 'Add Date', onPressed: () {}),
        ),
        width: 320,
      ),
      GoldenState(
        'Add Date focus',
        (_) => ExamChip.empty(
          trailing: WebTextLink(label: 'Add Date', onPressed: () {}),
        ),
        action: GoldenAction.focus,
        width: 320,
      ),
    ],
    cellWidth: 320,
    web: true,
  );
}
