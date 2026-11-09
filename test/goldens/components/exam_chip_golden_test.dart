import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/exam_name_line.dart';

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
        (_) => const ExamChip.empty(trailing: Text('Add your exam date')),
        width: 320,
      ),
    ],
    cellWidth: 320,
    columns: 2,
  );
}
