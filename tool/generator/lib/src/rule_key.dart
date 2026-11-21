import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'model.dart';

/// Choice construction metadata does not define the student's task. Keep this
/// boundary shared by generation, independent checking and capacity reports.
String taskRuleKey(String rule, Map<String, Object?> parameters) {
  final task = Map<String, Object?>.of(parameters);
  if (rule.startsWith('series-') || rule.startsWith('matrix-')) {
    task.remove('extraForm');
  }
  if (rule.startsWith('net-')) task.remove('profile');
  return sha256.convert(utf8.encode(canonicalJson(task))).toString();
}
