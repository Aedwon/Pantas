import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

import '../../content/lesson_asset_map.dart';

/// The exams the tool shows, as the content files and the app name them.
const reviewedExams = ['cse-pro', 'cse-sub'];

const _switchedOff = 'Students do not see this: it is switched off.';
const _figureNotDrawn =
    'The app leaves this question out: its figure is not drawn yet.';

/// What the content files say, joined with what the app's build kept.
class Manifest {
  Manifest({required this.items, required this.figureBlocks});

  final List<Map<String, Object?>> items;

  /// Figure id to the image block the exporter puts in the lesson body.
  final Map<String, Map<String, Object?>> figureBlocks;

  Map<String, String> get hashes => {
        for (final item in items)
          item['id']! as String: item['hash']! as String,
      };

  Map<String, Object?> toJson() => {
        'items': items,
        'counts': counts(),
      };

  Map<String, Object?> counts() {
    final out = <String, Object?>{};
    for (final kind in const ['lesson', 'question', 'mock', 'figure']) {
      for (final exam in reviewedExams) {
        final mine = items.where(
          (i) => i['kind'] == kind && (i['exams']! as List).contains(exam),
        );
        out['$kind/$exam'] = {
          'total': mine.length,
          'cantShow': mine.where((i) => i['cantShow'] != null).length,
        };
      }
    }
    return out;
  }
}

String _sha(List<int> bytes) => sha256.convert(bytes).toString();

Object? _plain(Object? node) {
  if (node is Map) {
    final keys = [for (final k in node.keys) '$k']..sort();
    return LinkedHashMap<String, Object?>.fromIterable(
      keys,
      value: (k) => _plain(node[k]),
    );
  }
  if (node is List) return [for (final v in node) _plain(v)];
  return node;
}

/// sha256 of the node as JSON with sorted keys.
String canonicalHash(Object? node) =>
    _sha(utf8.encode(jsonEncode(_plain(node))));

String _examCode(Object? examId) =>
    '$examId'.replaceFirst('exam_', '').replaceAll('_', '-');

List<File> _filesUnder(String dir, String ext) {
  final root = Directory(dir);
  if (!root.existsSync()) return const [];
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith(ext))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

String _rel(String root, String path) => path.substring(root.length + 1);

String _underscore(String s) => s.replaceAll('-', '_');

String _firstLine(String text, [int max = 90]) {
  final line = text.trim().split('\n').first.trim();
  return line.length <= max ? line : '${line.substring(0, max - 1)}…';
}

/// Builds the manifest for the content tree at [root], with [export] being
/// the decoded export.json built from that same tree.
Manifest buildManifest(String root, Map<String, Object?> export) {
  List<Map<String, Object?>> table(String key) => [
        for (final row in (export[key] as List? ?? const []))
          Map<String, Object?>.from(row as Map),
      ];
  String ref(Object? v) => (v! as Map)['_ref']! as String;

  final exportQuestions = {
    for (final q in table('question')) q['_id']! as String: q,
  };
  final exportLessons = {
    for (final l in table('lesson')) l['_id']! as String: l,
  };
  final subjectExam = {
    for (final s in table('subject')) s['_id']! as String: ref(s['exam']),
  };
  final topicSubject = {
    for (final t in table('topic')) t['_id']! as String: ref(t['subject']),
  };

  // Which reviewed exams touch a topic: its subject's exam plus every exam its
  // questions are tagged for. This mirrors how the app scopes a study map.
  final topicExams = <String, Set<String>>{};
  void addTopicExam(String topic, String code) {
    if (reviewedExams.contains(code)) {
      (topicExams[topic] ??= {}).add(code);
    }
  }

  for (final t in topicSubject.entries) {
    addTopicExam(t.key, _examCode(subjectExam[t.value]));
  }
  for (final q in exportQuestions.values) {
    for (final e in q['examIds']! as List) {
      addTopicExam(ref(q['topic']), _examCode(ref(e)));
    }
  }

  final items = <Map<String, Object?>>[];

  // Questions.
  var qOrder = 0;
  final yamlQuestionIds = <String>{};
  final yamlLessonIds = <String>{};
  final questionExamsByLesson = <String, Set<String>>{};
  for (final file in _filesUnder('$root/content/questions', '.yaml')) {
    final doc = loadYaml(file.readAsStringSync()) as YamlMap;
    final meta = doc['meta'] as YamlMap;
    final codes = [
      for (final c in meta['exams'] as YamlList)
        if (reviewedExams.contains('$c')) '$c',
    ];
    if (codes.isEmpty) continue;
    final lessonId = 'lesson-${meta['topic']}-${meta['subtopic']}';
    for (final raw in doc['questions'] as YamlList) {
      final node = raw as YamlMap;
      final id = node['id'] as String;
      yamlQuestionIds.add(id);
      final exported = exportQuestions[id];
      String? cant;
      if (exported == null) {
        final figure = node['figure'];
        cant = figure != null &&
                '$figure'.trim().isNotEmpty &&
                node['figureSpec'] == null
            ? _figureNotDrawn
            : 'The app leaves this question out of the content build.';
      } else if (exported['isActive'] == false) {
        cant = _switchedOff;
      }
      (questionExamsByLesson[lessonId] ??= {}).addAll(codes);
      items.add({
        'id': id,
        'kind': 'question',
        'file': _rel(root, file.path),
        'title': _firstLine('${node['stem']}'),
        'exams': codes,
        'hash': canonicalHash(node),
        'order': qOrder++,
        'lessonId': lessonId,
        'topic': '${meta['topic']}',
        'cantShow': cant,
      });
    }
  }

  // Lessons.
  final assets = LessonAssetMap.fromJsonFile(
    File('$root/content/illustrations/assets.json'),
  );
  final lessonFiles = _filesUnder('$root/content/lessons', '.md');
  final markerTexts = <String, List<String>>{};
  final lessonExams = <String, List<String>>{};
  final lessonIdByPrefix = <String, String>{};
  var lOrder = 0;
  final marker = RegExp(r'<!--\s*ILLUSTRATION:\s*(.*?)\s*-->', dotAll: true);
  for (final file in lessonFiles) {
    final text = file.readAsStringSync();
    final match = RegExp(r'^---\n(.*?)\n---\n', dotAll: true).firstMatch(text);
    if (match == null) continue;
    final front = loadYaml(match.group(1)!) as YamlMap;
    final id = front['_id'] as String;
    yamlLessonIds.add(id);
    final topicSlug = (front['topic'] as String).replaceFirst('topic-', '');
    final topicId = 'topic_upcat_${_underscore(topicSlug)}';
    final identity = LessonIdentity.fromPath(file.path);
    markerTexts[identity.assetKeyPrefix] = [
      for (final m in marker.allMatches(text.substring(match.end)))
        m.group(1)!.trim(),
    ];
    final exported = exportLessons[id];
    final exams = {
      ...?topicExams[ref(exported?['topic'] ?? {'_ref': topicId})],
      ...?questionExamsByLesson[id],
    }.toList()
      ..sort();
    lessonExams[identity.assetKeyPrefix] = exams;
    lessonIdByPrefix[identity.assetKeyPrefix] = id;
    if (exams.isEmpty) continue;
    final figureBytes = <int>[];
    final figureDir =
        Directory('$root/content/illustrations/${identity.assetKeyPrefix}');
    if (figureDir.existsSync()) {
      for (final f in _filesUnder(figureDir.path, '')) {
        figureBytes.addAll(f.readAsBytesSync());
      }
    }
    String? cant;
    if (front['isActive'] == false || exported?['isActive'] == false) {
      cant = _switchedOff;
    } else if (exported == null) {
      cant = 'The app leaves this lesson out of the content build.';
    }
    items.add({
      'id': id,
      'kind': 'lesson',
      'file': _rel(root, file.path),
      'title': '${front['title']}',
      'exams': exams,
      'hash': _sha([...utf8.encode(text), ...figureBytes]),
      'order': lOrder++,
      'topic': topicSlug,
      'ordering': front['ordering'],
      'cantShow': cant,
    });
  }

  // Rows the export carries from the old catalog file, not from the content
  // files. Students see them, so they are listed with that file as the source.
  const catalog = 'tools/build_content_export/historical_v1.json';
  for (final q in exportQuestions.values) {
    final id = q['_id']! as String;
    if (yamlQuestionIds.contains(id)) continue;
    final codes = {
      for (final e in q['examIds']! as List) _examCode(ref(e)),
    }.where(reviewedExams.contains).toList()
      ..sort();
    if (codes.isEmpty) continue;
    final stem = [
      for (final b in (q['stem'] as List? ?? const []))
        for (final c in ((b as Map)['children'] as List? ?? const []))
          '${(c as Map)['text']}',
    ].join(' ');
    items.add({
      'id': id,
      'kind': 'question',
      'file': catalog,
      'title': _firstLine(stem),
      'exams': codes,
      'hash': canonicalHash(q),
      'order': qOrder++,
      'lessonId': q['lesson'] == null ? null : ref(q['lesson']),
      'topic': ref(q['topic']),
      'cantShow': q['isActive'] == false ? _switchedOff : null,
    });
  }
  for (final l in exportLessons.values) {
    final id = l['_id']! as String;
    if (yamlLessonIds.contains(id)) continue;
    final exams = (topicExams[ref(l['topic'])] ?? const <String>{}).toList()
      ..sort();
    if (exams.isEmpty) continue;
    items.add({
      'id': id,
      'kind': 'lesson',
      'file': catalog,
      'title': '${l['title']}',
      'exams': exams,
      'hash': canonicalHash(l),
      'order': lOrder++,
      'topic': ref(l['topic']),
      'ordering': l['ordering'],
      'cantShow': l['isActive'] == false ? _switchedOff : null,
    });
  }

  // Mock blueprints.
  var mOrder = 0;
  for (final file in _filesUnder('$root/content/mock', '.yaml')) {
    final text = file.readAsStringSync();
    final doc = loadYaml(text) as YamlMap;
    final code = _examCode(doc['exam']);
    if (!reviewedExams.contains(code)) continue;
    items.add({
      'id': doc['_id'] as String,
      'kind': 'mock',
      'file': _rel(root, file.path),
      'title': '${doc['name']}',
      'exams': [code],
      'hash': _sha(utf8.encode(text)),
      'order': mOrder++,
      'cantShow': doc['isActive'] == false ? _switchedOff : null,
    });
  }

  // Figures.
  final figureBlocks = <String, Map<String, Object?>>{};
  final figureFiles = [
    for (final f in _filesUnder('$root/content/illustrations', ''))
      if (RegExp(r'\.(svg|png)$').hasMatch(f.path) &&
          !f.path.contains('/sources/'))
        f,
  ];
  var fOrder = 0;
  final figurePath = RegExp(
    r'^([a-z0-9-]+)/([a-z0-9-]+)/([a-z0-9-]+)/([0-9]{2,})-[a-z0-9-]+\.(svg|png)$',
  );
  for (final file in figureFiles) {
    final relative = _rel('$root/content/illustrations', file.path);
    final m = figurePath.firstMatch(relative);
    if (m == null) continue;
    final prefix = '${m[1]}/${m[2]}/${m[3]}';
    final seq = int.parse(m[4]!);
    final exams = lessonExams[prefix] ?? const <String>[];
    if (exams.isEmpty) continue;
    final lesson = lessonIdByPrefix[prefix];
    final bytes = file.readAsBytesSync();
    final ordered = assets.orderedEntriesFor(
      LessonIdentity.fromPath('content/lessons/${m[1]}/${m[2]}/${m[3]}.md'),
    );
    final index = ordered.indexWhere((e) => e.key == seq);
    final markers = markerTexts[prefix] ?? const <String>[];
    final used = lesson != null && index >= 0 && index < markers.length;
    if (index >= 0) {
      final entry = ordered[index].value;
      figureBlocks[relative] = {
        'asset': {'url': entry.url, 'credit': assets.creditFor(entry) ?? ''},
        'alt': entry.alt.isNotEmpty
            ? entry.alt
            : (index < markers.length ? markers[index] : ''),
      };
    }
    items.add({
      'id': relative,
      'kind': 'figure',
      'file': _rel(root, file.path),
      'title': relative.split('/').last,
      'exams': exams,
      'hash': _sha(bytes),
      'order': fOrder++,
      'lessonId': lesson,
      'seq': seq,
      'cantShow': used ? null : 'No lesson uses this figure.',
    });
  }

  return Manifest(items: items, figureBlocks: figureBlocks);
}
