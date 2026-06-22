// Enforces the project rule: no AI attribution anywhere in this repository,
// in a tracked file or in a commit message.
//
// Two tiers, because the rule is about attribution and not about a word.
//
//   1. Attribution markers are banned EVERYWHERE, including commit messages:
//      a Co-Authored-By trailer naming a vendor or "AI", a "Generated with /
//      by" line, an "Authored / Written / Assisted by <vendor>" credit, and
//      the robot marker some tools append.
//
//   2. Bare vendor names are banned in CODE AND CONTENT only: lib/, test/,
//      content/, assets/, functions/, android/, ios/, tool/, tools/. They have
//      no legitimate reason to appear there.
//
// Prose documentation is checked for tier 1 only. That is deliberate and it is
// what makes this check usable. The project's own instruction file is named
// CLAUDE.md, so every document referring to it by name used to trip a bare
// substring ban, and so did every plan carrying the line "No AI/Claude
// attribution in any commit message". The check exited 1 permanently, and a
// gate that is always red teaches everyone to ignore gates.
//
// Two exemptions are applied before any scan, in every scope:
//   - the literal filename `CLAUDE.md`, which is a reference and not a credit
//   - a sentence stating the prohibition, e.g. "No AI/Claude attribution" or
//     "do not add a Co-Authored-By: Claude trailer"
//
// Exit code: 0 if clean, 1 if any hit.
//
// Note: scans only files under git tracking, so notes outside the repo are not
// affected.
import 'dart:io';

/// Attribution markers. Banned in every file and every commit message.
final _markers = <RegExp>[
  RegExp(
    r'co-?authored-?by\s*:\s*\W*(claude|anthropic|chatgpt|gpt|copilot|gemini|ai\b)',
    caseSensitive: false,
  ),
  RegExp(
    r'generated\s+(with|by)\s+\W*(claude|anthropic|chatgpt|gpt|copilot|gemini|an?\s+ai\b|ai\b)',
    caseSensitive: false,
  ),
  RegExp(
    r'(authored|written|assisted|created)\s+by\s+\W*(claude|anthropic|chatgpt|copilot|gemini)',
    caseSensitive: false,
  ),
  RegExp('\u{1F916}'), // the robot marker some tools append
];

/// Vendor names. Banned in code and content, where they have no business.
final _vendors = RegExp(
  r'\b(claude|anthropic|chatgpt|openai|copilot)\b',
  caseSensitive: false,
);

/// Paths where a bare vendor name is a hit. Everything else is prose and is
/// checked for attribution markers only.
const _vendorScopes = <String>[
  'lib/',
  'test/',
  'content/',
  'assets/',
  'functions/',
  'android/',
  'ios/',
  'tool/',
  'tools/',
];

const _exemptPaths = <String>[
  'tool/check_no_ai_attribution.dart', // this file names the patterns
  'test/tool/check_no_ai_attribution_test.dart', // and so does its test
  'tools/audit/data/ai_phrases.txt', // a list of phrases to hunt for
  // Reproduces this checker's own source in a fenced block, including the
  // patterns it hunts for. Exempt for the same reason the checker is.
  'docs/superpowers/plans/2026-05-07-plan-01-foundation-and-ops.md',
];

/// The instruction file's name is a reference, never a credit.
final _fileNameReference = RegExp(r'CLAUDE\.md');

/// A sentence stating the prohibition is not a violation of it. Without this,
/// every plan carrying "No AI/Claude attribution in any commit message" is a
/// hit, and so is this project's own documentation of its own rule.
final _ruleStatement = RegExp(
  r'(\bno\b|\bnot\b|never|ban|banned|forbid|forbidden|avoid|without|do not)'
  r'[^.\n]{0,70}?'
  r'(attribution|trailer|co-?authored|generated\s+(with|by))',
  caseSensitive: false,
);

bool isExempt(String path) => _exemptPaths.contains(path);

/// Strips the two things that look like attribution and are not.
String _withoutFalsePositives(String text) {
  return text
      .replaceAll(_fileNameReference, '')
      .split('\n')
      .map((line) => _ruleStatement.hasMatch(line) ? '' : line)
      .join('\n');
}

/// Returns one description per violation found in [contents] at [path].
List<String> scanText(String path, String contents) {
  if (isExempt(path)) return const [];
  final text = _withoutFalsePositives(contents);
  final hits = <String>[];

  for (final marker in _markers) {
    final match = marker.firstMatch(text);
    if (match != null) {
      hits.add('$path: attribution marker "${match.group(0)!.trim()}"');
    }
  }

  if (_vendorScopes.any(path.startsWith)) {
    final match = _vendors.firstMatch(text);
    if (match != null) {
      hits.add('$path: vendor name "${match.group(0)}" in code or content');
    }
  }

  return hits;
}

/// Commit messages carry tier 1 only. A message may name `CLAUDE.md` and may
/// describe the rule.
List<String> scanCommitMessage(String sha, String message) {
  final text = _withoutFalsePositives(message);
  final hits = <String>[];
  for (final marker in _markers) {
    final match = marker.firstMatch(text);
    if (match != null) {
      final short = sha.length > 8 ? sha.substring(0, 8) : sha;
      hits.add('commit $short: attribution marker "${match.group(0)!.trim()}"');
    }
  }
  return hits;
}

Future<void> main(List<String> args) async {
  final hits = <String>[];

  final tracked = await Process.run('git', ['ls-files']);
  if (tracked.exitCode != 0) {
    stderr.writeln('git ls-files failed: ${tracked.stderr}');
    exit(2);
  }

  final paths =
      (tracked.stdout as String).split('\n').where((s) => s.isNotEmpty);
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    String contents;
    try {
      contents = file.readAsStringSync();
    } on FileSystemException {
      continue; // binary or unreadable
    }
    hits.addAll(scanText(path, contents));
  }

  // Commit messages are where a trailer actually gets added, and the old
  // file-only check could not see them at all.
  const unitSep = '';
  const recordSep = '';
  final log = await Process.run(
    'git',
    ['log', '--format=%H$unitSep%B$recordSep'],
  );
  if (log.exitCode == 0) {
    for (final entry in (log.stdout as String).split(recordSep)) {
      final parts = entry.trim().split(unitSep);
      if (parts.length != 2) continue;
      hits.addAll(scanCommitMessage(parts[0], parts[1]));
    }
  }

  if (hits.isEmpty) {
    stdout.writeln('check_no_ai_attribution: OK');
    exit(0);
  }
  stderr.writeln('check_no_ai_attribution: ${hits.length} hit(s)');
  for (final h in hits) {
    stderr.writeln('  $h');
  }
  exit(1);
}
