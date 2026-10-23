import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/content/sanity/parsers/mock_blueprint_parser.dart';

Map<String, Object?> blueprintDoc({
  Object? sectionalTiming,
  int? pass,
  Object? unscoredItems,
  int? close,
  List<Map<String, Object?>>? sections,
}) {
  return {
    '_id': 'blueprint_cse',
    '_updatedAt': '2026-05-17T00:00:00Z',
    'schemaVersion': 1,
    'isActive': true,
    'exam': {'_ref': 'exam_cse'},
    'name': 'CSE Practice',
    'durationMinutes': 90,
    if (unscoredItems != null) 'unscoredItems': unscoredItems,
    if (sectionalTiming != null) 'sectionalTiming': sectionalTiming,
    if (pass != null && close != null)
      'scoreBands': {'passAtPercent': pass, 'closeAtPercent': close},
    'sections': sections ??
        [
          {'subjectId': 'subject_verbal', 'questionCount': 10},
        ],
  };
}

void main() {
  test('unscoredItems parses when positive and is null otherwise', () {
    expect(
      parseMockBlueprint(blueprintDoc(unscoredItems: 15)).unscoredItems.value,
      15,
    );
    expect(parseMockBlueprint(blueprintDoc()).unscoredItems.value, isNull);
    expect(
      parseMockBlueprint(blueprintDoc(unscoredItems: 0)).unscoredItems.value,
      isNull,
    );
    expect(
      parseMockBlueprint(blueprintDoc(unscoredItems: 'x')).unscoredItems.value,
      isNull,
    );
  });

  test('a blueprint with no timing parses to null, not a default', () {
    final row = parseMockBlueprint(blueprintDoc());

    // A parser that quietly fills this in is how a student gets told they
    // can go back on an exam where they cannot.
    expect(row.sectionalTiming.value, isNull);
  });

  test('sectional and roamable both round-trip', () {
    expect(
      parseMockBlueprint(blueprintDoc(sectionalTiming: 'sectional'))
          .sectionalTiming
          .value,
      SectionalTiming.sectional.name,
    );
    expect(
      parseMockBlueprint(blueprintDoc(sectionalTiming: 'roamable'))
          .sectionalTiming
          .value,
      SectionalTiming.roamable.name,
    );
  });

  test('an unrecognised timing value is null, never a guess', () {
    expect(
      parseMockBlueprint(blueprintDoc(sectionalTiming: 'wibble'))
          .sectionalTiming
          .value,
      isNull,
    );
  });

  test('score bands round-trip and absent stays absent', () {
    final withBands = parseMockBlueprint(blueprintDoc(pass: 70, close: 55));
    final decoded =
        jsonDecode(withBands.scoreBandsJson.value!) as Map<String, Object?>;
    expect(decoded['passAtPercent'], 70);
    expect(decoded['closeAtPercent'], 55);

    expect(parseMockBlueprint(blueprintDoc()).scoreBandsJson.value, isNull);
  });

  test('half a band is no band at all', () {
    final doc = blueprintDoc()
      ..['scoreBands'] = <String, Object?>{'passAtPercent': 70};

    expect(parseMockBlueprint(doc).scoreBandsJson.value, isNull);
  });

  test('the per-part limit survives into the sections', () {
    final row = parseMockBlueprint(
      blueprintDoc(
        sectionalTiming: 'sectional',
        sections: [
          {
            'subjectId': 'subject_verbal',
            'questionCount': 10,
            'sectionalMinutes': 25,
          },
        ],
      ),
    );

    final sections = jsonDecode(row.sectionsJson.value) as List;
    expect((sections.first as Map)['sectionalMinutes'], 25);
  });

  test('a blueprint read back carries both fields', () {
    const blueprint = MockBlueprint(
      id: 'bp',
      examId: 'exam_cse',
      name: 'CSE Practice',
      durationMinutes: 90,
      sectionsJson: '[]',
      sectionalTiming: SectionalTiming.sectional,
      scoreBands: ScoreBands(passAtPercent: 70, closeAtPercent: 55),
    );

    expect(blueprint.sectionalTiming, SectionalTiming.sectional);
    expect(blueprint.scoreBands?.passAtPercent, 70);
  });

  test('v1 blueprint missing source parses to unknown', () {
    final row = parseMockBlueprint(blueprintDoc());
    expect(row.source.value, 'unknown');
    expect(row.sourceNote.value, isNull);
  });

  test('v2 blueprint parses source and sourceNote', () {
    final doc = blueprintDoc()
      ..['schemaVersion'] = 2
      ..['source'] = 'reported'
      ..['sourceNote'] = 'Supplied by Aedwon';
    final row = parseMockBlueprint(doc);
    expect(row.source.value, 'reported');
    expect(row.sourceNote.value, 'Supplied by Aedwon');
  });
}
