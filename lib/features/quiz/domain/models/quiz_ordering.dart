/// How today's session is built. Exposed in Settings as three choices, with
/// the default carrying a recommended marker.
enum QuizOrdering {
  /// Every question from the chosen topic.
  blocked('blocked'),

  /// Seven from the topic, three drawn from other topics' due cards.
  interleavedTail('interleaved_tail'),

  /// No two consecutive questions from the same topic.
  fullyMixed('fully_mixed');

  const QuizOrdering(this.storageValue);

  final String storageValue;

  static const defaultOrdering = QuizOrdering.interleavedTail;

  bool get isRecommended => this == defaultOrdering;

  /// Reads the `quiz_today_interleaved` account preference. The key predates
  /// this enum and shipped holding `'true'` or `'false'`, so both are still
  /// understood rather than silently reset.
  static QuizOrdering fromStorage(String? raw) {
    switch (raw) {
      case 'true':
        return QuizOrdering.interleavedTail;
      case 'false':
        return QuizOrdering.blocked;
    }
    for (final ordering in QuizOrdering.values) {
      if (ordering.storageValue == raw) return ordering;
    }
    return defaultOrdering;
  }
}
