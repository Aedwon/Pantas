import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

void main() {
  test('Deep Thinker requires slow overall and slower correct answers', () {
    final thinker = archetypeCatalog.singleWhere((a) => a.id == 'deep_thinker');
    double score(double ms, double correct, double incorrect,
            {int right = 2, int wrong = 8}) =>
        thinker.match({
          SignalKey.perQuestionSpeed: LatencyDistribution(
              averageMs: ms,
              correctAverageMs: correct,
              incorrectAverageMs: incorrect,
              sampleCount: right + wrong,
              correctCount: right,
              incorrectCount: wrong),
        });
    expect(score(12000, 16000, 11000), 0);
    expect(score(12001, 16000, 11000), greaterThan(0));
    expect(score(20000, 15000, 15000, right: 8, wrong: 2), 0);
    expect(score(20000, 14000, 16000, right: 8, wrong: 2), 0);
    expect(score(20000, 16000, 14000, right: 0, wrong: 0), 0);
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
      'long_memory': 'Strong Recall'
    };
    for (final item in expected.entries) {
      expect(archetypeCatalog.singleWhere((a) => a.id == item.key).label,
          item.value);
      expect(archetypeIdentityLine(item.key), isNotEmpty);
      expect(
          RegExp(r'[0-9]').hasMatch(archetypeIdentityLine(item.key)), isFalse);
    }
    expect(archetypeIdentityLine('pressure_tightener'), isEmpty);
  });
}
