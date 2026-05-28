import 'package:cse_cet_reviewer/features/progress/application/progress_providers.dart';
import 'package:cse_cet_reviewer/features/progress/domain/progress_panel.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/paywall_teaser_panel.dart';
import 'package:flutter/material.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({required this.proIsActive, super.key});

  final bool proIsActive;

  @override
  Widget build(BuildContext context) {
    final panels = progressPanelsForEntitlement(
      proIsActive: proIsActive,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final panel in panels) _ProgressPanelTile(panel: panel),
        ],
      ),
    );
  }
}

class _ProgressPanelTile extends StatelessWidget {
  const _ProgressPanelTile({required this.panel});

  final ProgressPanel panel;

  @override
  Widget build(BuildContext context) {
    if (panel.access == ProgressPanelAccess.teaser) {
      return PaywallTeaserPanel(panel: panel);
    }
    return Card(
      child: ListTile(
        title: Text(_title(panel.id)),
        subtitle: Text(_subtitle(panel)),
      ),
    );
  }

  String _title(String id) {
    return switch (id) {
      'archetype' => 'Personality fingerprint',
      'signal_stats' => 'Current study signals',
      'trend_lines' => 'Trend lines',
      'weakness_narrative' => 'Weakness narrative',
      'best_mock' => 'Best mock',
      'wrapped_history_stub' => 'Wrapped history',
      _ => id,
    };
  }

  String _subtitle(ProgressPanel panel) {
    return switch (panel.contentType) {
      ProgressPanelContent.identity => 'Included in Free.',
      ProgressPanelContent.analytical => 'Pro analytical panel.',
    };
  }
}
