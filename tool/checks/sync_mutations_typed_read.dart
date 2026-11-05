// No typed drift read or watch on syncLocalMutations.
//
// The recorder stores times as raw integers, which the table's typed read
// cannot map, so a typed read or watch fails on the first real row. Read it
// with customSelect, as production_sync_runtime_engine.dart does.
import 'check.dart';

final _typedRead = RegExp(
  r'\b(?:select|selectOnly|innerJoin|leftOuterJoin|crossJoin)\(\s*[\w.]*\bsyncLocalMutations\b'
  r'|\bsyncLocalMutations\s*\.\s*(?:select|selectOnly|all|map|mapFromRow|mapFromRowOrNull|count)\b'
  r'|\bmanagers\s*\.\s*syncLocalMutations\b',
);

class SyncMutationsTypedReadCheck extends Check {
  const SyncMutationsTypedReadCheck();

  @override
  String get name => 'sync-mutations-typed-read';

  @override
  String get origin =>
      'Nov 2026 web sync: a typed watch on sync_local_mutations failed on the '
      'first real row, because its times are raw integers';

  @override
  List<Violation> run(String root) => [
        for (final entry in libSources(root).entries)
          ...findTypedReads(entry.key, entry.value),
      ];
}

List<Violation> findTypedReads(String path, String source) {
  final code = withoutLineComments(source);
  return [
    for (final match in _typedRead.allMatches(code))
      Violation(
        '$path:${lineAt(code, match.start)}',
        'typed read of syncLocalMutations. Times there are raw integers: '
            'use customSelect.',
      ),
  ];
}
