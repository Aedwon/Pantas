import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';

import '../golden_harness.dart';

Widget _sheet({String? closeLabel = 'Close'}) => ProviderScope(
      child: PantasSheet(
        page: const SizedBox.expand(),
        open: true,
        label: 'Exam',
        closeLabel: closeLabel,
        onDismiss: () {},
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Choose an exam'),
              for (final name in ['UPCAT', 'ACET', 'DCAT'])
                ListRow(title: name, onTap: () {}),
            ],
          ),
        ),
      ),
    );

void main() {
  goldenSheet(
    'sheet',
    [
      GoldenState(
        'Phone',
        (_) => _sheet(),
        web: false,
        window: const Size(390, 560),
      ),
      GoldenState(
        'Phone without close',
        (_) => _sheet(closeLabel: null),
        web: false,
        window: const Size(390, 560),
      ),
      GoldenState(
        'Phone close focus',
        (_) => _sheet(),
        web: false,
        action: GoldenAction.focus,
        window: const Size(390, 560),
      ),
      GoldenState('Wide', (_) => _sheet(), window: const Size(1100, 560)),
    ],
    columns: 2,
    web: true,
  );
}
