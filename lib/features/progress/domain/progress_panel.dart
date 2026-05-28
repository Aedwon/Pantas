enum ProgressPanelIntent {
  currentState,
  retrospective,
  achievement,
}

enum ProgressPanelContent {
  identity,
  analytical,
}

enum ProgressPanelAccess {
  full,
  teaser,
}

enum ProgressPanelWindow {
  rolling30d,
  prepWindow,
  allTime,
}

class ProgressPanel {
  const ProgressPanel({
    required this.id,
    required this.intent,
    required this.contentType,
    required this.window,
    this.access = ProgressPanelAccess.full,
  });

  final String id;
  final ProgressPanelIntent intent;
  final ProgressPanelContent contentType;
  final ProgressPanelWindow window;
  final ProgressPanelAccess access;

  ProgressPanel copyWith({ProgressPanelAccess? access}) {
    return ProgressPanel(
      id: id,
      intent: intent,
      contentType: contentType,
      window: window,
      access: access ?? this.access,
    );
  }
}
