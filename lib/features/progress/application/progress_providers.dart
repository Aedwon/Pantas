import 'package:cse_cet_reviewer/features/progress/domain/progress_panel.dart';

const progressPanelCatalog = [
  ProgressPanel(
    id: 'archetype',
    intent: ProgressPanelIntent.currentState,
    contentType: ProgressPanelContent.identity,
    window: ProgressPanelWindow.rolling30d,
  ),
  ProgressPanel(
    id: 'signal_stats',
    intent: ProgressPanelIntent.currentState,
    contentType: ProgressPanelContent.identity,
    window: ProgressPanelWindow.rolling30d,
  ),
  ProgressPanel(
    id: 'trend_lines',
    intent: ProgressPanelIntent.retrospective,
    contentType: ProgressPanelContent.analytical,
    window: ProgressPanelWindow.prepWindow,
  ),
  ProgressPanel(
    id: 'weakness_narrative',
    intent: ProgressPanelIntent.retrospective,
    contentType: ProgressPanelContent.analytical,
    window: ProgressPanelWindow.prepWindow,
  ),
  ProgressPanel(
    id: 'best_mock',
    intent: ProgressPanelIntent.achievement,
    contentType: ProgressPanelContent.analytical,
    window: ProgressPanelWindow.allTime,
  ),
  ProgressPanel(
    id: 'wrapped_history_stub',
    intent: ProgressPanelIntent.achievement,
    contentType: ProgressPanelContent.identity,
    window: ProgressPanelWindow.allTime,
  ),
];

List<ProgressPanel> progressPanelsForEntitlement({required bool proIsActive}) {
  return [
    for (final panel in progressPanelCatalog)
      if (panel.contentType == ProgressPanelContent.analytical && !proIsActive)
        panel.copyWith(access: ProgressPanelAccess.teaser)
      else
        panel,
  ];
}
