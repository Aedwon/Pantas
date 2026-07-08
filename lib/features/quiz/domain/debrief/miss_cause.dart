/// Why a miss happened, as far as stored data can say.
///
/// Three, not five. Four of the five causes the debrief could name need no
/// question at all; the fifth, misreading, is invisible to every signal the
/// app has, and it is the only thing the tagging in Section 4 buys.
sealed class MissCause {
  const MissCause();
}

/// Answered far faster than this student usually answers in this topic.
class RushedCause extends MissCause {
  const RushedCause({
    required this.responseSeconds,
    required this.usualSeconds,
    required this.topicName,
  });

  final int responseSeconds;
  final int usualSeconds;
  final String topicName;

  /// "You answered in 4 seconds. You usually take 21 on Chemistry."
  String get line => 'You answered in $responseSeconds seconds. '
      'You usually take $usualSeconds on $topicName.';
}

/// Right before, wrong now.
class SlippedCause extends MissCause {
  const SlippedCause(this.lastCorrectAt);

  final DateTime lastCorrectAt;

  /// The spec's example continues "Today you multiplied where you needed to
  /// divide", which is a claim about this particular mistake. Nothing in the
  /// app knows that: it is the per-choice rationale, and that content pass has
  /// not run. Only the stored fact is stated here.
  String line(String day) => 'You had this right on $day.';
}

/// Never seen before.
class NewCause extends MissCause {
  const NewCause();

  String get line => "It's the first time you've seen this one.";
}

/// How much faster than usual counts as rushed.
///
/// Half the topic's own average, so it scales with the student rather than
/// against a constant somebody picked.
const rushedFraction = 0.5;

/// Below this many answers there is no usual pace to be faster than.
const rushedMinimumAnswers = 5;
