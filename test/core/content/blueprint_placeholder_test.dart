import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/content/sanity/parsers/mock_blueprint_parser.dart';

import '../../../tools/build_content_export/build_content_export.dart';

void main() {
  const marked = <String, Object?>{
    'value': 40,
    'placeholder': true,
    'placeholderNote': 'Awaiting published section counts.',
  };

  test('a marked blueprint value exposes its value and placeholder note', () {
    final figure = BlueprintValue.fromJson(marked);
    expect(figure.value, 40);
    expect(figure.isPlaceholder, isTrue);
    expect(figure.placeholderNote, 'Awaiting published section counts.');
  });

  test('plain blueprint values keep their published behavior', () {
    final figure = BlueprintValue.fromJson(40);
    expect(figure.value, 40);
    expect(figure.isPlaceholder, isFalse);
    expect(figure.placeholderNote, isNull);
  });

  test('a placeholder must carry a nonempty note', () {
    expect(
      () => BlueprintValue.fromJson(const {'value': 40, 'placeholder': true}),
      throwsFormatException,
    );
  });

  test('export and parser preserve field-level markers in sections', () {
    final root = Directory.systemTemp.createTempSync('pantas_placeholder_');
    addTearDown(() => root.deleteSync(recursive: true));
    final mock = Directory('${root.path}/content/mock')
      ..createSync(recursive: true);
    File('${mock.path}/test.yaml').writeAsStringSync('''
_id: bp_test
exam: exam_cse_pro
name: Test blueprint
durationMinutes: 90
sections:
  - subjectId: subject_verbal
    questionCount:
      value: 40
      placeholder: true
      placeholderNote: Awaiting published section counts.
    sectionalMinutes: 25
''');
    final export = buildMockBlueprints(root.path).single;
    final parsed = parseMockBlueprint(export);
    final sections = (jsonDecode(parsed.sectionsJson.value) as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final figure = BlueprintValue.fromJson(sections.single['questionCount']);
    expect(figure.value, 40);
    expect(figure.isPlaceholder, isTrue);
    expect(figure.placeholderNote, 'Awaiting published section counts.');
    expect(
      BlueprintValue.fromJson(sections.single['sectionalMinutes'])
          .isPlaceholder,
      isFalse,
    );
  });
}
