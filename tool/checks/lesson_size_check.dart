import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'check.dart';

/// Parsed lesson source shared by the three family checks.
class CheckLesson {
  CheckLesson(this.id, this.topic, this.front, this.body);
  final String id;
  final String? topic;
  final YamlMap front;
  final String body;
  bool get active => front['status'] != 'retired';
  bool get part => front.containsKey('part');
  List<String> get replacements =>
      (front['replacedBy'] as YamlList? ?? []).cast<String>().toList();
}

List<CheckLesson> readCheckLessons(String contentRoot) {
  final directory = Directory(p.join(contentRoot, 'lessons'));
  if (!directory.existsSync()) {
    throw const FormatException('lessons directory missing');
  }
  final lessons = <CheckLesson>[];
  final ids = <String>{};
  final files = directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final source = file.readAsStringSync();
    final match =
        RegExp(r'^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)').firstMatch(source);
    if (match == null) {
      throw FormatException('missing frontmatter: ${file.path}');
    }
    final front = loadYaml(match.group(1)!) as YamlMap;
    final id = front['_id'] as String;
    if (!ids.add(id)) throw FormatException('duplicate lesson id: $id');
    final path = p.split(p.relative(file.path, from: directory.path));
    lessons.add(
      CheckLesson(
        id,
        path.length == 3 ? p.join(path[0], path[1]) : null,
        front,
        source.substring(match.end),
      ),
    );
  }
  return lessons;
}

/// Heading and body, ending at the next heading of the same or higher level.
List<String> lessonSectionItems(String body, String section) {
  final lines = const LineSplitter().convert(body);
  final items = <String>[];
  var inSection = false;
  StringBuffer? item;
  void flush() {
    if (item != null) items.add(item.toString().trim());
    item = null;
  }

  for (final line in lines) {
    if (RegExp(r'^#{1,2}\s').hasMatch(line)) {
      flush();
      inSection = line.trim() == '## $section';
    } else if (inSection && line.startsWith('### ')) {
      flush();
      item = StringBuffer()..writeln(line);
    } else if (item != null) {
      item?.writeln(line);
    }
  }
  flush();
  return items;
}

List<Violation> runLessonSizeCheck(String contentRoot) {
  final found = <Violation>[];
  try {
    final lessons = readCheckLessons(contentRoot);
    final byId = {for (final lesson in lessons) lesson.id: lesson};
    final split = {
      for (final lesson in lessons)
        if (lesson.part && lesson.topic != null) lesson.topic,
    };
    for (final lesson in lessons) {
      void report(String message) => found.add(Violation(lesson.id, message));
      if (!lesson.active) {
        if (lesson.replacements.isEmpty) {
          report('retired lesson needs replacedBy');
        }
        for (final id in lesson.replacements) {
          if (byId[id] == null || !byId[id]!.part) {
            report('replacement $id must exist and have part');
          }
        }
        continue;
      }
      if (!lesson.part) {
        if (split.contains(lesson.topic)) {
          report('active lesson in split topic needs part');
        }
        continue;
      }
      final keys = lesson.front['keyPoints'] as YamlList?;
      if (keys == null || keys.isEmpty || keys.length > 4) {
        report('needs 1 to 4 keyPoints');
      }
      final body = lesson.body.replaceAll(RegExp(r'<!--[\s\S]*?-->'), ' ');
      final words =
          body.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
      final examples = lessonSectionItems(body, 'Examples').length;
      final math = lesson.front['subject'] == 'subject-mathematics';
      final cap = math && examples > 0 ? 550 : 450;
      if (words < 150 || words > cap) {
        report('teaching words $words, expected 150 to $cap');
      }
      if (math && examples > 2) report('more than 2 worked examples');
      if (lessonSectionItems(body, 'Traps to Watch For').length > 3) {
        report('more than 3 traps');
      }
    }
    final prerequisites =
        File(p.join(contentRoot, 'lesson-prerequisites.json'));
    if (prerequisites.existsSync()) {
      final doc =
          jsonDecode(prerequisites.readAsStringSync()) as Map<String, dynamic>;
      final links = doc['lessons'] as Map<String, dynamic>;
      for (final entry in links.entries) {
        final targets = (entry.value as List<dynamic>)
            .map((raw) => (raw as Map<String, dynamic>)['lesson'] as String);
        for (final id in [entry.key, ...targets]) {
          if (byId[id]?.active == false) {
            found.add(Violation(entry.key, 'retired prerequisite link: $id'));
          }
        }
      }
    }
    final visiting = <String>{};
    final visited = <String>{};
    void visit(String id) {
      if (visiting.contains(id)) {
        found.add(Violation(id, 'replacedBy cycle'));
        return;
      }
      if (!visited.add(id)) return;
      visiting.add(id);
      for (final next in byId[id]?.replacements ?? <String>[]) {
        visit(next);
      }
      visiting.remove(id);
    }

    for (final id in byId.keys) {
      visit(id);
    }
  } on Object catch (error) {
    found.add(Violation(contentRoot, '$error'));
  }
  return found;
}

class LessonSizeCheck extends Check {
  const LessonSizeCheck();
  @override
  String get name => 'lesson-size';
  @override
  String get origin => 'Bite-sized lessons B3 and B6';
  @override
  List<Violation> run(String root) => runLessonSizeCheck('$root/content');
}
