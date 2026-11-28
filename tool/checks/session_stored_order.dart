// A quiz session is stored in the order the student sees it.
//
// Nov 22 2026 audit: QuizSession.start groups a passage's questions together,
// but Retake, Today, Drill, the in-lesson quiz and Restart stored the order
// from before grouping. When another question split a passage, the second
// passage question failed its save ("Could not save your progress"), because
// the stored order no longer matched the screen. Store `session.questions`.
import 'check.dart';

// A session-repository create call whose questionIds are not the built
// session's own questions.
final _unsafeCreate = RegExp(
  r'\b_?sessions\??\.create(?:Guarded)?\([^;]*?questionIds:(?!\s*session\.questions\.)',
);

class SessionStoredOrderCheck extends Check {
  const SessionStoredOrderCheck();

  @override
  String get name => 'session-stored-order';

  @override
  String get origin =>
      'Nov 22 2026 audit: sessions stored their order from before passage '
      'grouping, so a split passage failed its second save';

  @override
  List<Violation> run(String root) => [
        for (final entry in libSources(root).entries)
          ...findUnsafeSessionCreates(entry.key, entry.value),
      ];
}

List<Violation> findUnsafeSessionCreates(String path, String source) {
  final code = withoutLineComments(source);
  return [
    for (final match in _unsafeCreate.allMatches(code))
      Violation(
        '$path:${lineAt(code, match.start)}',
        'stores questionIds that are not session.questions. Build the '
            'QuizSession first and store its grouped order.',
      ),
  ];
}
