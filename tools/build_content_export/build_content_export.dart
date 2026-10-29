import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:yaml/yaml.dart';

import '../content/lesson_asset_map.dart';
import '../content/markdown_portable_text.dart';

// Copying some constants and logic from build_dev_seed.dart
const _examId = 'exam_upcat';
const _keepExamId = 'exam_cse_pro';

// The post-launch expansion roster from the foundation spec §1.2, carried in
// the export so exam-list surfaces have realistic data to hold. They ship
// `isActive: true` so all built-in exams are available in the onboarding
// picker.
const _rosterExams = <Map<String, Object?>>[
  {
    'id': 'exam_dost_sei',
    'code': 'DOST_SEI',
    'name': 'DOST-SEI Undergraduate Scholarship',
    'shortName': 'DOST',
    'language': 'en',
    'isActive': true,
  },
  {
    'id': 'exam_sm_foundation',
    'code': 'SM_FOUNDATION',
    'name': 'SM Foundation College Scholarship',
    'shortName': 'SM',
    'language': 'en',
    'isActive': true,
  },
  {
    'id': 'exam_acet',
    'code': 'ACET',
    'name': 'Ateneo College Entrance Test',
    'shortName': 'ACET',
    'language': 'en',
    'isActive': true,
  },
  {
    'id': 'exam_dlsucet',
    'code': 'DLSUCET',
    'name': 'De La Salle University College Admission Test',
    'shortName': 'DLSUCET',
    'language': 'en',
    'isActive': true,
  },
  {
    'id': 'exam_ustet',
    'code': 'USTET',
    'name': 'UST Entrance Test',
    'shortName': 'USTET',
    'language': 'en',
    'isActive': true,
  },
  {
    'id': 'exam_pupcet',
    'code': 'PUPCET',
    'name': 'PUP College Entrance Test',
    'shortName': 'PUPCET',
    'language': 'en',
    'isActive': true,
  },
  {
    'id': 'exam_cse_sub',
    'code': 'CSE_SUB',
    'name': 'Civil Service Examination: Subprofessional',
    'shortName': 'CSE Sub',
    'language': 'en',
    'isActive': true,
  },
];

void main(List<String> args) {
  try {
    _export(args);
  } on FormatException catch (error) {
    stderr.writeln(error is YamlException ? error.toString() : error.message);
    exitCode = 65;
  } on FileSystemException catch (error) {
    stderr.writeln(error);
    exitCode = 65;
  }
}

void _export(List<String> arguments) {
  final args = List<String>.of(arguments);
  String? assetsOut;
  final assetsIndex = args.indexOf('--assets-out');
  if (assetsIndex >= 0) {
    if (assetsIndex + 1 >= args.length) {
      stderr.writeln('--assets-out requires a directory');
      exitCode = 64;
      return;
    }
    assetsOut = args[assetsIndex + 1];
    args.removeRange(assetsIndex, assetsIndex + 2);
  }
  if (args.isEmpty || args.length > 2) {
    stderr.writeln(
      'Usage: build_content_export.dart <output.json> [root] '
      '[--assets-out <directory>]',
    );
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

  final pendingQuestionIds = <String>{};
  final questions = buildQuestions(
    topicIdBySlug,
    root,
    pendingQuestionIds: pendingQuestionIds,
  );
  final lessons = buildLessons(topicIdBySlug, root);

  // Keep the CSE demo exam and its rows; replace everything UPCAT.
  final existing = jsonDecode(
    File('$root/tools/build_content_export/historical_v1.json')
        .readAsStringSync(),
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

  final v1UpdatedAt = _getFileHashTimestamp(
    File('$root/tools/build_content_export/historical_v1.json'),
  );

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

  if (exitCode != 0) return;
  final lessonLinks = buildLessonLinks(root, lessons);
  final gapTags = buildGapTags(
    root,
    questions,
    lessons,
    lessonLinks,
    pendingQuestionIds: pendingQuestionIds,
  );

  final seed = {
    'exam': examsOutput,
    'subject': subjects,
    'topic': topics,
    'passage': passagesOutput,
    'question': questions,
    'lesson': lessons,
    'mockBlueprint': mockBlueprints,
    'lessonLink': lessonLinks,
    'gapTag': gapTags,
  };

  if (assetsOut != null) {
    final slim = <String, List<Map<String, Object?>>>{};
    for (final link in lessonLinks) {
      (slim[link['lesson']! as String] ??= []).add({
        'lesson': link['requires'],
        'strength': link['strength'],
      });
    }
    final asset = File('$assetsOut/lesson_links.json');
    asset.parent.createSync(recursive: true);
    asset.writeAsStringSync('${jsonEncode(slim)}\n');
  }
  stdout.writeln('  ${lessonLinks.length} links and ${gapTags.length} tags');
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
  String root, {
  Set<String>? pendingQuestionIds,
}) {
  const labels = ['A', 'B', 'C', 'D', 'E', 'F'];
  final questions = <Map<String, Object?>>[];
  var skippedFigures = 0;

  for (final file in _filesUnder('$root/content/questions', '.yaml')) {
    final updatedAt = _getFileHashTimestamp(file);
    final doc =
        loadYaml(file.readAsStringSync(), sourceUrl: Uri.file(file.path))
            as YamlMap;
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
        pendingQuestionIds?.add(question['id'] as String);
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
  String root, {
  LessonAssetMap? assets,
}) {
  final assetMap = assets ??
      LessonAssetMap.fromJsonFile(
        File('$root/content/illustrations/assets.json'),
      );
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

    final identity = LessonIdentity.fromPath(file.path);

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
      'body': markdownToPortableText(
        source.substring(match.end),
        lesson: identity,
        assets: assetMap,
      ),
    });
  }

  // A figure folder with no lesson file (a renamed lesson, say) is never read
  // by a marker, so name it here instead of dropping it silently.
  assetMap.assertNoOrphanFigures([
    for (final file in _filesUnder('$root/content/lessons', '.md'))
      LessonIdentity.fromPath(file.path),
  ]);
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
    final doc =
        loadYaml(file.readAsStringSync(), sourceUrl: Uri.file(file.path))
            as YamlMap;
    BlueprintValue.validateSections(
      (doc['sections'] as YamlList).cast<Object?>(),
    );
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

Map<String, dynamic> _roadmapInput(String path, String key) {
  final Object? value;
  try {
    value = jsonDecode(File(path).readAsStringSync());
  } on FormatException {
    throw FormatException('$path: bad shape: invalid JSON');
  }
  if (value is! Map<String, dynamic>) {
    throw FormatException('$path: bad shape: expected object');
  }
  if (value['version'] != 1) {
    throw FormatException('$path: version must be 1');
  }
  final rows = value[key];
  if (rows is! Map<String, dynamic>) {
    throw FormatException('$path: bad shape: $key must be an object');
  }
  return rows;
}

List<Map<String, Object?>> buildLessonLinks(
  String root,
  List<Map<String, Object?>> lessons,
) {
  final path = '$root/content/lesson-prerequisites.json';
  final rows = _roadmapInput(path, 'lessons');
  final ids = lessons.map((lesson) => lesson['_id']).toSet();
  final links = <Map<String, Object?>>[];
  final targets = <String, List<String>>{};
  for (final id in rows.keys.toList()..sort()) {
    if (!ids.contains(id)) {
      throw FormatException('$path: $id: unknown source lesson');
    }
    final raw = rows[id];
    if (raw is! List<dynamic>) {
      throw FormatException('$path: $id: bad link shape: expected list');
    }
    final seen = <String>{};
    for (final link in raw) {
      if (link is! Map<String, dynamic> || link['lesson'] is! String) {
        throw FormatException('$path: $id: bad link shape');
      }
      final target = link['lesson'] as String;
      if (!ids.contains(target)) {
        throw FormatException('$path: $id -> $target: unknown target lesson');
      }
      if (target == id) {
        throw FormatException('$path: $id: self link');
      }
      if (!seen.add(target)) {
        throw FormatException('$path: $id -> $target: duplicate link');
      }
      final strength = link['strength'];
      if (strength != 'required' && strength != 'helpful') {
        throw FormatException('$path: $id -> $target: invalid strength');
      }
      (targets[id] ??= []).add(target);
      links.add({'lesson': id, 'requires': target, 'strength': strength});
    }
  }
  final visiting = <String>{};
  final visited = <String>{};
  void visit(String id) {
    if (visited.contains(id)) return;
    visiting.add(id);
    for (final target in targets[id] ?? const <String>[]) {
      if (visiting.contains(target)) {
        throw FormatException('$path: $id -> $target: cycle');
      }
      visit(target);
    }
    visiting.remove(id);
    visited.add(id);
  }

  for (final id in targets.keys) {
    visit(id);
  }
  links.sort((a, b) {
    final order = (a['lesson']! as String).compareTo(b['lesson']! as String);
    return order != 0
        ? order
        : (a['requires']! as String).compareTo(b['requires']! as String);
  });
  return links;
}

List<Map<String, Object?>> buildGapTags(
  String root,
  List<Map<String, Object?>> questions,
  List<Map<String, Object?>> lessons,
  List<Map<String, Object?>> links, {
  Set<String> pendingQuestionIds = const {},
}) {
  final path = '$root/content/question-gap-tags.json';
  final rows = _roadmapInput(path, 'questions');
  final byId = {for (final question in questions) question['_id']: question};
  final ids = lessons.map((lesson) => lesson['_id']).toSet();
  final tags = <Map<String, Object?>>[];
  var skipped = 0;
  for (final id in rows.keys.toList()..sort()) {
    if (pendingQuestionIds.contains(id)) {
      skipped++;
      continue;
    }
    final question = byId[id];
    if (question == null) {
      throw FormatException('$path: $id: unknown question');
    }
    final raw = rows[id];
    if (raw is! Map<String, dynamic>) {
      throw FormatException('$path: $id: bad tag shape');
    }
    final choices = (question['choices']! as List).cast<Map<String, Object?>>();
    final seen = <String>{};
    for (final text in raw.keys.toList()..sort()) {
      final matches = choices
          .where((choice) => (choice['text']! as String).trim() == text.trim())
          .toList();
      if (matches.isEmpty) {
        throw FormatException('$path: $id: no matching choice for "$text"');
      }
      if (matches.length != 1) {
        throw FormatException(
          '$path: $id: multiple matching choices for "$text"',
        );
      }
      final choice = matches.single;
      if (choice['isCorrect'] == true) {
        throw FormatException('$path: $id: tag on correct choice "$text"');
      }
      final target = raw[text];
      if (target is! String || !ids.contains(target)) {
        throw FormatException('$path: $id: unknown lesson $target');
      }
      final lesson = (question['lesson'] as Map<String, Object?>?)?['_ref'];
      if (!links.any(
        (link) => link['lesson'] == lesson && link['requires'] == target,
      )) {
        throw FormatException(
          '$path: $id -> $target: not a link target of $lesson',
        );
      }
      final choiceId = choice['_key']! as String;
      if (!seen.add(choiceId)) {
        throw FormatException(
          '$path: $id: duplicate normalized choice "$text"',
        );
      }
      tags.add({'question': id, 'choice': choiceId, 'prerequisite': target});
    }
  }
  tags.sort(
    (a, b) => (a['choice']! as String).compareTo(b['choice']! as String),
  );
  stdout.writeln('  skipped $skipped tagged figure-pending questions');
  return tags;
}
