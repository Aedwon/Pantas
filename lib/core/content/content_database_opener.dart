// coverage:ignore-file
import 'dart:io';

import 'package:pantas/core/content/content_database.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Which build of the corpus this app carries, re-exported so callers keep
/// importing one file. Written by the seed writer from the asset's own bytes,
/// because a hand-maintained version was missed by three content stages in a
/// row and then by a same-day rebuild.
export 'package:pantas/core/content/content_seed_version.dart';

const contentDbFileName = 'content.db';
Future<ContentDatabase> openContentDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final file = File(p.join(dir.path, contentDbFileName));
  return ContentDatabase(NativeDatabase.createInBackground(file));
}
