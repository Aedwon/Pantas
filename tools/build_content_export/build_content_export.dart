import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:yaml/yaml.dart';

import '../../tool/content/content_gate.dart';
import '../../tool/content/lesson_checks.dart';
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
  _checkDuplicateIds(root);

  final findings = runContentGate('$root/content');
  if (findings.isNotEmpty) {
    for (final finding in findings) {
      stderr.writeln(finding);
    }
    exitCode = 1;
    return;
  }

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

  // Keep historical CSE IDs for saved progress, including inactive sample rows.
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
        'isActive': subject['isActive'] ?? true,
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
      'isActive': topic['isActive'] ?? true,
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
      'isActive': q['isActive'] ?? true,
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
      'isActive': l['isActive'] ?? true,
      'topic': {'_ref': l['topicId']},
      'title': l['title'],
      'summary': l['summary'],
      'estimatedMinutes': l['estimatedMinutes'],
      'ordering': l['ordering'] ?? 0,
      'body': l['bodyJson'],
      'quizSize': 5,
      'status': l['status'] ?? 'active',
      if (l['replacedBy'] != null) 'replacedBy': l['replacedBy'],
      if (l['part'] != null) 'part': l['part'],
      if (l['partCount'] != null) 'partCount': l['partCount'],
      if (l['keyPoints'] != null) 'keyPoints': l['keyPoints'],
    });
  }

  final yamlPassages = <String, Map<String, Object?>>{};
  for (final file in _filesUnder('$root/content/questions', '.yaml')) {
    final doc =
        loadYaml(file.readAsStringSync(), sourceUrl: Uri.file(file.path))
            as YamlMap;
    final updatedAt = _getFileHashTimestamp(file);
    for (final raw in doc['passages'] as YamlList? ?? <Object?>[]) {
      final passage = raw! as YamlMap;
      final body = passage['body'] as String;
      yamlPassages[passage['id'] as String] = {
        '_updatedAt': updatedAt,
        'title': passage['title'] as String? ?? '',
        'body': body,
        'wordCount': body.trim().split(RegExp(r'\s+')).length,
      };
    }
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
      ...?yamlPassages[p['id']],
    });
  }

  final mockBlueprints = buildMockBlueprints(root);

  if (exitCode != 0) return;
  final resolver = _LessonResolver(lessons);
  for (final question in questions) {
    final ref = question['lesson'] as Map<String, Object?>?;
    if (ref != null) {
      question['lesson'] = {'_ref': resolver.resolve(ref['_ref']! as String)};
    }
  }
  final lessonLinks = buildLessonLinks(root, lessons);
  final gapTags = buildGapTags(
    root,
    questions,
    lessons,
    lessonLinks,
    pendingQuestionIds: pendingQuestionIds,
  );

  final lessonFindings = runLessonChecks('$root/content');
  if (lessonFindings.isNotEmpty) {
    for (final finding in lessonFindings) {
      stderr.writeln(finding);
    }
    exitCode = 1;
    return;
  }

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

/// Validate identities before filtering pending figures or rendering lessons.
/// Keep every occurrence, including two occurrences in the same source file.
void _checkDuplicateIds(String root) {
  final questions = <String, List<String>>{};
  final lessons = <String, List<String>>{};
  void record(Map<String, List<String>> sources, String id, String path) {
    (sources[id] ??= []).add(path);
  }

  for (final file in _filesUnder('$root/content/questions', '.yaml')) {
    final doc =
        loadYaml(file.readAsStringSync(), sourceUrl: Uri.file(file.path))
            as YamlMap;
    for (final row in doc['questions'] as YamlList) {
      record(questions, (row as YamlMap)['id'] as String, file.path);
    }
  }
  for (final file in _filesUnder('$root/content/lessons', '.md')) {
    final match = RegExp(r'^---\n(.*?)\n---\n', dotAll: true)
        .firstMatch(file.readAsStringSync());
    if (match == null) continue; // The existing frontmatter check names this.
    final front =
        loadYaml(match.group(1)!, sourceUrl: Uri.file(file.path)) as YamlMap;
    record(lessons, front['_id'] as String, file.path);
  }

  // The retained legacy paper is also part of this export's ID namespace.
  final historical =
      File('$root/tools/build_content_export/historical_v1.json');
  final saved =
      jsonDecode(historical.readAsStringSync()) as Map<String, dynamic>;
  final subjects = <String>{
    for (final raw in saved['exams'] as List)
      if ((raw as Map<String, dynamic>)['id'] == _keepExamId)
        for (final subject in raw['subjects'] as List)
          (subject as Map<String, dynamic>)['id'] as String,
  };
  final topics = <String>{
    for (final raw in saved['topics'] as List)
      if (subjects.contains((raw as Map<String, dynamic>)['subjectId']))
        raw['id'] as String,
  };
  for (final (key, sources) in [
    ('questions', questions),
    ('lessons', lessons),
  ]) {
    for (final raw in saved[key] as List) {
      final row = raw as Map<String, dynamic>;
      if (topics.contains(row['topicId'])) {
        record(sources, row['id'] as String, historical.path);
      }
    }
  }
  final errors = <String>[];
  for (final (kind, sources) in [
    ('question', questions),
    ('lesson', lessons),
  ]) {
    for (final id in sources.keys.toList()..sort()) {
      final files = sources[id]!;
      if (files.length > 1) {
        errors.add(
          'Duplicate $kind ID "$id":\n  ${(files..sort()).join('\n  ')}',
        );
      }
    }
  }
  if (errors.isNotEmpty) throw FormatException(errors.join('\n'));
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
        'lesson': {
          '_ref': question['lesson'] as String? ??
              'lesson-$topicSlug-$subtopicSlug',
        },
        if (question['keyPoint'] != null)
          'keyPoint': question['keyPoint'] as int,
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
  final explicitOrdering = <String, List<bool>>{};

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

    if (front['status'] != 'retired') {
      (explicitOrdering[topicId] ??= []).add(front['ordering'] != null);
    }
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
      'quizSize': lessonQuizSize(front, source.substring(match.end)),
      'status': front['status'] as String? ?? 'active',
      if (front['replacedBy'] != null)
        'replacedBy': (front['replacedBy'] as YamlList).cast<String>().toList(),
      if (front['part'] != null) 'part': front['part'] as int,
      if (front['partCount'] != null) 'partCount': front['partCount'] as int,
      if (front['keyPoints'] != null)
        'keyPoints': (front['keyPoints'] as YamlList).cast<String>().toList(),
      'body': markdownToPortableText(
        source.substring(match.end),
        lesson: identity,
        assets: assetMap,
      ),
    });
  }

  for (final entry in explicitOrdering.entries) {
    if (entry.value.any((value) => value) &&
        entry.value.any((value) => !value)) {
      throw FormatException(
        'Topic ${entry.key}: every lesson must set ordering '
        'when any lesson does',
      );
    }
  }

  // A figure folder with no lesson file (a renamed lesson, say) is never read
  // by a marker, so name it here instead of dropping it silently.
  assetMap.assertNoOrphanFigures([
    for (final file in _filesUnder('$root/content/lessons', '.md'))
      LessonIdentity.fromPath(file.path),
  ]);
  return lessons;
}

int lessonQuizSize(YamlMap front, String body) {
  final keys = front['keyPoints'] as YamlList?;
  if (keys == null || keys.isEmpty) return 5;
  var examples = 0;
  // B3 allows example practice only in Mathematics and quantitative Science.
  // This pilot has no quantitative Science topics, so only Mathematics applies.
  if (front['subject'] == 'subject-mathematics') {
    var inExamples = false;
    for (final line in const LineSplitter().convert(body)) {
      if (line.startsWith('## ')) inExamples = line.trim() == '## Examples';
      if (inExamples && line.startsWith('### ')) examples++;
    }
  }
  return (keys.length + examples.clamp(0, 2)).clamp(2, 6);
}

/// Validate every replacement edge, including alternatives after the first.
/// Lookup follows only the first replacement, as required for retired aliases.
class _LessonResolver {
  _LessonResolver(List<Map<String, Object?>> lessons)
      : byId = {
          for (final lesson in lessons) lesson['_id']! as String: lesson,
        } {
    final visiting = <String>{};
    final visited = <String>{};
    void visit(String id) {
      if (visiting.contains(id)) {
        throw FormatException('replacedBy cycle at $id');
      }
      if (visited.contains(id)) return;
      final row = byId[id];
      if (row == null) {
        throw FormatException('unknown lesson $id in replacedBy');
      }
      visiting.add(id);
      final replacements =
          (row['replacedBy'] as List?)?.cast<String>() ?? const <String>[];
      if (row['status'] == 'retired' && replacements.isEmpty) {
        throw FormatException('retired lesson $id has empty replacedBy');
      }
      for (final next in replacements) {
        visit(next);
      }
      visiting.remove(id);
      visited.add(id);
    }

    for (final id in byId.keys) {
      visit(id);
    }
  }

  final Map<String, Map<String, Object?>> byId;

  String resolve(String id) {
    var current = id;
    while (true) {
      final row = byId[current];
      if (row == null) throw FormatException('unknown lesson $current');
      if (row['status'] != 'retired') return current;
      current = (row['replacedBy']! as List).first as String;
    }
  }
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
      if (doc['unscoredItems'] != null)
        'unscoredItems': doc['unscoredItems'] as int,
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
  // Code branches carry no roadmap inputs until content merges them in.
  if (!File(path).existsSync()) return const {};
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
  final resolver = _LessonResolver(lessons);
  final ids = resolver.byId.keys.toSet();
  final links = <Map<String, Object?>>[];
  final targets = <String, List<String>>{};
  for (final id in rows.keys.toList()..sort()) {
    if (!ids.contains(id)) {
      throw FormatException('$path: $id: unknown source lesson');
    }
    if (resolver.byId[id]!['status'] == 'retired') {
      throw FormatException('$path: $id: retired lesson in prerequisite link');
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
      if (resolver.byId[target]!['status'] == 'retired') {
        throw FormatException(
          '$path: $id -> $target: retired lesson in prerequisite link',
        );
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
  final resolver = _LessonResolver(lessons);
  final ids = resolver.byId.keys.toSet();
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
      final authoredTarget = raw[text];
      if (authoredTarget is! String || !ids.contains(authoredTarget)) {
        throw FormatException('$path: $id: unknown lesson $authoredTarget');
      }
      final target = resolver.resolve(authoredTarget);
      if (target != authoredTarget) {
        stderr.writeln(
          '$path: warning: $id: retired lesson $authoredTarget '
          'resolves to $target',
        );
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
