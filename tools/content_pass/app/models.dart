/// One thing to review, as the server's manifest lists it.
class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.kind,
    required this.file,
    required this.title,
    required this.exams,
    required this.hash,
    required this.order,
    this.lessonId,
    this.seq,
    this.cantShow,
  });

  factory ReviewItem.fromJson(Map<String, Object?> json) => ReviewItem(
        id: json['id']! as String,
        kind: json['kind']! as String,
        file: json['file']! as String,
        title: json['title']! as String,
        exams: [for (final e in json['exams']! as List) e as String],
        hash: json['hash']! as String,
        order: json['order']! as int,
        lessonId: json['lessonId'] as String?,
        seq: json['seq'] as int?,
        cantShow: json['cantShow'] as String?,
      );

  final String id;

  /// `lesson`, `question`, `mock` or `figure`.
  final String kind;
  final String file;
  final String title;
  final List<String> exams;
  final String hash;
  final int order;
  final String? lessonId;
  final int? seq;
  final String? cantShow;
}

const tagNames = ['wrong_answer', 'wording', 'figure', 'layout', 'other'];
const tagLabels = ['Wrong answer', 'Wording', 'Figure', 'Layout', 'Other'];

/// What was noted about one item.
class NoteRecord {
  const NoteRecord({
    required this.id,
    this.tags = const [],
    this.comment = '',
    this.status = 'not_reviewed',
    this.previous,
    this.changed = false,
  });

  factory NoteRecord.fromJson(Map<String, Object?> json) => NoteRecord(
        id: json['id']! as String,
        tags: [for (final t in (json['tags'] as List? ?? const [])) '$t'],
        comment: '${json['comment'] ?? ''}',
        status: '${json['status'] ?? 'not_reviewed'}',
        previous: json['previous'] == null
            ? null
            : Map<String, Object?>.from(json['previous']! as Map),
        changed: json['changed'] == true,
      );

  final String id;
  final List<String> tags;
  final String comment;

  /// `not_reviewed`, `looks_good` or `tagged`.
  final String status;

  /// The earlier answer, kept when the item changed and went back.
  final Map<String, Object?>? previous;
  final bool changed;
}
