// Enforces architectural import rules from spec §5.2.
//
// Rules:
//   R1: lib/core/** must NOT import from lib/features/**
//   R2: lib/features/X/** must NOT import another feature's presentation.
//       A screen composed of what other features measure is the normal
//       direction: Home reads what Progress computes, everything reads
//       entitlement and settings. What tangles two features is one reaching
//       into the other's screens and screen state. So a cross-feature import
//       is allowed only when it names a layer directory other than
//       presentation, which also rules out a feature's barrel: barrels
//       re-export presentation and exist for lib/app/router.dart.
//   R3: lib/**/domain/** must NOT import flutter, firebase_*, drift, dio,
//       sqlite3_*, sqlcipher_*, path_provider, flutter_secure_storage,
//       google_sign_in, sign_in_with_apple, purchases_flutter,
//       cloud_firestore, firebase_auth, cloud_functions
//
//   R4: lib/features/** and lib/app/** must NOT import
//       package:flutter/material.dart or package:flutter/cupertino.dart.
//       They import package:pantas/core/ui/ds.dart, which hides the raw
//       controls (guardrails layer 1).
//   R5: a screen (lib/features/**, lib/app/**) that imports
//       package:pantas/core/ui/raw_controls.dart must carry
//       `// ds-raw: <reason>` with a non-empty reason, on the import line or
//       on the line directly above it.
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
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('lib/ not found; run from project root.');
    exit(2);
  }

  final sources = <String, String>{};
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.g.dart') ||
        entity.path.endsWith('.freezed.dart') ||
        entity.path.endsWith('.config.dart')) {
      continue;
    }
    sources[entity.path.replaceAll(r'\', '/')] = entity.readAsStringSync();
  }

  final violations = findLayeringViolations(sources);
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

const _rawControlsImport = 'package:pantas/core/ui/raw_controls.dart';
const _bannedFrameworkImports = <String>{
  'package:flutter/material.dart',
  'package:flutter/cupertino.dart',
};
final _rawMarker = RegExp(r'//\s*ds-raw:\s*\S');

/// Every violation in [sources], a map of project-relative path (for example
/// `lib/features/quiz/quiz_page.dart`) to file text.
List<String> findLayeringViolations(Map<String, String> sources) {
  final violations = <String>[];
  for (final entry in sources.entries) {
    final relPath = entry.key;
    final src = entry.value;
    final imports = _importRegex
        .allMatches(src)
        .map((m) => m.group(1)!)
        .toList(growable: false);

    final inCore = relPath.startsWith('lib/core/');
    final inFeatures = relPath.startsWith('lib/features/');
    final inScreens = inFeatures || relPath.startsWith('lib/app/');
    final inDomain = relPath.contains('/domain/');
    final featurePrefix = inFeatures ? _featureName(relPath) : null;

    for (final imp in imports) {
      // R1: core must not import features
      if (inCore && imp.contains('package:pantas/features/')) {
        violations.add('R1 $relPath imports $imp');
      }

      // R2: features must not import another feature's presentation
      if (inFeatures && imp.startsWith('package:pantas/features/')) {
        final importedFeature = _featureFromImport(imp);
        final layer = _importedLayer(imp);
        if (importedFeature != null &&
            importedFeature != featurePrefix &&
            (layer == null || layer == 'presentation')) {
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

      // R4: screens take the design-system import, not the framework's
      if (inScreens && _bannedFrameworkImports.contains(imp)) {
        violations.add(
          'R4 $relPath imports $imp; import '
          'package:pantas/core/ui/ds.dart',
        );
      }
    }

    // R5: the raw-controls escape needs a written reason
    if (inScreens) {
      final lines = src.split('\n');
      for (var i = 0; i < lines.length; i++) {
        if (!lines[i].contains(_rawControlsImport)) continue;
        if (!_importRegex.hasMatch(lines[i])) continue;
        final above = i > 0 ? lines[i - 1].trim() : '';
        final marked = _rawMarker.hasMatch(lines[i]) ||
            (above.startsWith('//') && _rawMarker.hasMatch(above));
        if (!marked) {
          violations.add(
            'R5 $relPath imports raw_controls.dart without '
            '`// ds-raw: <reason>`',
          );
        }
      }
    }
  }
  return violations;
}

String? _featureName(String relPath) {
  final m = RegExp('^lib/features/([^/]+)/').firstMatch(relPath);
  return m?.group(1);
}

String? _featureFromImport(String imp) {
  final m = RegExp('^package:pantas/features/([^/]+)/').firstMatch(imp);
  return m?.group(1);
}

/// The layer directory a cross-feature import names, or null when it names
/// none. A barrel (`features/quiz/quiz.dart`) names none, and re-exports
/// presentation, so null is treated the same as presentation by R2.
String? _importedLayer(String imp) {
  final m = RegExp('^package:pantas/features/[^/]+/([^/]+)/').firstMatch(imp);
  return m?.group(1);
}

String? _packageOf(String imp) {
  final m = RegExp('^package:([^/]+)/').firstMatch(imp);
  return m?.group(1);
}
