/// How today's session is built out of topics.
///
/// The stored values keep the Quiz spec's vocabulary so anyone reading the
/// database recognizes them. The labels are the student's, and only two of
/// the three were plainened: "Interleaved tail" keeps its name because it is
/// the badged default, "interleaved" is the real learning-science word, and
/// the badge is making an authority claim that a plain phrase would not carry.
enum SessionOrdering {
  blocked,
  interleavedTail,
  fullyMixed;

  String get storageValue => name;

  String get label => switch (this) {
        SessionOrdering.blocked => 'One topic only',
        SessionOrdering.interleavedTail => 'Interleaved tail',
        SessionOrdering.fullyMixed => 'All mixed up',
      };

  String get reason => switch (this) {
        SessionOrdering.blocked => 'All 10 questions from your topic.',
        SessionOrdering.interleavedTail =>
          '7 from your topic, 3 from others. Harder now, easier on exam day.',
        SessionOrdering.fullyMixed => 'No two in a row from the same topic.',
      };

  bool get isRecommended => this == SessionOrdering.interleavedTail;

  static SessionOrdering fromStorage(String? value) {
    return SessionOrdering.values.firstWhere(
      (ordering) => ordering.storageValue == value,
      orElse: () => SessionOrdering.interleavedTail,
    );
  }
}
