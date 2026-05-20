// coverage:ignore-file
import 'dart:io';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const contentDbFileName = 'content.db';

Future<ContentDatabase> openContentDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, contentDbFileName));
  return ContentDatabase(NativeDatabase.createInBackground(file));
}
