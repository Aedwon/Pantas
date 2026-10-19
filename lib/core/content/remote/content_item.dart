import 'package:meta/meta.dart';

enum ContentKind {
  lessons,
  questions,

  /// The structure of the content (exams, subjects, topics, lesson rows
  /// without text, question index rows). Ids and format: `web/README.md`.
  catalog;

  /// The value the `getContent` callable expects.
  String get wire => name;
}

/// One lesson or question set as the server sent it.
///
/// `tier` is the account tier the copy was built for ('free' or 'pro'). The
/// server also puts it at the end of `version`, so a Free copy never counts
/// as current for a Pro account.
@immutable
class ContentItem {
  const ContentItem({
    required this.kind,
    required this.id,
    required this.version,
    required this.tier,
    required this.data,
  });

  final ContentKind kind;
  final String id;
  final String version;
  final String tier;
  final Map<String, Object?> data;
}
