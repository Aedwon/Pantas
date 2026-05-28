import 'package:cse_cet_reviewer/features/progress/domain/progress_panel.dart';
import 'package:flutter/material.dart';

class PaywallTeaserPanel extends StatelessWidget {
  const PaywallTeaserPanel({required this.panel, super.key});

  final ProgressPanel panel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(_title(panel.id)),
        subtitle: const Text('Unlock Pro to see the full analysis.'),
        trailing: const Icon(Icons.lock_outline),
      ),
    );
  }

  String _title(String id) {
    return switch (id) {
      'trend_lines' => 'Trend lines',
      'weakness_narrative' => 'Weakness narrative',
      'best_mock' => 'Best mock',
      _ => 'Pro analysis',
    };
  }
}
