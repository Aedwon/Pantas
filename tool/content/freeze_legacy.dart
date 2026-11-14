import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'ledger.dart';
import 'question_hash.dart';
import 'shipping_questions.dart';

void main(List<String> args) {
  if (args.length != 2 ||
      args.first != '--root' ||
      !Directory(args[1]).existsSync()) {
    stderr.writeln(
      'Usage: dart run tool/content/freeze_legacy.dart --root <content dir>',
    );
    exitCode = 2;
    return;
  }
  try {
    final file = File(p.join(args[1], 'question-ledger', 'legacy.json'));
    if (file.existsSync()) {
      throw const FileSystemException(
        'legacy.json already exists; refusing to overwrite',
      );
    }
    final questions = shippingQuestions(args[1]);
    writeLedger(file, {
      for (final q in questions)
        q.id: {
          'hash': questionHash(q.question, q.meta),
          'lesson': questionLesson(q.question, q.meta),
          'yamlApproved': q.question['approved'] == true,
        },
    });
    final approvedCount =
        questions.where((q) => q.question['approved'] == true).length;
    stdout
      ..writeln(
        'total: ${questions.length}, yamlApproved true: $approvedCount, '
        'false: ${questions.length - approvedCount}',
      )
      ..writeln(sha256.convert(file.readAsBytesSync()));
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}
