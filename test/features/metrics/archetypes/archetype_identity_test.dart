import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

void main() {
  test('Deep Thinker requires measured slow answers and a correct majority',
      () {
    final thinker = archetypeCatalog.singleWhere((a) => a.id == 'deep_thinker');
    double score(double ms, int right, int wrong) => thinker.match({
          SignalKey.perQuestionSpeed: LatencyDistribution(
            averageMs: ms,
            correctAverageMs: ms,
            incorrectAverageMs: ms,
            sampleCount: right + wrong,
            correctCount: right,
            incorrectCount: wrong,
          ),
        });
    expect(score(12000, 8, 2), 0);
    expect(score(12001, 8, 2), greaterThan(0));
    expect(score(20000, 2, 8), 0);
    expect(score(20000, 5, 5), 0);
    expect(score(20000, 0, 0), 0);
    expect(archetypeCatalog.any((a) => a.id == 'pressure_tightener'), false);
  });

  test('approved identity labels preserve original signal rules and IDs', () {
    const expected = {
      'deep_thinker': 'Deep Thinker',
      'night_owl_sprinter': 'Night Owl',
      'early_bird_marathoner': 'Early Bird',
      'game_day_player': 'Levelheaded',
      'bookmark_strategist': 'Thorough Reviewer',
      'time_master': 'Time Master',
      'closer': 'Closer',
      'wordsmith': 'Wordsmith',
      'numbers_person': 'Math Wizard',
      'generalist': 'All-Rounder',
      'scholar': 'Scholar',
      'long_memory': 'Strong Recall',
    };
    for (final item in expected.entries) {
      expect(
        archetypeCatalog.singleWhere((a) => a.id == item.key).label,
        item.value,
      );
      expect(archetypeIdentityLine(item.key), isNotEmpty);
      expect(
        RegExp('[0-9]').hasMatch(archetypeIdentityLine(item.key)),
        isFalse,
      );
    }
    expect(archetypeIdentityLine('pressure_tightener'), isEmpty);
  });
}
