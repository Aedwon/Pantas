import 'package:pantas/features/metrics/archetypes/archetype.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/domain/signal_key.dart';

/// D-80 identity copy. Retired and unknown identities have no claim.
String archetypeIdentityLine(String id) => switch (id) {
      'game_day_player' => "Exam-day pressure doesn't shake you.",
      'deep_thinker' => 'You take your sweet time, and it shows.',
      'night_owl_sprinter' => 'Late nights are when you shine.',
      'early_bird_marathoner' => 'Mornings fire you up and get you going.',
      'numbers_person' => 'Numbers bend to your will.',
      'wordsmith' => 'Words just make sense to you.',
      'generalist' => "Give you any subject and you'll handle it.",
      'scholar' => 'You learn it fully before you put it to work.',
      'long_memory' => 'What you learn stays with you.',
      'bookmark_strategist' => 'You never leave a question unchecked.',
      'time_master' => 'The clock works for you, not against you.',
      'closer' => 'You save your best for last.',
      _ => '',
    };

class ArchetypeTemplates {
  const ArchetypeTemplates();

  String synthesize(ArchetypeResult archetype, Map<SignalKey, Object> signals) {
    final matches = archetypeCatalog.where((a) => a.id == archetype.id);
    if (matches.isEmpty ||
        !signals.keys.toSet().containsAll(matches.first.requiredSignals)) {
      return '';
    }
    return archetypeIdentityLine(archetype.id);
  }
}
