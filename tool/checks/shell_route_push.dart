// A page above the web ShellRoute must not push a route inside it.
//
// Pushed from up there, a page inside the shell asks for a second shell with
// the same navigator: the one in use moves under the lesson and the new page
// is blank. buildAppRoutes in lib/app/router.dart lifts the lesson and
// webRoutesAboveLesson above the shell; this check reads the same names.
import 'dart:io';

import '../list_routes.dart';
import 'check.dart';

/// Findings that are known. Key: `path|route`.
const _accepted = <String, String>{
  'lib/features/quiz/application/quiz_starts.dart|/quiz/quick/:examId':
      'startQuickQuiz shares a file with the lesson quiz start; only Study '
          'calls it',
  'lib/core/error/state_patterns.dart|/settings/exam/change':
      'OPEN BUG: the lesson contents sheet can show chooseExamFallback, whose '
          'button pushes this route. Reported Nov 5; remove once fixed',
};

const _lessonRoute = '/lesson/:lessonId';

class ShellRoutePushCheck extends Check {
  const ShellRoutePushCheck();

  @override
  String get name => 'shell-route-push';

  @override
  String get origin =>
      'Nov 2026 web: pushing a shell page over a lesson or its quiz opened a '
      'blank page (see buildAppRoutes)';

  @override
  List<Violation> run(String root) {
    final sources = libSources(root);
    final router = File('$root/lib/app/router.dart').readAsStringSync();
    final setBody =
        RegExp(r'webRoutesAboveLesson = \{([^}]*)\}').firstMatch(router);
    if (setBody == null) {
      return const [
        Violation('lib/app/router.dart', 'webRoutesAboveLesson not found'),
      ];
    }
    final above = {
      _lessonRoute,
      for (final match in RegExp("'([^']+)'").allMatches(setBody.group(1)!))
        match.group(1)!,
    };
    final routeFiles = {
      for (final entry in sources.entries)
        if (entry.key.startsWith('lib/app/')) entry.key: entry.value,
    };
    final routes = {
      for (final source in routeFiles.values) ...routesIn(source),
    };
    final missing = above.difference(routes);
    if (missing.isNotEmpty) {
      return [Violation('lib/app/routes', 'routes not found: $missing')];
    }
    final roots = <String>{};
    final problems = <Violation>[];
    for (final path in above) {
      final page = pageBuiltBy(path, routeFiles.values);
      final file = page == null ? null : fileDeclaring(page, sources);
      if (file == null) {
        problems.add(Violation(path, 'could not find the page it builds'));
      } else {
        roots.add(file);
      }
    }
    return [
      ...problems,
      ...findShellPushes(
        sources: sources,
        roots: roots,
        shellRoutes: routes.difference(above),
        aboveRoutes: above,
      ),
    ];
  }
}

/// The widget a route's builder returns, from the source after its path.
String? pageBuiltBy(String path, Iterable<String> routeFiles) {
  for (final source in routeFiles) {
    final at = source.indexOf("path: '$path'");
    if (at < 0) continue;
    final rest = source.substring(at, (at + 500).clamp(0, source.length));
    final page = RegExp(r'\b([A-Z]\w*(?:Page|Screen))\(').firstMatch(rest);
    if (page != null) return page.group(1);
  }
  return null;
}

String? fileDeclaring(String className, Map<String, String> sources) {
  final declaration = RegExp('class $className\\b');
  for (final entry in sources.entries) {
    if (declaration.hasMatch(entry.value)) return entry.key;
  }
  return null;
}

/// Every push from code [roots] import to a route in [shellRoutes].
List<Violation> findShellPushes({
  required Map<String, String> sources,
  required Set<String> roots,
  required Set<String> shellRoutes,
  required Set<String> aboveRoutes,
}) {
  final violations = <Violation>[];
  final call = RegExp(r'\.(push|pushReplacement)(?:<[^>()]*>)?\(');
  for (final path in _importClosure(roots, sources)) {
    final source = withoutLineComments(sources[path]!);
    for (final match in call.allMatches(source)) {
      final target = _target(source, match.end);
      if (target == null) continue;
      if (aboveRoutes.any((route) => _matches(target, route))) continue;
      final route = shellRoutes.where((r) => _matches(target, r)).firstOrNull;
      if (route == null) continue;
      if (_guarded(source, match.start, match.group(1)!)) continue;
      violations.add(
        Violation(
          '$path:${lineAt(source, match.start)}',
          'pushes shell route $route from a page above the shell. '
              'Use go, or lift the route in webRoutesAboveLesson.',
          acceptedBecause: _accepted['$path|$route'],
        ),
      );
    }
  }
  return violations;
}

/// A push behind a shell test is deliberate, and replacing the only page has
/// nothing beneath it to collide with.
bool _guarded(String source, int offset, String method) {
  final lines = source.substring(0, offset).split('\n');
  final recent =
      lines.skip((lines.length - 8).clamp(0, lines.length)).join('\n');
  if (recent.contains('ShellRouteMatch')) return true;
  if (method != 'pushReplacement') return false;
  return lines
      .skip((lines.length - 3).clamp(0, lines.length))
      .join('\n')
      .contains('canPop');
}

Iterable<String> _importClosure(
  Set<String> roots,
  Map<String, String> sources,
) {
  final seen = <String>{};
  final pending = roots.toList();
  final directive = RegExp(
    r'^\s*(?:import|export|part)\s[^;]*;',
    multiLine: true,
  );
  final uri = RegExp(r'''['"]([^'"]+\.dart)['"]''');
  while (pending.isNotEmpty) {
    final path = pending.removeLast();
    if (!sources.containsKey(path) || !seen.add(path)) continue;
    for (final line in directive.allMatches(sources[path]!)) {
      for (final match in uri.allMatches(line.group(0)!)) {
        pending.add(_resolve(path, match.group(1)!));
      }
    }
  }
  return seen;
}

String _resolve(String from, String target) {
  const package = 'package:pantas/';
  if (target.startsWith(package)) {
    return 'lib/${target.substring(package.length)}';
  }
  final parts = from.split('/')..removeLast();
  for (final part in target.split('/')) {
    if (part == '..') {
      parts.removeLast();
    } else if (part != '.') {
      parts.add(part);
    }
  }
  return parts.join('/');
}

const _hole = '\u0000';

/// The path a push names, with interpolations as holes. Null when it cannot be
/// read from the source, such as a value passed in.
String? _target(String source, int start) {
  var at = start;
  void skipSpace() {
    while (at < source.length && source[at].trim().isEmpty) {
      at++;
    }
  }

  skipSpace();
  if (at >= source.length) return null;
  if (source[at] != "'" && source[at] != '"') {
    final name = RegExp(r'\w+').matchAsPrefix(source, at)?.group(0);
    if (name == null) return null;
    final value = RegExp(
      "(?:const|final)\\s+$name\\s*=\\s*'([^'\$]*)'",
    ).firstMatch(source)?.group(1);
    return value?.split('?').first;
  }
  final path = StringBuffer();
  while (at < source.length && (source[at] == "'" || source[at] == '"')) {
    final quote = source[at++];
    var depth = 0;
    while (at < source.length && (depth > 0 || source[at] != quote)) {
      final char = source[at];
      if (depth > 0) {
        if (char == '{') depth++;
        if (char == '}') depth--;
        at++;
      } else if (char == r'$' && source[at + 1] == '{') {
        depth = 1;
        at += 2;
        path.write(_hole);
      } else if (char == r'$') {
        at++;
        at = RegExp(r'\w*').matchAsPrefix(source, at)!.end;
        path.write(_hole);
      } else {
        path.write(char);
        at++;
      }
    }
    at++;
    skipSpace();
  }
  return path.toString().split('?').first;
}

bool _matches(String target, String route) {
  final have = target.split('/');
  final want = route.split('/');
  if (have.length != want.length) return false;
  for (var i = 0; i < want.length; i++) {
    if (want[i].startsWith(':')) {
      if (have[i].isEmpty) return false;
    } else if (have[i] != want[i]) {
      return false;
    }
  }
  return true;
}
