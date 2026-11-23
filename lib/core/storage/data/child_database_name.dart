import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// The name of one child's own on-device store: a hash of the child's uid, so
/// the file name never holds the uid itself (under-13 plan, Decision 9 item 1).
Future<String> childDatabaseName(String uid) async {
  final digest = await Sha256().hash(utf8.encode(uid));
  final suffix = base64Url.encode(digest.bytes).replaceAll('=', '');
  return 'pantas-child-$suffix';
}
