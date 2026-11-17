// Tool libraries live outside the root package lib directory.
// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import '../lib/src/check/files.dart';

void main(List<String> args) {
  var types = 'content/types';
  var heldTypes = 'content/types-held';
  var questionsRef = '646326517';
  try {
    for (var i = 0; i < args.length; i += 2) {
      if (i + 1 >= args.length) {
        throw const FormatException('missing option value');
      }
      switch (args[i]) {
        case '--types':
          types = args[i + 1];
        case '--held-types':
          heldTypes = args[i + 1];
        case '--questions-ref':
          questionsRef = args[i + 1];
        default:
          throw FormatException('unknown option ${args[i]}');
      }
    }
    if (!Directory(types).existsSync() && !Directory(heldTypes).existsSync()) {
      stdout.writeln(
        'Generator checker: no content/types/ directory ($types); skipped.',
      );
      return;
    }
    final failures = checkTypeFiles(
      root: Directory.current.path,
      typesPath: types,
      questionsRef: questionsRef,
    )..addAll(
        checkTypeFiles(
          root: Directory.current.path,
          typesPath: heldTypes,
          held: true,
          questionsRef: questionsRef,
        ),
      );
    for (final failure in failures) {
      stderr.writeln(failure);
    }
    exitCode = failures.isEmpty ? 0 : 1;
  } on Object catch (error) {
    stderr.writeln('checker #0 input: $error');
    exitCode = 1;
  }
}
