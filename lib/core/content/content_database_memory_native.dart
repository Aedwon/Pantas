import 'package:drift/native.dart';
import 'package:pantas/core/content/content_database.dart';

/// Only the web build uses this. Native builds read the bundled database.
Future<ContentDatabase> openInMemoryContentDatabase() async =>
    ContentDatabase(NativeDatabase.memory());
