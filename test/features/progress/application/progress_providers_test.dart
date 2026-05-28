import 'dart:io';

import 'package:cse_cet_reviewer/features/progress/application/progress_providers.dart';
import 'package:cse_cet_reviewer/features/progress/domain/progress_panel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('progress panels use metrics-spec windows by panel intent', () {
    expect(
      progressPanelCatalog
          .where((panel) => panel.intent == ProgressPanelIntent.currentState)
          .map((panel) => panel.window)
          .toSet(),
      {ProgressPanelWindow.rolling30d},
    );
    expect(
      progressPanelCatalog
          .where((panel) => panel.intent == ProgressPanelIntent.retrospective)
          .map((panel) => panel.window)
          .toSet(),
      {ProgressPanelWindow.prepWindow},
    );
    expect(
      progressPanelCatalog
          .where((panel) => panel.intent == ProgressPanelIntent.achievement)
          .map((panel) => panel.window)
          .toSet(),
      {ProgressPanelWindow.allTime},
    );
  });

  test('free users get identity content and teaser analytical panels', () {
    final visible = progressPanelsForEntitlement(proIsActive: false);

    expect(
      visible
          .where((panel) => panel.contentType == ProgressPanelContent.identity)
          .every((panel) => panel.access == ProgressPanelAccess.full),
      isTrue,
    );
    expect(
      visible
          .where(
            (panel) => panel.contentType == ProgressPanelContent.analytical,
          )
          .every((panel) => panel.access == ProgressPanelAccess.teaser),
      isTrue,
    );
  });

  test('progress feature does not define a progress cache', () {
    final files = Directory('lib/features/progress')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    final source = files.map((file) => file.readAsStringSync()).join('\n');

    expect(source, isNot(contains('progress_cache')));
  });
}
