// Builds assets/seed/v1.json from the authored corpus under content/ so the
// running app shows real questions and lessons instead of the demo rows.
//
// Temporary dev tool: the app's shipping content path is the Sanity ->
// content.db pipeline, which no UI reads yet. This fills the v1 seed the
// AppDatabase actually loads, for UI/UX work against real content.
//
// Usage: dart run tools/build_dev_seed/build_dev_seed.dart
//
// DO NOT COMMIT the assets/seed/v1.json this writes. That file is a shipping
// asset — the app bundles it and seeds from it — and the committed version is
// deliberately the small 2-subject demo seed. Two expectations in
// test/core/storage/data/seeder_test.dart assert that shape, so committing the
// generated seed turns the suite red and puts scaffolding content into the
// build. Regenerate locally whenever you need it; discard with
// `git checkout -- assets/seed/v1.json`.

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

const _examId = 'exam_upcat';
const _keepExamId = 'exam_cse_pro';

// The post-launch expansion roster from the foundation spec §1.2, carried in
// the dev seed so exam-list surfaces have realistic data to hold. They ship
// `isActive: false` because nothing is authored behind them — selecting one
// would land on an app with no subjects, topics, questions, or lessons. This
// mirrors production, where an exam goes active only when its content pack
// does. Flip an entry to `true` to see it in the onboarding picker.
const _rosterExams = <Map<String, Object?>>[
  {
    'id': 'exam_acet',
    'code': 'ACET',
    'name': 'Ateneo College Entrance Test',
    'shortName': 'ACET',
    'language': 'en',
    'isActive': false,
    'subjects': <Map<String, Object?>>[],
  },
  {
    'id': 'exam_dlsucet',
    'code': 'DLSUCET',
    'name': 'De La Salle University College Admission Test',
    'shortName': 'DLSUCET',
    'language': 'en',
    'isActive': false,
    'subjects': <Map<String, Object?>>[],
  },
  {
    'id': 'exam_ustet',
    'code': 'USTET',
    'name': 'UST Entrance Test',
    'shortName': 'USTET',
    'language': 'en',
    'isActive': false,
    'subjects': <Map<String, Object?>>[],
  },
  {
    'id': 'exam_pupcet',
    'code': 'PUPCET',
    'name': 'PUP College Entrance Test',
    'shortName': 'PUPCET',
    'language': 'en',
    'isActive': false,
    'subjects': <Map<String, Object?>>[],
  },
  {
    'id': 'exam_cse_sub',
    'code': 'CSE_SUB',
    'name': 'Civil Service Examination — Subprofessional',
    'shortName': 'CSE Sub',
    'language': 'en',
    'isActive': false,
    'subjects': <Map<String, Object?>>[],
  },
];

void main() {
  final outline = jsonDecode(
    File('tools/lesson_author/outline.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  final subjects = <Map<String, Object?>>[];
  final topics = <Map<String, Object?>>[];
  final topicIdBySlug = <String, String>{};

  var subjectOrder = 1;
  for (final rawSubject in outline['subjects'] as List) {
    final subject = rawSubject as Map<String, dynamic>;
    final subjectSlug = subject['slug'] as String;
    final subjectId = 'subj_upcat_${_underscore(subjectSlug)}';
    subjects.add({
      'id': subjectId,
      'examId': _examId,
      'name': subject['name'] as String,
      'ordering': subjectOrder++,
    });

    var topicOrder = 1;
    for (final rawTopic in subject['topics'] as List) {
      final topic = rawTopic as Map<String, dynamic>;
      final topicSlug = topic['slug'] as String;
      final topicId = 'topic_upcat_${_underscore(topicSlug)}';
      topicIdBySlug[topicSlug] = topicId;
      topics.add({
        'id': topicId,
        'subjectId': subjectId,
        'name': topic['name'] as String,
        'ordering': topicOrder++,
      });
    }
  }

  final questions = _buildQuestions(topicIdBySlug);
  final lessons = _buildLessons(topicIdBySlug);

  // Keep the CSE demo exam and its rows; replace everything UPCAT.
  final existing = jsonDecode(
    File('assets/seed/v1.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final keptExams = [
    for (final exam in existing['exams'] as List)
      if ((exam as Map<String, dynamic>)['id'] == _keepExamId) exam,
  ];
  final keptSubjectIds = {
    for (final exam in keptExams)
      for (final subject in (exam as Map<String, dynamic>)['subjects'] as List)
        (subject as Map<String, dynamic>)['id'] as String,
  };
  final keptTopics = [
    for (final topic in existing['topics'] as List)
      if (keptSubjectIds.contains(
        (topic as Map<String, dynamic>)['subjectId'],
      ))
        topic,
  ];
  final keptTopicIds = {
    for (final topic in keptTopics) (topic as Map<String, dynamic>)['id'],
  };
  final keptQuestions = [
    for (final question in existing['questions'] as List)
      if (keptTopicIds.contains(
        (question as Map<String, dynamic>)['topicId'],
      ))
        question,
  ];
  final keptLessons = [
    for (final lesson in existing['lessons'] as List)
      if (keptTopicIds.contains((lesson as Map<String, dynamic>)['topicId']))
        lesson,
  ];

  final seed = {
    'schemaVersion': 1,
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'exams': [
      ...keptExams,
      {
        'id': _examId,
        'code': 'UPCAT',
        'name': 'UP College Admission Test',
        'shortName': 'UPCAT',
        'language': 'en',
        'isActive': true,
        'subjects': subjects,
      },
      ..._rosterExams,
    ],
    'topics': [...keptTopics, ...topics],
    'questions': [...keptQuestions, ...questions],
    'lessons': [...keptLessons, ...lessons],
  };

  File('assets/seed/v1.json').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(seed)}\n');

  stdout.writeln('Wrote assets/seed/v1.json');
  stdout.writeln('  subjects:  ${subjects.length}');
  stdout.writeln('  topics:    ${topics.length}');
  stdout.writeln(
      '  questions: ${questions.length} (+${keptQuestions.length} kept)');
  stdout
      .writeln('  lessons:   ${lessons.length} (+${keptLessons.length} kept)');
}

String _underscore(String slug) => slug.replaceAll('-', '_');

// --- questions ---------------------------------------------------------

List<Map<String, Object?>> _buildQuestions(Map<String, String> topicIdBySlug) {
  const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
  final questions = <Map<String, Object?>>[];
  var skippedFigures = 0;

  for (final file in _filesUnder('content/questions', '.yaml')) {
    final doc = loadYaml(file.readAsStringSync()) as YamlMap;
    final meta = doc['meta'] as YamlMap;
    final topicSlug = meta['topic'] as String;
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
      if (figure != null && '$figure'.trim().isNotEmpty) {
        skippedFigures++;
        continue;
      }
      final id = question['id'] as String;
      final choices = (question['choices'] as YamlList)
          .cast<YamlMap>()
          .toList(growable: false);
      questions.add({
        'id': id,
        'version': 1,
        'examIds': examIds,
        'topicId': topicId,
        'language': 'en',
        'stem': (question['stem'] as String).trim(),
        'choices': [
          for (var i = 0; i < choices.length; i++)
            {
              'id': '${id}_${labels[i].toLowerCase()}',
              'label': labels[i],
              'text': '${choices[i]['text']}'.trim(),
              'isCorrect': choices[i]['correct'] == true,
            },
        ],
        'explanation': (question['explanation'] as String).trim(),
      });
    }
  }

  stdout.writeln('  skipped $skippedFigures figure-pending questions');
  return questions;
}

// --- lessons -----------------------------------------------------------

List<Map<String, Object?>> _buildLessons(Map<String, String> topicIdBySlug) {
  final lessons = <Map<String, Object?>>[];

  for (final file in _filesUnder('content/lessons', '.md')) {
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

    lessons.add({
      'id': front['_id'] as String,
      'topicId': topicId,
      'title': front['title'] as String,
      'summary': front['summary'] as String,
      'estimatedMinutes': front['estimatedMinutes'] as int,
      'bodyJson': _markdownToPortableText(source.substring(match.end)),
    });
  }

  return lessons;
}

/// Converts the lesson markdown subset the corpus uses into the Portable Text
/// blocks [PortableTextRenderer] understands.
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
    // Illustration placeholders mark art that has not been drawn yet.
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

/// Splits `$math$`, `**strong**` and `*em*` out of a line into marked spans.
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
    final (value, mark) = switch (match) {
      _ when match.group(1) != null => (match.group(1)!, 'latex'),
      _ when match.group(2) != null => (match.group(2)!, 'strong'),
      _ => (match.group(3)!, 'em'),
    };
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

// --- shared ------------------------------------------------------------

List<File> _filesUnder(String root, String extension) =>
    Directory(root).listSync(recursive: true).whereType<File>().where((file) {
      return file.path.endsWith(extension);
    }).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
