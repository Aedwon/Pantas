import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  final out = StringBuffer(), key = StringBuffer();
  final rnd = Random(20261117);
  final files = Directory('content/types').listSync(recursive: true)
      .whereType<File>().where((f) => f.path.endsWith('.variants.yaml')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final vf in files) {
    final tf = File(vf.path.replaceFirst('.variants.yaml', '.yaml'));
    final t = loadYaml(tf.readAsStringSync()) as YamlMap;
    final vs = (loadYaml(vf.readAsStringSync()) as YamlMap)['variants'] as YamlList;
    final picks = <int>{0};
    while (picks.length < 5) { picks.add(1 + rnd.nextInt(vs.length - 1)); }
    for (final i in picks.toList()..sort()) {
      final v = jsonDecode(jsonEncode(vs[i])) as Map<String, dynamic>;
      final slots = (v['slots'] as Map?) ?? {};
      var stem = t['stem'] as String;
      slots.forEach((k, val) => stem = stem.replaceAll('{$k}', '$val'));
      final id = '${t['id']}#$i';
      out.writeln('### $id\n\nQuestion: ${stem.trim()}\n');
      if (v['figureSpec'] != null) out.writeln('Shown figure data: ${jsonEncode(v['figureSpec'])}\n');
      final choices = [...(v['choices'] as List)]..shuffle(Random(id.hashCode));
      for (var c = 0; c < choices.length; c++) {
        final ch = choices[c] as Map;
        final fig = ch['figure'] == null ? '' : '  figure: ${jsonEncode(ch['figure'])}';
        out.writeln('${String.fromCharCode(65 + c)}. ${ch['text']}$fig');
        if (ch['correct'] == true) key.writeln('$id ${String.fromCharCode(65 + c)}');
      }
      out.writeln();
    }
  }
  File(args[0]).writeAsStringSync(out.toString());
  File(args[1]).writeAsStringSync(key.toString());
}
