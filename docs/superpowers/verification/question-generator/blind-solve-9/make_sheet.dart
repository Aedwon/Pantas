// Blind solve 9: matrix-ray-intersection after the held2 fix stage.
// Picks index 0, the two audit examples (43, 46) and two seeded picks.
// Run from the repository root:
//   dart run docs/superpowers/verification/question-generator/blind-solve-9/make_sheet.dart <sheet.md> <key.txt>
// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:yaml/yaml.dart';

void main(List<String> args) {
  const base =
      'content/types-held/reasoning/spatial-abstract-reasoning/matrix-keeping-shared-features/qt-spatial-abstract-reasoning-matrix-ray-intersection';
  final out = StringBuffer();
  final key = StringBuffer();
  final t = loadYaml(File('$base.yaml').readAsStringSync()) as YamlMap;
  final vs =
      (loadYaml(File('$base.variants.yaml').readAsStringSync()) as YamlMap)['variants']
          as YamlList;
  final rnd = Random(20261128);
  final picks = <int>{0, 43, 46};
  while (picks.length < 5) {
    picks.add(1 + rnd.nextInt(vs.length - 1));
  }
  for (final i in picks.toList()..sort()) {
    final v = jsonDecode(jsonEncode(vs[i])) as Map<String, dynamic>;
    final slots = (v['slots'] as Map?) ?? {};
    var stem = t['stem'] as String;
    slots.forEach((k, val) => stem = stem.replaceAll('{$k}', '$val'));
    final id = '${t['id']}#$i';
    out.writeln('### $id\n\nQuestion: ${stem.trim()}\n');
    out.writeln('Shown figure data: ${jsonEncode(v['figureSpec'])}\n');
    final choices = [...(v['choices'] as List)]..shuffle(Random(i * 7919 + 13));
    for (var c = 0; c < choices.length; c++) {
      final ch = choices[c] as Map;
      final fig =
          ch['figure'] == null ? '' : '  figure: ${jsonEncode(ch['figure'])}';
      final letter = String.fromCharCode(65 + c);
      out.writeln('$letter. ${ch['text']}$fig');
      if (ch['correct'] == true) key.writeln('$id $letter');
    }
    out.writeln();
  }
  File(args[0]).writeAsStringSync(out.toString());
  File(args[1]).writeAsStringSync(key.toString());
}
