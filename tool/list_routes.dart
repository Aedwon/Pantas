// Lists the app's screens for the local test panel (Screens tab).
//
// Reads `lib/app/router.dart` and `lib/app/routes/*.dart`, finds every
// `GoRoute(path: '...')`, joins nested paths to their parent, and prints a
// JSON list of {path, label, group} to stdout. The local runner writes the
// output to `build/web/local-panel-routes.json`.
//
// Routes whose path has a segment starting with an underscore (the
// debug-only gallery and debug settings) are left out: a profile build does
// not register them.
import 'dart:convert';
import 'dart:io';

/// One row of the Screens tab.
class PanelRoute {
  const PanelRoute({
    required this.path,
    required this.label,
    required this.group,
  });

  final String path;
  final String label;
  final String group;

  Map<String, String> toJson() => {
        'path': path,
        'label': label,
        'group': group,
      };
}

const _groupOrder = <String>[
  'Home and plan',
  'Study and quiz',
  'Mock',
  'Settings and Pro',
  'Other',
];

const _labelOverrides = <String, String>{
  '/quiz/today/:examId': "Today's quiz",
};

void main(List<String> args) {
  final routes = listRoutes(Directory('lib/app'));
  stdout.writeln(
    const JsonEncoder.withIndent('  ').convert(
      [for (final route in routes) route.toJson()],
    ),
  );
}

/// Every screen path under [appDir] (`lib/app`), once each, with a label and
/// a group, ordered by group and then by path.
List<PanelRoute> listRoutes(Directory appDir) {
  final files = <File>[
    File('${appDir.path}/router.dart'),
    ...Directory('${appDir.path}/routes')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart')),
  ]..sort((a, b) => a.path.compareTo(b.path));

  final seen = <String>{};
  final routes = <PanelRoute>[];
  for (final file in files) {
    for (final path in routesIn(file.readAsStringSync())) {
      if (path.split('/').any((segment) => segment.startsWith('_'))) continue;
      if (!seen.add(path)) continue;
      routes.add(
        PanelRoute(path: path, label: labelFor(path), group: groupFor(path)),
      );
    }
  }
  routes.sort((a, b) {
    final byGroup =
        _groupOrder.indexOf(a.group).compareTo(_groupOrder.indexOf(b.group));
    return byGroup != 0 ? byGroup : a.path.compareTo(b.path);
  });
  return routes;
}

final _routeStart = RegExp(r"GoRoute\(\s*path:\s*'([^']*)'");

/// The full path of every `GoRoute(path: '...')` in [source], in source
/// order. A path that does not start with a slash is joined to the nearest
/// enclosing route. A `path:` argument that is not directly inside a
/// `GoRoute(` (for example `Uri(path: ...)`) is not a route and is ignored.
List<String> routesIn(String source) {
  final spans = <_Span>[
    for (final match in _routeStart.allMatches(source))
      _Span(
        start: match.start,
        end: _closingParen(source, source.indexOf('(', match.start)),
        path: match.group(1)!,
      ),
  ];
  final resolved = <String>[];
  for (var i = 0; i < spans.length; i++) {
    final span = spans[i];
    var path = span.path;
    if (!path.startsWith('/')) {
      _Span? parent;
      for (final other in spans) {
        if (other == span) continue;
        final encloses = other.start < span.start && other.end > span.end;
        if (encloses && (parent == null || other.start > parent.start)) {
          parent = other;
        }
      }
      if (parent == null) continue;
      final parentPath = resolved[spans.indexOf(parent)];
      path = '$parentPath/$path';
    }
    resolved.add(path);
  }
  return resolved;
}

class _Span {
  const _Span({required this.start, required this.end, required this.path});

  final int start;
  final int end;
  final String path;
}

/// The index of the `)` that closes the `(` at [open], skipping string
/// literals.
int _closingParen(String source, int open) {
  var depth = 0;
  String? quote;
  for (var i = open; i < source.length; i++) {
    final char = source[i];
    if (quote != null) {
      if (char == r'\') {
        i++;
      } else if (char == quote) {
        quote = null;
      }
      continue;
    }
    if (char == "'" || char == '"') {
      quote = char;
    } else if (char == '(') {
      depth++;
    } else if (char == ')') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return source.length;
}

/// A readable name for [path]: its static segments in sentence case, with
/// "quiz" dropped before "mock" and "settings" dropped before a sub-page.
String labelFor(String path) {
  final override = _labelOverrides[path];
  if (override != null) return override;
  var words = path
      .split('/')
      .where((segment) => segment.isNotEmpty && !segment.startsWith(':'))
      .map((segment) => segment.replaceAll('-', ' '))
      .toList();
  if (words.length > 1 && words.first == 'quiz' && words[1] == 'mock') {
    words = words.sublist(1);
  }
  if (words.length > 1 && words.first == 'settings') {
    words = words.sublist(1);
  }
  final text = words.join(' ');
  return text.isEmpty ? path : text[0].toUpperCase() + text.substring(1);
}

/// The Screens tab section for [path], by its first segment.
String groupFor(String path) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  final first = segments.isEmpty ? '' : segments.first;
  if (first == 'quiz' && segments.length > 1 && segments[1] == 'mock') {
    return 'Mock';
  }
  switch (first) {
    case 'home':
    case 'plan':
    case 'performance':
    case 'record':
    case 'tendencies':
      return 'Home and plan';
    case 'study':
    case 'lesson':
    case 'quiz':
    case 'assessment':
      return 'Study and quiz';
    case 'mock':
      return 'Mock';
    case 'settings':
    case 'pro':
    case 'legal':
      return 'Settings and Pro';
  }
  return 'Other';
}
