// Enforces architectural import rules from spec §5.2.
//
// Rules:
//   R1: lib/core/** must NOT import from lib/features/**
//   R2: lib/features/X/** must NOT import from lib/features/Y/** (X != Y)
//   R3: lib/**/domain/** must NOT import flutter, firebase_*, drift, dio,
//       sqlite3_*, sqlcipher_*, path_provider, flutter_secure_storage,
//       google_sign_in, sign_in_with_apple, purchases_flutter,
//       cloud_firestore, firebase_auth, cloud_functions
//
// Exit code: 0 if clean, 1 if any violation (lists all violations first).
import 'dart:io';

const _domainForbiddenPackages = <String>{
  'flutter',
  'flutter_localizations',
  'flutter_riverpod',
  'riverpod_annotation',
  'go_router',
  'firebase_core',
  'firebase_auth',
  'cloud_firestore',
  'firebase_analytics',
  'firebase_crashlytics',
  'firebase_remote_config',
  'firebase_messaging',
  'firebase_app_check',
  'cloud_functions',
  'drift',
  'drift_dev',
  'sqlite3_flutter_libs',
  'sqlcipher_flutter_libs',
  'path_provider',
  'dio',
  'flutter_secure_storage',
  'google_sign_in',
  'sign_in_with_apple',
  'purchases_flutter',
};

final _importRegex = RegExp(
  r'''^\s*import\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main(List<String> args) {
  final violations = <String>[];
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('lib/ not found; run from project root.');
    exit(2);
  }

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.g.dart') ||
        entity.path.endsWith('.freezed.dart') ||
        entity.path.endsWith('.config.dart')) {
      continue;
    }

    final relPath = entity.path.replaceAll(r'\', '/');
    final src = entity.readAsStringSync();
    final imports = _importRegex
        .allMatches(src)
        .map((m) => m.group(1)!)
        .toList(growable: false);

    final inCore = relPath.startsWith('lib/core/');
    final inFeatures = relPath.startsWith('lib/features/');
    final inDomain = relPath.contains('/domain/');
    final featurePrefix = inFeatures ? _featureName(relPath) : null;

    for (final imp in imports) {
      // R1: core must not import features
      if (inCore && imp.contains('package:cse_cet_reviewer/features/')) {
        violations.add('R1 $relPath imports $imp');
      }

      // R2: features must not cross-import
      if (inFeatures && imp.startsWith('package:cse_cet_reviewer/features/')) {
        final importedFeature = _featureFromImport(imp);
        if (importedFeature != null && importedFeature != featurePrefix) {
          violations.add('R2 $relPath imports $imp');
        }
      }

      // R3: domain must be pure Dart
      if (inDomain) {
        final pkg = _packageOf(imp);
        if (pkg != null && _domainForbiddenPackages.contains(pkg)) {
          violations.add('R3 $relPath imports $imp');
        }
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('check_layering: OK');
    exit(0);
  }
  stderr.writeln('check_layering: ${violations.length} violation(s)');
  for (final v in violations) {
    stderr.writeln('  $v');
  }
  exit(1);
}

String? _featureName(String relPath) {
  final m = RegExp('^lib/features/([^/]+)/').firstMatch(relPath);
  return m?.group(1);
}

String? _featureFromImport(String imp) {
  final m =
      RegExp('^package:cse_cet_reviewer/features/([^/]+)/').firstMatch(imp);
  return m?.group(1);
}

String? _packageOf(String imp) {
  final m = RegExp('^package:([^/]+)/').firstMatch(imp);
  return m?.group(1);
}
