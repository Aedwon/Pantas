import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

// Copying some constants and logic from build_dev_seed.dart
const _examId = 'exam_upcat';
const _keepExamId = 'exam_cse_pro';

const _rosterExams = <Map<String, Object?>>[
  {
    'id': 'exam_acet',
    'code': 'ACET',
    'name': 'Ateneo College Entrance Test',
    'shortName': 'ACET',
    'language': 'en',
    'isActive': false,
  },
  {
    'id': 'exam_dlsucet',
    'code': 'DLSUCET',
    'name': 'De La Salle University College Admission Test',
    'shortName': 'DLSUCET',
    'language': 'en',
    'isActive': false,
  },
  {
    'id': 'exam_ustet',
    'code': 'USTET',
    'name': 'UST Entrance Test',
    'shortName': 'USTET',
    'language': 'en',
    'isActive': false,
  },
  {
    'id': 'exam_pupcet',
    'code': 'PUPCET',
    'name': 'PUP College Entrance Test',
    'shortName': 'PUPCET',
    'language': 'en',
    'isActive': false,
  },
  {
    'id': 'exam_cse_sub',
    'code': 'CSE_SUB',
    'name': 'Civil Service Examination: Subprofessional',
    'shortName': 'CSE Sub',
    'language': 'en',
    'isActive': false,
  },
];

void main(List<String> args) {
  if (args.isEmpty || args.length > 2) {
    stderr.writeln('Usage: build_content_export.dart <output.json> [root]');
    exit(64);
  }
  final root = args.length == 2 ? args[1] : '.';

  final outlineFile = File('$root/tools/lesson_author/outline.json');
  final outlineUpdatedAt = _getFileHashTimestamp(outlineFile);
  final outline =
      jsonDecode(outlineFile.readAsStringSync()) as Map<String, dynamic>;

  final topicIdBySlug = loadTopicIdBySlug(outline);

  final subjects = <Map<String, Object?>>[];
  final topics = <Map<String, Object?>>[];

  // Ordering runs per exam, so a subject that is second on its own paper does
  // not inherit a number from the exam listed before it.
  final subjectOrderByExam = <String, int>{};
  for (final rawSubject in outline['subjects'] as List) {
    final subject = rawSubject as Map<String, dynamic>;
    final subjectSlug = subject['slug'] as String;
    // Which paper a subject sits on. Absent means UPCAT, which is what every
    // subject in this outline meant before the field existed.
    final examCode = subject['exam'] as String? ?? 'upcat';
    final examId = 'exam_${_underscore(examCode)}';
    // The `upcat` in these ids is historical and is now just a namespace. It
    // stays because `track_scope_local` stores topic ids: a student who has
    // hidden a topic has that id on their device, and renaming would silently
    // un-hide it. Renaming is its own migration, not a side effect of this.
    final subjectId = 'subj_upcat_${_underscore(subjectSlug)}';
    subjects.add({
      '_id': subjectId,
      '_updatedAt': outlineUpdatedAt,
      'schemaVersion': 1,
      'isActive': true,
      'exam': {'_ref': examId},
      'name': subject['name'] as String,
      'ordering': (subjectOrderByExam[examId] =
          (subjectOrderByExam[examId] ?? 0) + 1),
    });

    var topicOrder = 1;
    for (final rawTopic in subject['topics'] as List) {
      final topic = rawTopic as Map<String, dynamic>;
      final topicSlug = topic['slug'] as String;
      final topicId = 'topic_upcat_${_underscore(topicSlug)}';
      topics.add({
        '_id': topicId,
        '_updatedAt': outlineUpdatedAt,
        'schemaVersion': 1,
        'isActive': true,
        'subject': {'_ref': subjectId},
        'name': topic['name'] as String,
        'ordering': topicOrder++,
      });
    }
  }

  final questions = buildQuestions(topicIdBySlug, root);
  final lessons = buildLessons(topicIdBySlug, root);

  // Keep the CSE demo exam and its rows; replace everything UPCAT.
  final existing = jsonDecode(
    File('$root/assets/seed/v1.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final keptExams = [
    for (final exam in existing['exams'] as List)
      if ((exam as Map<String, dynamic>)['id'] == _keepExamId) exam,
  ];
  final keptSubjectIds = {
    for (final exam in keptExams)
      for (final subject in exam['subjects'] as List)
        (subject as Map<String, dynamic>)['id'] as String,
  };
  final keptTopics = [
    for (final topic in existing['topics'] as List)
      if (keptSubjectIds.contains((topic as Map<String, dynamic>)['subjectId']))
        topic,
  ];
  final keptTopicIds = {
    for (final topic in keptTopics) topic['id'],
  };
  final keptQuestions = [
    for (final question in existing['questions'] as List)
      if (keptTopicIds.contains((question as Map<String, dynamic>)['topicId']))
        question,
  ];
  final keptPassages = [
    for (final passage in existing['passages'] as List? ?? []) passage,
  ];
  final keptLessons = [
    for (final lesson in existing['lessons'] as List)
      if (keptTopicIds.contains((lesson as Map<String, dynamic>)['topicId']))
        lesson,
  ];

  final v1UpdatedAt = _getFileHashTimestamp(File('$root/assets/seed/v1.json'));

  final examsOutput = <Map<String, Object?>>[];
  for (final exam in keptExams) {
    examsOutput.add({
      '_id': exam['id'],
      '_updatedAt': v1UpdatedAt,
      'schemaVersion': 1,
      'isActive': exam['isActive'] ?? true,
      'code': exam['code'],
      'name': exam['name'],
      'shortName': exam['shortName'],
      'language': exam['language'],
      'ordering': 1,
    });
    for (final subject
        in (exam['subjects'] as List).cast<Map<String, dynamic>>()) {
      subjects.add({
        '_id': subject['id'],
        '_updatedAt': v1UpdatedAt,
        'schemaVersion': 1,
        'isActive': true,
        'exam': {'_ref': exam['id']},
        'name': subject['name'],
        'ordering': subject['ordering'],
      });
    }
  }

  examsOutput.add({
    '_id': _examId,
    '_updatedAt': outlineUpdatedAt,
    'schemaVersion': 1,
    'isActive': true,
    'code': 'UPCAT',
    'name': 'UP College Admission Test',
    'shortName': 'UPCAT',
    'language': 'en',
    'ordering': 2,
  });

  for (final exam in _rosterExams) {
    examsOutput.add({
      '_id': exam['id'],
      '_updatedAt': outlineUpdatedAt,
      'schemaVersion': 1,
      'isActive': exam['isActive'],
      'code': exam['code'],
      'name': exam['name'],
      'shortName': exam['shortName'],
      'language': exam['language'],
      'ordering': 99,
    });
  }

  for (final topic in keptTopics) {
    topics.add({
      '_id': topic['id'],
      '_updatedAt': v1UpdatedAt,
      'schemaVersion': 1,
      'isActive': true,
      'subject': {'_ref': topic['subjectId']},
      'name': topic['name'],
      'ordering': topic['ordering'],
    });
  }

  for (final q in keptQuestions) {
    questions.add({
      '_id': q['id'],
      '_updatedAt': v1UpdatedAt,
      'schemaVersion': 1,
      'isActive': true,
      'topic': {'_ref': q['topicId']},
      if (q['lessonId'] != null) 'lesson': {'_ref': q['lessonId']},
      if (q['passageId'] != null) 'passage': {'_ref': q['passageId']},
      if (q['shortLabel'] != null) 'shortLabel': q['shortLabel'],
      if (q['figureSpec'] != null) 'figureSpec': q['figureSpec'],
      'examIds':
          (q['examIds'] as List? ?? []).map((id) => {'_ref': id}).toList(),
      'language': q['language'] ?? 'en',
      'stem': _textToPortableText(q['stem'] as String),
      'explanation': _textToPortableText(q['explanation'] as String),
      'version': q['version'] ?? 1,
      'choices': [
        for (final c in (q['choices'] as List).cast<Map<String, dynamic>>())
          {
            '_key': c['id'],
            'label': c['label'],
            'text': c['text'],
            'isCorrect': c['isCorrect'],
            // Note B. Omitted when absent so the document shape stays the
            // same as it was for every question authored before it existed.
            if (c['rationale'] != null) 'rationale': c['rationale'],
          },
      ],
    });
  }

  for (final l in keptLessons) {
    lessons.add({
      '_id': l['id'],
      '_updatedAt': v1UpdatedAt,
      'schemaVersion': 1,
      'isActive': true,
      'topic': {'_ref': l['topicId']},
      'title': l['title'],
      'summary': l['summary'],
      'estimatedMinutes': l['estimatedMinutes'],
      'ordering': l['ordering'] ?? 0,
      'body': l['bodyJson'],
    });
  }

  final passagesOutput = <Map<String, Object?>>[];
  for (final p in keptPassages) {
    passagesOutput.add({
      '_id': (p as Map<String, dynamic>)['id'],
      '_updatedAt': v1UpdatedAt,
      'schemaVersion': 1,
      'isActive': true,
      'topic': {'_ref': p['topicId']},
      'title': p['title'],
      'body': p['body'],
      'language': p['language'],
      'wordCount': p['wordCount'],
    });
  }

  final mockBlueprints = buildMockBlueprints(root);

  final seed = {
    'exam': examsOutput,
    'subject': subjects,
    'topic': topics,
    'passage': passagesOutput,
    'question': questions,
    'lesson': lessons,
    'mockBlueprint': mockBlueprints,
  };

  File(args[0]).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(seed)}\n',
  );
}

String _underscore(String slug) => slug.replaceAll('-', '_');

/// A stable `_updatedAt` derived from the file's contents.
///
/// **Not the wall clock and not the file's modification time.** Either makes
/// every document in every build look like it changed, which defeats the
/// incremental `_updatedAt > $since` sync this pipeline exists to allow. The
/// same content produces the same timestamp, so a rebuild that changes
/// nothing changes nothing.
///
/// It is a hash rendered as a date rather than a real instant, because the
/// parsers want ISO 8601 and nothing compares it to a calendar.
String _getFileHashTimestamp(File file) {
  final bytes = file.readAsBytesSync();
  final digest = sha256.convert(bytes);
  final hex = digest.toString().substring(0, 15);
  final ms = int.parse(hex, radix: 16) % 1000000000000;
  return DateTime.fromMillisecondsSinceEpoch(ms).toUtc().toIso8601String();
}

Map<String, String> loadTopicIdBySlug(Map<String, dynamic> outline) {
  final topicIdBySlug = <String, String>{};
  for (final rawSubject in outline['subjects'] as List) {
    final subject = rawSubject as Map<String, dynamic>;
    for (final rawTopic in subject['topics'] as List) {
      final topic = rawTopic as Map<String, dynamic>;
      final topicSlug = topic['slug'] as String;
      final topicId = 'topic_upcat_${_underscore(topicSlug)}';
      topicIdBySlug[topicSlug] = topicId;
    }
  }
  return topicIdBySlug;
}

List<Map<String, Object?>> buildQuestions(
  Map<String, String> topicIdBySlug,
  String root,
) {
  const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
  final questions = <Map<String, Object?>>[];
  var skippedFigures = 0;

  for (final file in _filesUnder('$root/content/questions', '.yaml')) {
    final updatedAt = _getFileHashTimestamp(file);
    final doc = loadYaml(file.readAsStringSync()) as YamlMap;
    final meta = doc['meta'] as YamlMap;
    final topicSlug = meta['topic'] as String;
    final subtopicSlug = meta['subtopic'] as String;
    final topicId = topicIdBySlug[topicSlug];
    if (topicId == null) {
      stderr.writeln('${file.path}: no outline topic for "$topicSlug"');
      exitCode = 65;
      continue;
    }
    final examIds = [
      for (final code in meta['exams'] as YamlList)
        'exam_${_underscore('$code')}',
    ];

    for (final raw in doc['questions'] as YamlList) {
      final question = raw as YamlMap;
      final figure = question['figure'];
      // A figure the app draws itself is not pending. Only the ones still
      // waiting on a hand-drawn picture are held back.
      final drawnSpec = question['figureSpec'];
      if (figure != null &&
          '$figure'.trim().isNotEmpty &&
          drawnSpec == null) {
        skippedFigures++;
        continue;
      }
      final id = question['id'] as String;
      final choices = (question['choices'] as YamlList)
          .cast<YamlMap>()
          .toList(growable: false);
      questions.add({
        '_id': id,
        '_updatedAt': updatedAt,
        'schemaVersion': 1,
        'isActive': true,
        'topic': {'_ref': topicId},
        'subtopic': {'_ref': 'subtopic_$subtopicSlug'},
        'lesson': {'_ref': 'lesson-$topicSlug-$subtopicSlug'},
        if (question['passage'] != null)
          'passage': {'_ref': question['passage']},
        if (question['shortLabel'] != null)
          'shortLabel': question['shortLabel'],
        if (question['figureSpec'] != null)
          'figureSpec': question['figureSpec'],
        'examIds': examIds.map((e) => {'_ref': e}).toList(),
        'language': 'en',
        'stem': _textToPortableText((question['stem'] as String).trim()),
        'explanation':
            _textToPortableText((question['explanation'] as String).trim()),
        'version': 1,
        'choices': [
          for (var i = 0; i < choices.length; i++)
            {
              '_key': '${id}_${labels[i].toLowerCase()}',
              'label': labels[i],
              'text': '${choices[i]['text']}'.trim(),
              'isCorrect': choices[i]['correct'] == true,
              if (choices[i]['rationale'] != null)
                'rationale': '${choices[i]['rationale']}'.trim(),
            },
        ],
      });
    }
  }

  stdout.writeln('  skipped $skippedFigures figure-pending questions');
  return questions;
}

List<Map<String, Object?>> buildLessons(
  Map<String, String> topicIdBySlug,
  String root,
) {
  final lessons = <Map<String, Object?>>[];

  final nextOrdering = <String, int>{};

  for (final file in _filesUnder('$root/content/lessons', '.md')) {
    final updatedAt = _getFileHashTimestamp(file);
    final source = file.readAsStringSync();
    final match =
        RegExp(r'^---\n(.*?)\n---\n', dotAll: true).firstMatch(source);
    if (match == null) {
      stderr.writeln('${file.path}: missing frontmatter');
      exitCode = 65;
      continue;
    }
    final front = loadYaml(match.group(1)!) as YamlMap;
    if (front['isActive'] == false) continue;

    final topicSlug = (front['topic'] as String).replaceFirst('topic-', '');
    final topicId = topicIdBySlug[topicSlug];
    if (topicId == null) {
      stderr.writeln('${file.path}: no outline topic for "$topicSlug"');
      exitCode = 65;
      continue;
    }
    final subtopicSlug =
        front['_id'].toString().replaceFirst('lesson-$topicSlug-', '');

    final fallback = (nextOrdering[topicId] ?? 0) + 1;
    nextOrdering[topicId] = fallback;

    lessons.add({
      '_id': front['_id'] as String,
      '_updatedAt': updatedAt,
      'schemaVersion': 1,
      'isActive': true,
      'topic': {'_ref': topicId},
      'subtopic': {'_ref': 'subtopic_$subtopicSlug'},
      'title': front['title'] as String,
      'summary': front['summary'] as String,
      'estimatedMinutes': front['estimatedMinutes'] as int,
      'ordering': front['ordering'] as int? ?? fallback,
      'body': _markdownToPortableText(source.substring(match.end)),
    });
  }

  return lessons;
}

List<Map<String, Object?>> _textToPortableText(String text) {
  return [
    {
      '_type': 'block',
      'style': 'normal',
      'children': [
        {
          '_type': 'span',
          'text': text,
          'marks': <String>[],
        }
      ],
    }
  ];
}

List<Map<String, Object?>> _markdownToPortableText(String body) {
  final blocks = <Map<String, Object?>>[];
  final paragraph = <String>[];
  final quote = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(_textBlock(paragraph.join(' '), 'normal'));
    paragraph.clear();
  }

  void flushQuote() {
    if (quote.isEmpty) return;
    blocks.add(_textBlock(quote.join(' '), 'blockquote'));
    quote.clear();
  }

  void flushAll() {
    flushParagraph();
    flushQuote();
  }

  final heading = RegExp(r'^(#{1,6})\s+(.*)$');
  final bullet = RegExp(r'^(\s*)[-*+]\s+(.*)$');
  final numbered = RegExp(r'^(\s*)\d+\.\s+(.*)$');
  final displayMath = RegExp(r'^\$\$(.*)\$\$$');

  for (final line in body.split('\n')) {
    final trimmed = line.trim();

    if (trimmed.isEmpty) {
      flushAll();
      continue;
    }
    if (trimmed.startsWith('<!--')) {
      flushAll();
      continue;
    }

    final math = displayMath.firstMatch(trimmed);
    if (math != null) {
      flushAll();
      blocks.add({'_type': 'latex', 'body': math.group(1)!.trim()});
      continue;
    }

    final headingMatch = heading.firstMatch(trimmed);
    if (headingMatch != null) {
      flushAll();
      blocks.add(
        _textBlock(headingMatch.group(2)!, 'h${headingMatch.group(1)!.length}'),
      );
      continue;
    }

    if (trimmed.startsWith('>')) {
      flushParagraph();
      quote.add(trimmed.replaceFirst(RegExp(r'^>\s*'), ''));
      continue;
    }

    final bulletMatch = bullet.firstMatch(line);
    if (bulletMatch != null) {
      flushAll();
      blocks.add(
        _textBlock(bulletMatch.group(2)!, 'normal')
          ..['listItem'] = 'bullet'
          ..['level'] = _indentLevel(bulletMatch.group(1)!),
      );
      continue;
    }

    final numberedMatch = numbered.firstMatch(line);
    if (numberedMatch != null) {
      flushAll();
      blocks.add(
        _textBlock(numberedMatch.group(2)!, 'normal')
          ..['listItem'] = 'number'
          ..['level'] = _indentLevel(numberedMatch.group(1)!),
      );
      continue;
    }

    flushQuote();
    paragraph.add(trimmed);
  }

  flushAll();
  return blocks;
}

int _indentLevel(String indent) => indent.length ~/ 2 + 1;

Map<String, Object?> _textBlock(String text, String style) => {
      '_type': 'block',
      'style': style,
      'children': _inlineSpans(text),
    };

final _inline = RegExp(r'\$([^$]+)\$|\*\*(.+?)\*\*|\*(.+?)\*');

List<Map<String, Object?>> _inlineSpans(String text) {
  final spans = <Map<String, Object?>>[];
  var cursor = 0;

  void addPlain(String value) {
    if (value.isEmpty) return;
    spans.add({'_type': 'span', 'text': value, 'marks': <String>[]});
  }

  for (final match in _inline.allMatches(text)) {
    addPlain(text.substring(cursor, match.start));
    final value = match.group(1) != null
        ? match.group(1)!
        : match.group(2) != null
            ? match.group(2)!
            : match.group(3)!;
    final mark = match.group(1) != null
        ? 'latex'
        : match.group(2) != null
            ? 'strong'
            : 'em';
    spans.add({
      '_type': 'span',
      'text': mark == 'latex' ? value.trim() : value,
      'marks': [mark],
    });
    cursor = match.end;
  }
  addPlain(text.substring(cursor));

  if (spans.isEmpty) addPlain('');
  return spans;
}

List<File> _filesUnder(String root, String extension) =>
    Directory(root).listSync(recursive: true).whereType<File>().where((file) {
      return file.path.endsWith(extension);
    }).toList()
      ..sort((a, b) => a.path.compareTo(b.path));

List<Map<String, Object?>> buildMockBlueprints(String root) {
  final mockBlueprints = <Map<String, Object?>>[];
  final mockDir = Directory('$root/content/mock');
  if (!mockDir.existsSync()) return mockBlueprints;

  for (final file in _filesUnder(mockDir.path, '.yaml')) {
    final updatedAt = _getFileHashTimestamp(file);
    final doc = loadYaml(file.readAsStringSync()) as YamlMap;
    mockBlueprints.add({
      '_id': doc['_id'] as String,
      '_updatedAt': updatedAt,
      'schemaVersion': doc['schemaVersion'] as int? ?? 2,
      'isActive': doc['isActive'] as bool? ?? true,
      'exam': {'_ref': doc['exam'] as String},
      'name': doc['name'] as String,
      'durationMinutes': doc['durationMinutes'] as int,
      if (doc['sectionalTiming'] != null)
        'sectionalTiming': doc['sectionalTiming'] as String,
      if (doc['totalPublishedItems'] != null)
        'totalPublishedItems': doc['totalPublishedItems'] as int,
      if (doc['source'] != null) 'source': doc['source'] as String,
      if (doc['sourceNote'] != null) 'sourceNote': doc['sourceNote'] as String,
      if (doc['scoreBands'] != null)
        'scoreBands': _convertYaml(doc['scoreBands']),
      'sections': [
        for (final section in doc['sections'] as YamlList)
          _convertYaml(section),
      ],
    });
  }

  return mockBlueprints;
}

Object? _convertYaml(Object? node) {
  if (node is YamlMap) {
    return {
      for (final entry in node.entries)
        '${entry.key}': _convertYaml(entry.value),
    };
  }
  if (node is YamlList) {
    return [for (final item in node) _convertYaml(item)];
  }
  return node;
}
