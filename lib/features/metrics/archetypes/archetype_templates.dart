import 'package:cse_cet_reviewer/features/metrics/archetypes/archetype.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_key.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';

class ArchetypeTemplates {
  const ArchetypeTemplates();

  String synthesize(
    ArchetypeResult archetype,
    Map<SignalKey, Object> signals,
  ) {
    if (archetype.id == 'game_day_player') {
      final x1 = signals[SignalKey.testModeDelta];
      if (x1 is PressureDelta) {
        final pts = (x1.delta * 100).abs().round();
        return 'You lift in mock mode, running $pts pts above practice.';
      }
    }
    return '${archetype.label}: your prep pattern is consistent enough '
        'to name.';
  }
}
