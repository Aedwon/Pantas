import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _baseSha = 'd0afd71548e520ef5b4a8668ef99eae1650494d4';
const _flutterVersion = '3.41.9';
const _flutterRevision = '00b0c91f06209d9e4a41f71b7a512d6eb3b9c694';
const _dartVersion = '3.11.5';
const _device = 'emulator-5554';
const _onboardingRepairCommit = 'ac02421aeaf16140c5dae3b6b0cf2e7ef2c4f05b';
const _onboardingRepairPath =
    'lib/features/onboarding/presentation/onboarding_picker_step.dart';
const _onboardingRepairSha256 =
    'e1b08420ea0ad0d99f01adec53fe57cf2a02d7b88d4fcc62b9656a642950d0fe';
const _reviewLogRepairCommit = '482b96fb77d1504e6141f759455f22e4196c4156';
const _reviewLogRepairPath =
    'lib/features/quiz/application/quiz_providers.dart';
const _reviewLogRepairSha256 =
    'af6584723b81ac99a33a6f3853078b3b3e8e392023e656e11d3868578bc2e553';
const _onboardingRepairTestPath =
    'test/app/router_onboarding_completion_test.dart';
const _onboardingRepairTestSha256 =
    'ab52f275a6570df2c5c871749438c090f125be22cc22144a64aedb07aa80007e';
const _reviewLogRepairTestPath =
    'test/features/quiz/application/quiz_providers_review_log_test.dart';
const _reviewLogRepairTestSha256 =
    '3406906973e944e35ba1293320f476535e2e2c84c7202218a015b52bb04960b3';
const _acceptedProductionRepairs =
    <({String commit, String path, String sha256})>[
  (
    commit: _onboardingRepairCommit,
    path: _onboardingRepairPath,
    sha256: _onboardingRepairSha256,
  ),
  (
    commit: _reviewLogRepairCommit,
    path: _reviewLogRepairPath,
    sha256: _reviewLogRepairSha256,
  ),
];
const _acceptedRepairFiles = <({String commit, String path, String sha256})>[
  ..._acceptedProductionRepairs,
  (
    commit: _onboardingRepairCommit,
    path: _onboardingRepairTestPath,
    sha256: _onboardingRepairTestSha256,
  ),
  (
    commit: _reviewLogRepairCommit,
    path: _reviewLogRepairTestPath,
    sha256: _reviewLogRepairTestSha256,
  ),
];

String _which(String command) {
  final result = Process.runSync('which', <String>[command]);
  if (result.exitCode != 0) throw StateError('missing test tool: $command');
  return result.stdout.toString().trim();
}

final _python = _which('python3');
final _git = _which('git');

Future<ProcessResult> _runner(List<String> args) =>
    Process.run('bash', <String>['tools/release/test_e2e.sh', ...args]);

Future<ProcessResult> _support(
  List<String> args, {
  Map<String, String>? environment,
}) =>
    Process.run(
      _python,
      <String>['tools/release/e2e/runner_support.py', ...args],
      environment: environment,
      includeParentEnvironment: environment == null,
    );

Future<void> _mustGit(Directory root, List<String> args) async {
  final result = await Process.run(_git, args, workingDirectory: root.path);
  expect(result.exitCode, 0, reason: result.stderr.toString());
}

Future<void> _executable(File file, String text) async {
  await file.writeAsString(text);
  final result = await Process.run('chmod', <String>['+x', file.path]);
  expect(result.exitCode, 0, reason: result.stderr.toString());
}

Future<String> _gitShow(String revision, String path) async {
  final result = await Process.run(
    _git,
    <String>['show', '$revision:$path'],
  );
  expect(result.exitCode, 0, reason: result.stderr.toString());
  return result.stdout.toString();
}

Future<void> _applyAcceptedProductionRepairs(FakeRepository fixture) async {
  for (final repair in _acceptedRepairFiles) {
    final bytes = utf8.encode(await _gitShow(repair.commit, repair.path));
    expect(sha256.convert(bytes).toString(), repair.sha256);
    final file = File('${fixture.root.path}/${repair.path}');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
  }
  await _mustGit(fixture.root, <String>[
    'add',
    _onboardingRepairPath,
    _reviewLogRepairPath,
    _onboardingRepairTestPath,
    _reviewLogRepairTestPath,
  ]);
  await _mustGit(
    fixture.root,
    <String>['commit', '-m', 'accepted repairs'],
  );
}

Future<void> _commitAllowedHarnessDiffs(FakeRepository fixture) async {
  for (final path in <String>[
    'tools/release/e2e/fake_support.py',
    'integration_test/release/fake_journey_test.dart',
    'test/tool/release_e2e_fake_test.dart',
  ]) {
    final file = File('${fixture.root.path}/$path');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('release e2e fixture\n');
  }
  await _mustGit(fixture.root, <String>['add', '.']);
  await _mustGit(
    fixture.root,
    <String>['commit', '-m', 'allowed harness diffs'],
  );
}

Object? _yamlValue(Object? value) {
  if (value is YamlMap) {
    return <String, Object?>{
      for (final entry in value.entries)
        entry.key.toString(): _yamlValue(entry.value),
    };
  }
  if (value is YamlList) return value.map(_yamlValue).toList();
  return value;
}

class FakeRepository {
  FakeRepository(this.root, this.bin, this.candidate, this.contentSha);

  final Directory root;
  final Directory bin;
  final String candidate;
  final String contentSha;

  List<String> preflight({String? candidateSha, String? expectedContentSha}) =>
      <String>[
        'preflight',
        '--repo-root',
        root.path,
        '--candidate',
        candidateSha ?? candidate,
        '--content-sha',
        expectedContentSha ?? contentSha,
        '--device',
        _device,
      ];

  Map<String, String> env({
    String flutter = _flutterVersion,
    String revision = _flutterRevision,
    String dart = _dartVersion,
    String java = '17.0.12',
    String gradle = '8.14',
    String adbMode = 'online',
    Map<String, String> extra = const <String, String>{},
  }) =>
      <String, String>{
        'PATH': '${bin.path}:/usr/bin:/bin',
        'FAKE_FLUTTER_VERSION': flutter,
        'FAKE_FLUTTER_REVISION': revision,
        'FAKE_DART_VERSION': dart,
        'FAKE_JAVA_VERSION': java,
        'FAKE_GRADLE_VERSION': gradle,
        'FAKE_ADB_MODE': adbMode,
        ...extra,
      };

  static Future<FakeRepository> create({
    String agp = '8.11.1',
    String? prefix,
  }) async {
    final root = await Directory.systemTemp.createTemp('pantas-release-e2e-');
    final bin = Directory('${root.path}/fake-bin')..createSync(recursive: true);
    File('${root.path}/.gitignore').writeAsStringSync('fake-bin/\n');
    final bytes = utf8.encode('approved shipping fixture');
    final digest = sha256.convert(bytes).toString();

    File('${root.path}/pubspec.yaml')
      ..createSync(recursive: true)
      ..writeAsStringSync('name: pantas\n');
    File('${root.path}/assets/seed/content.db')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
    File('${root.path}/lib/core/content/content_seed_version.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        "const contentSeedVersion = '${prefix ?? digest.substring(0, 16)}';\n",
      );
    for (final path in <String>[
      _onboardingRepairPath,
      _reviewLogRepairPath,
    ]) {
      File('${root.path}/$path')
        ..createSync(recursive: true)
        ..writeAsStringSync('nominal candidate bytes for $path\n');
    }
    File('${root.path}/android/settings.gradle.kts')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        'plugins { id("com.android.application") '
        'version "$agp" apply false }\n',
      );
    File('${root.path}/android/gradle/wrapper/gradle-wrapper.jar')
      ..createSync(recursive: true)
      ..writeAsBytesSync(const <int>[0]);
    File('${root.path}/firestore.rules')
      ..createSync(recursive: true)
      ..writeAsStringSync("rules_version = '2';\n");
    File('${root.path}/firestore.indexes.json')
      ..createSync(recursive: true)
      ..writeAsStringSync('{"indexes":[],"fieldOverrides":[]}\n');

    const ci = 'name: CI (main)\n\n'
        '''
on:
  push:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - run: flutter test
''';
    const integration = '  integration:\n'
        '''
    runs-on: macos-13
    needs: ci
    steps:
      - run: echo integration
''';
    File('${root.path}/.github/workflows/main.yml')
      ..createSync(recursive: true)
      ..writeAsStringSync('$ci$integration');

    await _executable(
      File('${root.path}/android/gradlew'),
      '#!/bin/sh\n'
      r'''
printf 'Gradle %s\n' "${FAKE_GRADLE_VERSION:-8.14}"
''',
    );
    await _executable(
      File('${bin.path}/flutter'),
      '#!/bin/sh\n'
      r'''
if [ "${1-}" = "--version" ] && [ "${2-}" = "--machine" ]; then
  printf '{"frameworkVersion":"%s","frameworkRevision":"%s","dartSdkVersion":"%s"}\n' \
    "${FAKE_FLUTTER_VERSION:-3.41.9}" \
    "${FAKE_FLUTTER_REVISION:-00b0c91f06209d9e4a41f71b7a512d6eb3b9c694}" \
    "${FAKE_DART_VERSION:-3.11.5}"
  exit 0
fi
exit 0
''',
    );
    await _executable(
      File('${bin.path}/java'),
      '#!/bin/sh\n'
      r'''
printf 'openjdk version "%s" 2026-01-01\n' "${FAKE_JAVA_VERSION:-17.0.12}" >&2
''',
    );
    await _executable(
        File('${bin.path}/firebase'),
        '#!/bin/sh\n'
        r'''
printf '14.12.0\n'
''');
    await _executable(
      File('${bin.path}/adb'),
      '#!/bin/sh\n'
              r'''
mode="${FAKE_ADB_MODE:-online}"
if [ "${1-}" = "version" ]; then
  printf 'Android Debug Bridge version 1.0.41\n'
  exit 0
fi
if [ "${1-}" = "devices" ]; then
  printf 'List of devices attached\n'
  case "$mode" in
    online) printf '__DEVICE__\tdevice\n' ;;
    absent) ;;
    unauthorized) printf '__DEVICE__\tunauthorized\n' ;;
    offline) printf '__DEVICE__\toffline\n' ;;
    ambiguous) printf '__DEVICE__\tdevice\n__DEVICE__\tdevice\n' ;;
  esac
  exit 0
fi
if [ "${1-}" = "-s" ]; then
  serial="${2-}"
  [ "$serial" = "__DEVICE__" ] || exit 41
  shift 2
  if [ "${1-}" = "get-state" ]; then
    [ "$mode" = "online" ] || exit 42
    printf 'device\n'
    exit 0
  fi
  if [ "${1-}" = "shell" ] && [ "${2-}" = "getprop" ]; then
    case "${3-}" in
      ro.build.version.sdk) printf '35\n' ;;
      ro.product.model) printf 'Fake_Pixel\n' ;;
    esac
    exit 0
  fi
fi
exit 0
'''
          .replaceAll('__DEVICE__', _device),
    );

    await _mustGit(root, <String>['init']);
    await _mustGit(root, <String>[
      'config',
      'user.email',
      'runner-test@example.invalid',
    ]);
    await _mustGit(root, <String>['config', 'user.name', 'Runner Test']);
    await _mustGit(root, <String>[
      'remote',
      'add',
      'origin',
      'https://github.com/Aedwon/Pantas.git',
    ]);
    await _mustGit(root, <String>['add', '.']);
    await _mustGit(root, <String>['commit', '-m', 'candidate']);
    final candidate = (await Process.run(
      _git,
      <String>['rev-parse', 'HEAD'],
      workingDirectory: root.path,
    ))
        .stdout
        .toString()
        .trim();

    File('${root.path}/.github/workflows/main.yml').writeAsStringSync(ci);
    File('${root.path}/docs/superpowers/specs/2026-09-05-release-e2e-design.md')
      ..createSync(recursive: true)
      ..writeAsStringSync('# Release E2E design\n');
    await _mustGit(root, <String>['add', '.']);
    await _mustGit(root, <String>['commit', '-m', 'e2e docs']);

    return FakeRepository(root, bin, candidate, digest);
  }

  Future<void> dispose() => root.delete(recursive: true);
}

class _ResetEmulatorStub {
  _ResetEmulatorStub(
    this.auth,
    this.firestore,
    this.authRequests,
    this.authAuthorizations,
    this.firestoreRequests,
    this.firestoreBodies,
  );

  final HttpServer auth;
  final HttpServer firestore;
  final List<String> authRequests;
  final List<String?> authAuthorizations;
  final List<String> firestoreRequests;
  final List<String> firestoreBodies;

  static Future<_ResetEmulatorStub> start(
    String projectId, {
    bool authHasUsers = false,
    bool allowLegacyFirestoreRootGet = true,
    int firestoreListStatus = HttpStatus.ok,
    String? firestoreListBody,
    List<String> firestoreCollectionIds = const <String>[],
  }) async {
    final auth = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final firestore = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final stub = _ResetEmulatorStub(
      auth,
      firestore,
      <String>[],
      <String?>[],
      <String>[],
      <String>[],
    );
    final accountsPath = '/emulator/v1/projects/$projectId/accounts';
    final batchListPath =
        '/identitytoolkit.googleapis.com/v1/projects/$projectId/accounts:batchGet';
    auth.listen((request) async {
      final target = request.uri.hasQuery
          ? '${request.uri.path}?${request.uri.query}'
          : request.uri.path;
      stub.authRequests.add('${request.method} $target');
      await request.drain<void>();
      final response = request.response;
      if (request.method == 'DELETE' && request.uri.path == accountsPath) {
        response.statusCode = HttpStatus.ok;
        response.headers.contentType = ContentType.json;
        response.write('{}');
      } else if (request.method == 'GET' && request.uri.path == accountsPath) {
        response
          ..statusCode = HttpStatus.methodNotAllowed
          ..write('Method GET not allowed');
      } else if (request.method == 'GET' &&
          request.uri.path == batchListPath &&
          request.uri.queryParameters['maxResults'] == '1') {
        stub.authAuthorizations.add(
          request.headers.value(HttpHeaders.authorizationHeader),
        );
        response.statusCode = HttpStatus.ok;
        response.headers.contentType = ContentType.json;
        response.write(
          jsonEncode(
            authHasUsers
                ? <String, Object?>{
                    'users': <Object>[
                      <String, String>{'localId': 'leftover-user'},
                    ],
                  }
                : const <String, Object?>{},
          ),
        );
      } else {
        response.statusCode = HttpStatus.notFound;
      }
      await response.close();
    });

    final deletePath =
        '/emulator/v1/projects/$projectId/databases/(default)/documents';
    final legacyListPath =
        '/v1/projects/$projectId/databases/(default)/documents';
    final listCollectionsPath =
        '/v1/projects/$projectId/databases/(default)/documents:listCollectionIds';
    firestore.listen((request) async {
      final target = request.uri.hasQuery
          ? '${request.uri.path}?${request.uri.query}'
          : request.uri.path;
      stub.firestoreRequests.add('${request.method} $target');
      final body = await utf8.decoder.bind(request).join();
      stub.firestoreBodies.add(body);
      final response = request.response;
      if (request.method == 'DELETE' && request.uri.path == deletePath) {
        response.statusCode = HttpStatus.ok;
        response.headers.contentType = ContentType.json;
        response.write('{}');
      } else if (request.method == 'GET' &&
          request.uri.path == legacyListPath &&
          allowLegacyFirestoreRootGet) {
        response.statusCode = HttpStatus.ok;
        response.headers.contentType = ContentType.json;
        response.write('{}');
      } else if (request.method == 'POST' &&
          request.uri.path == listCollectionsPath) {
        if (request.headers.value(HttpHeaders.authorizationHeader) !=
            'Bearer owner') {
          response.statusCode = HttpStatus.forbidden;
          response.headers.contentType = ContentType.json;
          response.write('admin authorization required');
          await response.close();
          return;
        }
        response.statusCode = firestoreListStatus;
        response.headers.contentType = ContentType.json;
        response.write(
          firestoreListBody ??
              jsonEncode(
                firestoreCollectionIds.isEmpty
                    ? const <String, Object?>{}
                    : <String, Object?>{
                        'collectionIds': firestoreCollectionIds,
                      },
              ),
        );
      } else {
        response.statusCode = HttpStatus.notFound;
      }
      await response.close();
    });
    return stub;
  }

  Future<void> close() async {
    await auth.close(force: true);
    await firestore.close(force: true);
  }
}

void main() {
  group('public runner arguments', () {
    test('missing, extra, and unknown arguments fail closed', () async {
      for (final args in <List<String>>[
        <String>[],
        <String>['--candidate'],
        <String>[
          '--candidate',
          'a' * 40,
          '--content-sha',
          'b' * 64,
          '--device',
          _device,
          'extra',
        ],
        <String>['--unknown', 'value'],
      ]) {
        final result = await _runner(args);
        expect(result.exitCode, isNot(0), reason: args.join(' '));
        expect(
          result.stderr.toString(),
          contains('release e2e runner failed:'),
        );
      }
    });

    test('candidate must be a full 40-character SHA', () async {
      final result = await _runner(<String>[
        '--candidate',
        'a' * 39,
        '--content-sha',
        'b' * 64,
        '--device',
        _device,
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('40-character Git SHA'));
    });

    test('content hash must be a full 64-character SHA-256', () async {
      final result = await _runner(<String>[
        '--candidate',
        'a' * 40,
        '--content-sha',
        'b' * 63,
        '--device',
        _device,
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('64-character SHA-256'));
    });
  });

  group('provenance, toolchain, and target preflight', () {
    test('accepts an isolated fake repository satisfying the contract',
        () async {
      final fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      final result = await _support(
        fixture.preflight(),
        environment: fixture.env(),
      );
      expect(result.exitCode, 0, reason: result.stderr.toString());
      final output =
          jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
      expect(output['candidate'], fixture.candidate);
      expect(output['content_sha'], fixture.contentSha);
      expect(output['device'], _device);
      expect(output['android_api_level'], '35');
    });

    test('accepts the exact two frozen production repair bytes', () async {
      final fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      await _applyAcceptedProductionRepairs(fixture);

      final result = await _support(
        fixture.preflight(),
        environment: fixture.env(),
      );

      expect(result.exitCode, 0, reason: result.stderr.toString());
    });

    test('rejects tampering of any accepted repair file', () async {
      for (final repair in _acceptedRepairFiles) {
        final fixture = await FakeRepository.create();
        addTearDown(fixture.dispose);
        await _applyAcceptedProductionRepairs(fixture);
        File('${fixture.root.path}/${repair.path}').writeAsStringSync(
          'tampered\n',
        );
        await _mustGit(fixture.root, <String>['add', repair.path]);
        await _mustGit(
          fixture.root,
          <String>['commit', '-m', 'tamper accepted repair'],
        );

        final result = await _support(
          fixture.preflight(),
          environment: fixture.env(),
        );

        final expectedDiagnostic = _acceptedProductionRepairs.contains(repair)
            ? 'accepted production repair bytes'
            : 'accepted repair companion bytes';
        expect(result.exitCode, isNot(0), reason: repair.path);
        expect(
          result.stderr.toString(),
          contains(expectedDiagnostic),
          reason: repair.path,
        );
      }
    });

    test('rejects an arbitrary third production path', () async {
      final fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      await _applyAcceptedProductionRepairs(fixture);
      const path = 'lib/features/release_e2e_unapproved.dart';
      final file = File('${fixture.root.path}/$path');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('unapproved production change\n');
      await _mustGit(fixture.root, <String>['add', path]);
      await _mustGit(
        fixture.root,
        <String>['commit', '-m', 'third production path'],
      );

      final result = await _support(
        fixture.preflight(),
        environment: fixture.env(),
      );

      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('unapproved path: $path'));
    });

    test('keeps harness, docs, and workflow allowlist behavior', () async {
      final fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      await _commitAllowedHarnessDiffs(fixture);

      final result = await _support(
        fixture.preflight(),
        environment: fixture.env(),
      );

      expect(result.exitCode, 0, reason: result.stderr.toString());
    });

    test('rejects candidate mismatch and dirty source', () async {
      final fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      final unrelated = await Process.run(
        _git,
        <String>['commit-tree', 'HEAD^{tree}', '-m', 'unrelated'],
        workingDirectory: fixture.root.path,
      );
      expect(unrelated.exitCode, 0, reason: unrelated.stderr.toString());
      var result = await _support(
        fixture.preflight(candidateSha: unrelated.stdout.toString().trim()),
        environment: fixture.env(),
      );
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        contains('candidate is not an ancestor'),
      );

      File('${fixture.root.path}/unexpected.txt').writeAsStringSync('dirty');
      result = await _support(fixture.preflight(), environment: fixture.env());
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('worktree is not clean'));
    });

    test('rejects shipping hash and tracked prefix mismatch', () async {
      var fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      var result = await _support(
        fixture.preflight(expectedContentSha: '0' * 64),
        environment: fixture.env(),
      );
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('content SHA-256 mismatch'));

      fixture = await FakeRepository.create(prefix: '0' * 16);
      addTearDown(fixture.dispose);
      result = await _support(fixture.preflight(), environment: fixture.env());
      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        contains('tracked content seed version'),
      );
    });

    test('rejects wrong Flutter, Dart, JDK, Gradle, and AGP', () async {
      var fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      for (final entry in <Map<String, String>>[
        <String, String>{
          'kind': 'flutter',
          'value': '3.40.0',
          'message': 'Flutter 3.41.9',
        },
        <String, String>{
          'kind': 'dart',
          'value': '3.11.4',
          'message': 'Dart 3.11.5',
        },
        <String, String>{
          'kind': 'java',
          'value': '21.0.4',
          'message': 'JDK 17',
        },
        <String, String>{
          'kind': 'gradle',
          'value': '8.13',
          'message': 'Gradle 8.14',
        },
      ]) {
        final env = switch (entry['kind']) {
          'flutter' => fixture.env(flutter: entry['value']!),
          'dart' => fixture.env(dart: entry['value']!),
          'java' => fixture.env(java: entry['value']!),
          'gradle' => fixture.env(gradle: entry['value']!),
          _ => fixture.env(),
        };
        final result = await _support(fixture.preflight(), environment: env);
        expect(result.exitCode, isNot(0), reason: entry['kind']);
        expect(result.stderr.toString(), contains(entry['message']));
      }

      fixture = await FakeRepository.create(agp: '8.10.0');
      addTearDown(fixture.dispose);
      final result =
          await _support(fixture.preflight(), environment: fixture.env());
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('AGP 8.11.1'));
    });

    test('rejects missing Firebase CLI or ADB', () async {
      var fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      await File('${fixture.bin.path}/firebase').delete();
      var result =
          await _support(fixture.preflight(), environment: fixture.env());
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('firebase'));

      fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      await File('${fixture.bin.path}/adb').delete();
      result = await _support(fixture.preflight(), environment: fixture.env());
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('adb'));
    });

    test('rejects absent, unauthorized, offline, or ambiguous target',
        () async {
      final fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      for (final mode in <String>[
        'absent',
        'unauthorized',
        'offline',
        'ambiguous',
      ]) {
        final result = await _support(
          fixture.preflight(),
          environment: fixture.env(adbMode: mode),
        );
        expect(result.exitCode, isNot(0), reason: mode);
        expect(result.stderr.toString(), contains('ADB target'), reason: mode);
      }
    });

    test('rejects production credential or service indicators', () async {
      final fixture = await FakeRepository.create();
      addTearDown(fixture.dispose);
      for (final entry in <String, String>{
        'GOOGLE_APPLICATION_CREDENTIALS': '/tmp/key.json',
        'FIREBASE_TOKEN': 'token',
        'REVENUECAT_ANDROID_API_KEY': 'key',
        'PROD_FIREBASE_GOOGLE_SERVICES_JSON': '/tmp/prod.json',
      }.entries) {
        final result = await _support(
          fixture.preflight(),
          environment:
              fixture.env(extra: <String, String>{entry.key: entry.value}),
        );
        expect(result.exitCode, isNot(0), reason: entry.key);
        expect(
          result.stderr.toString(),
          contains('production credential/service indicator'),
        );
      }
    });
  });

  group('Firebase isolation and failure plumbing', () {
    test('requires demo project and loopback emulator hosts', () async {
      var result = await _support(<String>[
        'validate-emulator-isolation',
        '--project-id',
        'pantas-prod',
        '--auth-host',
        '127.0.0.1:9099',
        '--firestore-host',
        '127.0.0.1:8080',
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('demo-'));

      result = await _support(<String>[
        'validate-emulator-isolation',
        '--project-id',
        'demo-pantas-e2e',
        '--auth-host',
        'firebase.example.com:9099',
        '--firestore-host',
        '127.0.0.1:8080',
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('loopback'));
    });

    test('rejects occupied or duplicate emulator ports', () async {
      final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(socket.close);
      var result = await _support(<String>[
        'check-ports',
        '--auth-port',
        '${socket.port}',
        '--firestore-port',
        '${socket.port + 1}',
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('port collision'));

      result = await _support(<String>[
        'check-ports',
        '--auth-port',
        '19099',
        '--firestore-port',
        '19099',
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('distinct'));
    });

    test(
        'Firestore reset verifies empty top-level collections through '
        'supported listCollectionIds endpoint', () async {
      const projectId = 'demo-firestore-reset-list-collections';
      final stub = await _ResetEmulatorStub.start(
        projectId,
        allowLegacyFirestoreRootGet: false,
      );
      addTearDown(stub.close);

      final result = await _support(<String>[
        'reset-emulators',
        '--project-id',
        projectId,
        '--auth-port',
        '${stub.auth.port}',
        '--firestore-port',
        '${stub.firestore.port}',
      ]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(
        stub.firestoreRequests,
        contains(
          'POST /v1/projects/$projectId/databases/(default)/documents:listCollectionIds',
        ),
      );
      expect(
        stub.firestoreRequests,
        isNot(
          contains(
            'GET /v1/projects/$projectId/databases/(default)/documents?pageSize=1',
          ),
        ),
      );
      final postIndex = stub.firestoreRequests.indexWhere(
        (request) => request.startsWith('POST '),
      );
      expect(postIndex, greaterThanOrEqualTo(0));
      expect(
        jsonDecode(stub.firestoreBodies[postIndex]),
        <String, Object?>{'pageSize': 1},
      );
    });

    test('Firestore reset accepts explicit empty collectionIds', () async {
      const projectId = 'demo-firestore-reset-explicit-empty';
      final stub = await _ResetEmulatorStub.start(
        projectId,
        allowLegacyFirestoreRootGet: false,
        firestoreListBody: '{"collectionIds":[]}',
      );
      addTearDown(stub.close);

      final result = await _support(<String>[
        'reset-emulators',
        '--project-id',
        projectId,
        '--auth-port',
        '${stub.auth.port}',
        '--firestore-port',
        '${stub.firestore.port}',
      ]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
    });

    test(
        'Auth reset verifies empty accounts through supported '
        'batch-list endpoint', () async {
      const projectId = 'demo-auth-reset-regression';
      final stub = await _ResetEmulatorStub.start(projectId);
      addTearDown(stub.close);

      final result = await _support(<String>[
        'reset-emulators',
        '--project-id',
        projectId,
        '--auth-port',
        '${stub.auth.port}',
        '--firestore-port',
        '${stub.firestore.port}',
      ]);

      expect(result.exitCode, 0, reason: result.stderr.toString());
      expect(
        stub.authRequests,
        contains(
          'GET /identitytoolkit.googleapis.com/v1/projects/$projectId/accounts:batchGet?maxResults=1',
        ),
      );
      expect(
        stub.authRequests,
        isNot(contains('GET /emulator/v1/projects/$projectId/accounts')),
      );
      expect(stub.authAuthorizations, <String?>['Bearer owner']);
    });

    test('reset remains fail-closed when Auth still has accounts', () async {
      const projectId = 'demo-auth-reset-not-empty';
      final stub = await _ResetEmulatorStub.start(
        projectId,
        authHasUsers: true,
      );
      addTearDown(stub.close);

      final result = await _support(<String>[
        'reset-emulators',
        '--project-id',
        projectId,
        '--auth-port',
        '${stub.auth.port}',
        '--firestore-port',
        '${stub.firestore.port}',
      ]);

      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        contains('Firebase Auth emulator cleanup verification found accounts'),
      );
    });

    test('reset remains fail-closed when Firestore has top-level collections',
        () async {
      const projectId = 'demo-firestore-reset-regression';
      final stub = await _ResetEmulatorStub.start(
        projectId,
        firestoreCollectionIds: const <String>['leftover-collection'],
      );
      addTearDown(stub.close);

      final result = await _support(<String>[
        'reset-emulators',
        '--project-id',
        projectId,
        '--auth-port',
        '${stub.auth.port}',
        '--firestore-port',
        '${stub.firestore.port}',
      ]);

      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        contains('Firestore emulator cleanup verification found collections'),
      );
    });

    test('Firestore reset fails closed on non-2xx collection listing',
        () async {
      const projectId = 'demo-firestore-reset-list-failure';
      final stub = await _ResetEmulatorStub.start(
        projectId,
        allowLegacyFirestoreRootGet: false,
        firestoreListStatus: HttpStatus.internalServerError,
      );
      addTearDown(stub.close);

      final result = await _support(<String>[
        'reset-emulators',
        '--project-id',
        projectId,
        '--auth-port',
        '${stub.auth.port}',
        '--firestore-port',
        '${stub.firestore.port}',
      ]);

      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        contains('Firestore emulator cleanup verification failed'),
      );
    });

    test('Firestore reset fails closed on malformed collection listing JSON',
        () async {
      const projectId = 'demo-firestore-reset-list-malformed';
      final stub = await _ResetEmulatorStub.start(
        projectId,
        allowLegacyFirestoreRootGet: false,
        firestoreListBody: '{not-json',
      );
      addTearDown(stub.close);

      final result = await _support(<String>[
        'reset-emulators',
        '--project-id',
        projectId,
        '--auth-port',
        '${stub.auth.port}',
        '--firestore-port',
        '${stub.firestore.port}',
      ]);

      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        contains('Firestore emulator cleanup verification was not JSON'),
      );
    });

    test('Firestore reset fails closed on non-object collection listing JSON',
        () async {
      const projectId = 'demo-firestore-reset-list-non-object';
      final stub = await _ResetEmulatorStub.start(
        projectId,
        allowLegacyFirestoreRootGet: false,
        firestoreListBody: '[]',
      );
      addTearDown(stub.close);

      final result = await _support(<String>[
        'reset-emulators',
        '--project-id',
        projectId,
        '--auth-port',
        '${stub.auth.port}',
        '--firestore-port',
        '${stub.firestore.port}',
      ]);

      expect(result.exitCode, isNot(0));
      expect(
        result.stderr.toString(),
        contains('Firestore emulator cleanup verification was not an object'),
      );
    });

    test('bounded polling times out with predicate diagnostics', () async {
      final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(socket.close);
      final stopwatch = Stopwatch()..start();
      final result = await _support(<String>[
        'wait-port-free',
        '--port',
        '${socket.port}',
        '--deadline-ms',
        '100',
      ]);
      stopwatch.stop();
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('port to become free'));
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    });

    test('cleanup, diagnostics, and summary failures are fatal', () async {
      var result = await _support(<String>[
        'verify-pm-clear',
        '--output',
        'Failure',
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('pm clear'));

      final temp = await Directory.systemTemp.createTemp('release-e2e-fail-');
      addTearDown(() => temp.delete(recursive: true));
      final blocker = File('${temp.path}/blocker')..writeAsStringSync('file');
      result = await _support(<String>[
        'prepare-diagnostics',
        '--path',
        '${blocker.path}/child',
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('diagnostics'));

      final results = File('${temp.path}/results.jsonl')
        ..writeAsStringSync(
          '{"scenario":"shipping","outcome":"pass","runtime_seconds":1}\n',
        );
      result = await _support(<String>[
        'write-summary',
        '--results',
        results.path,
        '--json-output',
        '${blocker.path}/summary.json',
        '--text-output',
        '${blocker.path}/summary.txt',
        '--candidate',
        'a' * 40,
        '--content-sha',
        'b' * 64,
        '--device',
        _device,
        '--total-runtime-seconds',
        '1',
      ]);
      expect(result.exitCode, isNot(0));
      expect(result.stderr.toString(), contains('summary'));
    });

    test('redacts credentials and learner-payload-like fields', () async {
      const redactionInput =
          'Authorization: Bearer abc123 email=user@example.com '
          'apiKey=AIzaFake payload=answer';
      final result = await _support(<String>[
        'redact',
        '--text',
        redactionInput,
      ]);
      expect(result.exitCode, 0, reason: result.stderr.toString());
      final output = result.stdout.toString();
      expect(output, contains('[REDACTED]'));
      for (final secret in <String>[
        'abc123',
        'user@example.com',
        'AIzaFake',
        'payload=answer',
      ]) {
        expect(output, isNot(contains(secret)));
      }
    });
  });

  group('static runner and workflow contract', () {
    test('runner is strict, device-bound, deterministic, and sleep-free', () {
      final runner = File('tools/release/test_e2e.sh').readAsStringSync();
      expect(runner, contains('set -euo pipefail'));
      expect(runner, contains('export FLUTTER_SWIFT_PACKAGE_MANAGER=true'));
      expect(runner, isNot(contains('sleep ')));
      expect(
        runner,
        isNot(contains('0f69e79c9a13daaf7198eae62706f09dd9822ab5')),
      );
      expect(
        runner,
        isNot(
          contains(
            'eb3a9da425b80a51331cce74694ef014c3372392194bacbd60ba145db5ea2a45',
          ),
        ),
      );
      expect(runner, contains(r'adb -s "$device"'));
      expect(runner, contains(r'-d "$device"'));
      for (final scenario in <String>[
        'shipping_cold_start_e2e_test.dart',
        'quiz_state_e2e_test.dart',
        'mock_resume_e2e_test.dart',
        'delete_local_data_e2e_test.dart',
        'firebase_sync_roundtrip_e2e_test.dart',
        'firebase_conflict_isolation_e2e_test.dart',
      ]) {
        expect(runner, contains(scenario));
      }
      expect(runner, contains('write-summary'));
    });

    test('jobs.ci remains semantically unchanged and integration is absent',
        () async {
      final current = loadYaml(
        File('.github/workflows/main.yml').readAsStringSync(),
      ) as YamlMap;
      final baseResult = await Process.run(
        _git,
        <String>['show', '$_baseSha:.github/workflows/main.yml'],
      );
      expect(baseResult.exitCode, 0, reason: baseResult.stderr.toString());
      final base = loadYaml(baseResult.stdout.toString()) as YamlMap;
      final currentJobs = current['jobs'] as YamlMap;
      final baseJobs = base['jobs'] as YamlMap;
      expect(currentJobs.containsKey('ci'), isTrue);
      expect(currentJobs.containsKey('integration'), isFalse);
      expect(
        jsonEncode(_yamlValue(currentJobs['ci'])),
        jsonEncode(_yamlValue(baseJobs['ci'])),
      );
    });
  });
}
