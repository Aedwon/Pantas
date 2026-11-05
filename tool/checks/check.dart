// The shape of a verification check. See docs/workflow/process-improvement.md.
//
// A check exists because a real failure reached Aedwon or nearly did. It must
// fail on the bad version and pass on the good one, and it names the failure
// it came from, so a reader can tell whether it may ever be removed.
import 'dart:io';

/// One thing a check found.
class Violation {
  const Violation(this.where, this.message, {this.acceptedBecause});

  /// `path:line`, or an id for content.
  final String where;
  final String message;

  /// When set, this finding is known and does not fail the run. Say why.
  final String? acceptedBecause;

  @override
  String toString() => '$where: $message';
}

abstract class Check {
  const Check();

  String get name;

  /// The failure this check came from.
  String get origin;

  /// Findings for the project at [root].
  List<Violation> run(String root);
}

/// Project-relative path to source for hand-written Dart under `lib/`.
Map<String, String> libSources(String root) {
  final sources = <String, String>{};
  final lib = Directory('$root/lib');
  for (final entity in lib.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.substring(root.length + 1).replaceAll(r'\', '/');
    if (RegExp(r'\.(g|freezed|config)\.dart$').hasMatch(path)) continue;
    if (path.startsWith('lib/l10n/')) continue;
    sources[path] = entity.readAsStringSync();
  }
  return sources;
}

/// Blanks whole-line comments, keeping every offset and line number.
String withoutLineComments(String source) => source.replaceAllMapped(
      RegExp(r'^[ \t]*//.*$', multiLine: true),
      (match) => ' ' * match.group(0)!.length,
    );

int lineAt(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;
