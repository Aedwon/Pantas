// One-off, kept for the record: swaps the framework's material import in
// lib/features and lib/app for the design-system import (guardrails layer 1).
// Run from the project root: dart run tool/swap_material_import.dart
import 'dart:io';

void main() {
  const from = "import 'package:flutter/material.dart';";
  const to = "import 'package:pantas/core/ui/ds.dart';";
  var count = 0;
  for (final dir in ['lib/features', 'lib/app']) {
    for (final e in Directory(dir).listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      final src = e.readAsStringSync();
      if (!src.contains(from)) continue;
      e.writeAsStringSync(src.replaceFirst(from, to));
      count++;
    }
  }
  stdout.writeln('swapped $count file(s)');
}
