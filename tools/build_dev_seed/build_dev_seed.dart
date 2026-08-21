// Builds assets/seed/v1.json from the authored corpus under content/ so the
// running app shows real questions and lessons instead of the demo rows.
//
// SUPERSEDED: This generator and the v1.json asset it produces are superseded
// by the content.db pipeline. The asset is no longer shipped with the app.
// Do not delete this file or the asset yet, as Stage 3 needs a known-good
// corpus to compare against.
//
// Usage: dart run tools/build_dev_seed/build_dev_seed.dart

import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../content/lesson_asset_map.dart';
import '../content/markdown_portable_text.dart';

const _examId = 'exam_upcat';
const _keepExamId = 'exam_cse_pro';

// The post-launch expansion roster from the foundation spec §1.2, carried in
// the dev seed so exam-list surfaces have realistic data to hold. They ship
// `isActive: true` so all built-in exams are available in the onboarding
// picker.
const _rosterExams = <Map<String, Object?>>[
  {
    'id': 'exam_acet',
    'code': 'ACET',
    'name': 'Ateneo College Entrance Test',
    'shortName': 'ACET',
    'language': 'en',
    'isActive': true,
    'subjects': <Map<String, Object?>>[],
  },
  {
    'id': 'exam_dlsucet',
    'code': 'DLSUCET',
    'name': 'De La Salle University College Admission Test',
    'shortName': 'DLSUCET',
    'language': 'en',
    'isActive': true,
    'subjects': <Map<String, Object?>>[],
  },
  {
    'id': 'exam_ustet',
    'code': 'USTET',
    'name': 'UST Entrance Test',
    'shortName': 'USTET',
    'language': 'en',
    'isActive': true,
    'subjects': <Map<String, Object?>>[],
  },
  {
    'id': 'exam_pupcet',
    'code': 'PUPCET',
    'name': 'PUP College Entrance Test',
    'shortName': 'PUPCET',
    'language': 'en',
    'isActive': true,
    'subjects': <Map<String, Object?>>[],
  },
  {
    'id': 'exam_cse_sub',
    'code': 'CSE_SUB',
    'name': 'Civil Service Examination: Subprofessional',
    'shortName': 'CSE Sub',
    'language': 'en',
    'isActive': true,
    'subjects': <Map<String, Object?>>[],
  },
];

void main() {
  final topicIdBySlug = loadTopicIdBySlug();
  final outline = jsonDecode(
    File('tools/lesson_author/outline.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  final subjects = <Map<String, Object?>>[];
  final topics = <Map<String, Object?>>[];

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
      topics.add({
        'id': topicId,
        'subjectId': subjectId,
        'name': topic['name'] as String,
        'ordering': topicOrder++,
      });
    }
  }

  final passages = buildPassages(topicIdBySlug);
  final questions = buildQuestions(topicIdBySlug);
  final lessons = buildLessons(topicIdBySlug);

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
      for (final subject in exam['subjects'] as List)
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
    for (final topic in keptTopics) topic['id'],
  };
  final keptPassages = [
    for (final passage in (existing['passages'] as List? ?? const []))
      if (keptTopicIds.contains((passage as Map<String, dynamic>)['topicId']))
        passage,
  ];
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
    'contentVersion': computeContentVersion(),
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
    'passages': [...keptPassages, ...passages],
    'questions': [...keptQuestions, ...questions],
    'lessons': [...keptLessons, ...lessons],
  };

  File('assets/seed/v1.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(seed)}\n',
  );

  // Deliberately not a cascade. Cascading on `stdout` crashes the compiler's
  // FFI pass with "type 'InvalidType' is not a subtype of type
  // 'FunctionType'", so this tool would not build at all. It was made a
  // cascade on 10 August to clear a `cascade_invocations` info, and nothing
  // ran the generator afterwards to notice.
  // ignore_for_file: cascade_invocations
  stdout.writeln('Wrote assets/seed/v1.json');
  stdout.writeln('  subjects:  ${subjects.length}');
  stdout.writeln('  topics:    ${topics.length}');
  stdout.writeln(
    '  questions: ${questions.length} (+${keptQuestions.length} kept)',
  );
  stdout.writeln(
    '  lessons:   ${lessons.length} (+${keptLessons.length} kept)',
  );
}

String _underscore(String slug) => slug.replaceAll('-', '_');

/// Derives a monotonic contentVersion integer from [timestamp] formatted as
/// `YYYYMMDDHH`.
///
/// This scheme ensures that seed builds produce strictly increasing version
/// numbers without requiring a manually maintained counter.
int computeContentVersion([DateTime? timestamp]) {
  final time = timestamp ?? DateTime.now().toUtc();
  final year = time.year.toString().padLeft(4, '0');
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  final hour = time.hour.toString().padLeft(2, '0');
  return int.parse('$year$month$day$hour');
}

Map<String, String> loadTopicIdBySlug() {
  final outline = jsonDecode(
    File('tools/lesson_author/outline.json').readAsStringSync(),
  ) as Map<String, dynamic>;
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

// --- passages ----------------------------------------------------------

List<Map<String, Object?>> buildPassages(Map<String, String> topicIdBySlug) {
  final passages = <Map<String, Object?>>[];

  for (final file in _filesUnder('content/questions', '.yaml')) {
    final doc = loadYaml(file.readAsStringSync()) as YamlMap;
    final rawPassages = doc['passages'] as YamlList?;
    if (rawPassages == null) continue;

    final meta = doc['meta'] as YamlMap;
    final topicSlug = meta['topic'] as String;
    final topicId = topicIdBySlug[topicSlug];
    if (topicId == null) continue;

    for (final raw in rawPassages) {
      final passage = raw as YamlMap;
      final body = (passage['body'] as String).trim();
      final wordCount =
          body.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
      passages.add({
        'id': passage['id'] as String,
        'topicId': topicId,
        'title': (passage['title'] as String).trim(),
        'body': body,
        'language': 'en',
        'wordCount': wordCount,
      });
    }
  }

  return passages;
}

// --- questions ---------------------------------------------------------

List<Map<String, Object?>> buildQuestions(Map<String, String> topicIdBySlug) {
  const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
  final questions = <Map<String, Object?>>[];
  var skippedFigures = 0;

  for (final file in _filesUnder('content/questions', '.yaml')) {
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
      if (figure != null && '$figure'.trim().isNotEmpty && drawnSpec == null) {
        skippedFigures++;
        continue;
      }
      final id = question['id'] as String;
      final choices = (question['choices'] as YamlList)
          .cast<YamlMap>()
          .toList(growable: false);
      final passageId = question['passage'] as String?;
      questions.add({
        'id': id,
        'version': 1,
        'examIds': examIds,
        'topicId': topicId,
        // Derived, never authored. A question at
        // content/questions/<subject>/<topic>/<subtopic>.yaml belongs to the
        // lesson at the mirror path, whose _id is lesson-<topic>-<subtopic>.
        'lessonId': 'lesson-$topicSlug-$subtopicSlug',
        if (passageId != null) 'passageId': passageId,
        'language': 'en',
        'stem': (question['stem'] as String).trim(),
        'choices': [
          for (var i = 0; i < choices.length; i++)
            {
              'id': '${id}_${labels[i].toLowerCase()}',
              'label': labels[i],
              'text': '${choices[i]['text']}'.trim(),
              'isCorrect': choices[i]['correct'] == true,
              if (choices[i]['rationale'] != null)
                'rationale': '${choices[i]['rationale']}'.trim(),
            },
        ],
        'explanation': (question['explanation'] as String).trim(),
        if (drawnSpec != null)
          'figureSpecJson': jsonEncode(_plainMap(drawnSpec)),
      });
    }
  }

  stdout.writeln('  skipped $skippedFigures figure-pending questions');
  return questions;
}

// --- lessons -----------------------------------------------------------

List<Map<String, Object?>> buildLessons(
  Map<String, String> topicIdBySlug, [
  String root = '.',
  LessonAssetMap? assets,
]) {
  final assetMap = assets ??
      LessonAssetMap.fromJsonFile(
        File('$root/content/illustrations/assets.json'),
      );
  final lessons = <Map<String, Object?>>[];

  // Not one lesson file carries `ordering:` yet. Numbering each topic's files
  // in glob order preserves exactly what students see today, and a frontmatter
  // `ordering:` overrides it wherever the editorial pass has run.
  final nextOrdering = <String, int>{};

  for (final file in _filesUnder('$root/content/lessons', '.md')) {
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

    final fallback = (nextOrdering[topicId] ?? 0) + 1;
    nextOrdering[topicId] = fallback;

    final identity = LessonIdentity.fromPath(file.path);

    final bodyJson = markdownToPortableText(
      source.substring(match.end),
      lesson: identity,
      assets: assetMap,
    );

    lessons.add({
      'id': front['_id'] as String,
      'topicId': topicId,
      'title': front['title'] as String,
      'summary': front['summary'] as String,
      'estimatedMinutes': front['estimatedMinutes'] as int,
      'ordering': front['ordering'] as int? ?? fallback,
      'bodyJson': bodyJson,
    });
  }

  return lessons;
}

// --- shared ------------------------------------------------------------

List<File> _filesUnder(String root, String extension) =>
    Directory(root).listSync(recursive: true).whereType<File>().where((file) {
      return file.path.endsWith(extension);
    }).toList()
      ..sort((a, b) => a.path.compareTo(b.path));

/// YAML maps are not JSON encodable on their own. This turns one into a
/// plain map so the figure spec can be stored as text.
Map<String, Object?> _plainMap(Object? value) {
  final map = value! as Map;
  return {
    for (final entry in map.entries)
      '${entry.key}': entry.value is Map
          ? _plainMap(entry.value)
          : entry.value is List
              ? [
                  for (final item in entry.value as List)
                    item is Map ? _plainMap(item) : item,
                ]
              : entry.value,
  };
}
