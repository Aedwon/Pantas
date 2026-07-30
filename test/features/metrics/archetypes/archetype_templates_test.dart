import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/metrics/archetypes/archetype.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

void main() {
  test('synthesis copy is deterministic for the same archetype and signals',
      () {
    const result = ArchetypeResult(
      id: 'game_day_player',
      label: 'Game-Day Player',
      category: ArchetypeCategory.pressureMode,
      matchScore: 0.8,
    );
    const signals = {
      SignalKey.testModeDelta: PressureDelta(
        practiceAccuracy: 0.75,
        mockAccuracy: 0.85,
      ),
    };

    final first = const ArchetypeTemplates().synthesize(result, signals);
    final second = const ArchetypeTemplates().synthesize(result, signals);

    expect(first, second);
    expect(first, contains('mock mode'));
    expect(first, contains('10 pts'));
  });
}
