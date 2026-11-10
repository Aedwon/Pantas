import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// The path filter script in tool/ci/changed_areas.sh, run against a small
// throwaway git history.
void main() {
  late Directory repo;
  late String first;

  ProcessResult git(List<String> args) =>
      Process.runSync('git', args, workingDirectory: repo.path);

  Map<String, String> areas({
    required String ref,
    String event = 'push',
    String? before,
  }) {
    final out = File('${repo.path}/.out')..writeAsStringSync('');
    final result = Process.runSync(
      'bash',
      <String>['${Directory.current.path}/tool/ci/changed_areas.sh'],
      workingDirectory: repo.path,
      environment: <String, String>{
        'EVENT': event,
        'REF': ref,
        'BEFORE': before ?? first,
        'GITHUB_OUTPUT': out.path,
      },
    );
    expect(result.exitCode, 0, reason: '${result.stderr}');
    return <String, String>{
      for (final line in out.readAsLinesSync())
        line.split('=').first: line.split('=').last,
    };
  }

  setUp(() {
    repo = Directory.systemTemp.createTempSync('changed_areas_');
    git(<String>['init', '-q']);
    git(<String>['config', 'user.email', 'ci@example.com']);
    git(<String>['config', 'user.name', 'ci']);
    File('${repo.path}/README.txt').writeAsStringSync('a');
    git(<String>['add', '.']);
    git(<String>['commit', '-qm', 'first']);
    first = (git(<String>['rev-parse', 'HEAD']).stdout as String).trim();
    Directory('${repo.path}/lib').createSync();
    File('${repo.path}/lib/a.dart').writeAsStringSync('a');
    git(<String>['add', '.']);
    git(<String>['commit', '-qm', 'code only']);
  });

  tearDown(() => repo.deleteSync(recursive: true));

  const all = <String, String>{
    'flutter': 'true',
    'functions': 'true',
    'android': 'true',
  };

  test('a code-only push to a feature branch skips Android and functions', () {
    expect(areas(ref: 'refs/heads/web/ci-speed-r1'), <String, String>{
      'flutter': 'true',
      'functions': 'false',
      'android': 'false',
    });
  });

  test('main and the release line always run everything', () {
    expect(areas(ref: 'refs/heads/main'), all);
    expect(areas(ref: 'refs/heads/web/design-system-4'), all);
  });

  test('a manual run and a push with no base run everything', () {
    expect(areas(ref: 'refs/heads/web/x', event: 'workflow_dispatch'), all);
    expect(areas(ref: 'refs/heads/web/x', before: '0' * 40), all);
  });
}
