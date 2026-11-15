import 'dart:convert';
import 'dart:io';

/// Read a ledger without treating an absent file as an approval.
Map<String, Map<String, Object?>> readLedger(File file) {
  if (!file.existsSync()) return {};
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  return decoded.map(
    (id, value) => MapEntry(id, Map<String, Object?>.from(value! as Map)),
  );
}

/// Write stable key order, preserving strings such as evidence paths verbatim.
void writeLedger(File file, Map<String, Map<String, Object?>> entries) {
  final ordered = <String, Object?>{
    for (final id in entries.keys.toList()..sort())
      id: {
        for (final key in entries[id]!.keys.toList()..sort())
          key: entries[id]![key],
      },
  };
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(ordered)}\n',
  );
}
