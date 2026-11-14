import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/score_breakdown_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';

import '../golden_harness.dart';

Widget _card(List<Widget> rows) => Builder(
      builder: (context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(PantasRadius.xl),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: rows),
        ),
      ),
    );

void main() {
  goldenSheet(
    'stat_row',
    [
      GoldenState(
        'Rows',
        (_) => _card(const [
          ScoreBreakdownRow(
            name: 'Mathematics',
            correct: 18,
            total: 24,
            divider: true,
          ),
          ScoreBreakdownRow(
            name: 'Science',
            correct: 9,
            total: 20,
            divider: true,
          ),
          ScoreBreakdownRow(
            name: 'Language Proficiency',
            correct: 4,
            total: 5,
            divider: false,
          ),
        ]),
        width: 380,
      ),
      GoldenState(
        'Empty row',
        (_) => _card(const [
          ScoreBreakdownRow.value(
            name: 'Reading Comprehension',
            accuracy: null,
            divider: false,
          ),
        ]),
        width: 380,
      ),
      GoldenState(
        'Link row',
        (_) => _card(const [
          ScoreBreakdownRow.value(
            name: 'Algebra',
            subtitle: '6 topics',
            accuracy: 0.72,
            chevron: true,
            divider: false,
          ),
        ]),
        width: 380,
      ),
    ],
    cellWidth: 380,
    columns: 2,
    web: true,
  );
}
