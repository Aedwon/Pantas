import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/content/sanity/schema_versions.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';

abstract final class ReleaseTestContentIds {
  static const exam = 'release-e2e-exam';
  static const subject = 'release-e2e-subject';
  static const topic = 'release-e2e-topic';
  static const lesson = 'release-e2e-lesson';
  static const question1 = 'release-e2e-question-1';
  static const question2 = 'release-e2e-question-2';
  static const question3 = 'release-e2e-question-3';
  static const mockBlueprint = 'release-e2e-mock-blueprint';
  static const mockExam = 'release-e2e-mock-exam';
}

const _updatedAt = '2026-01-01T00:00:00.000Z';

Map<String, Object?> releaseTestContentDocument() => <String, Object?>{
      'exam': <Object?>[
        <String, Object?>{
          '_id': ReleaseTestContentIds.exam,
          '_updatedAt': _updatedAt,
          'schemaVersion': SchemaVersions.exam,
          'isActive': true,
          'code': 'RELEASE_E2E',
          'name': 'Release E2E Exam',
          'shortName': 'Release E2E',
          'language': 'en',
          'ordering': 1,
        },
      ],
      'subject': <Object?>[
        <String, Object?>{
          '_id': ReleaseTestContentIds.subject,
          '_updatedAt': _updatedAt,
          'schemaVersion': SchemaVersions.subject,
          'isActive': true,
          'exam': <String, Object?>{'_ref': ReleaseTestContentIds.exam},
          'name': 'Release E2E Subject',
          'ordering': 1,
        },
      ],
      'topic': <Object?>[
        <String, Object?>{
          '_id': ReleaseTestContentIds.topic,
          '_updatedAt': _updatedAt,
          'schemaVersion': SchemaVersions.topic,
          'isActive': true,
          'subject': <String, Object?>{'_ref': ReleaseTestContentIds.subject},
          'name': 'Release E2E Topic',
          'ordering': 1,
        },
      ],
      'passage': <Object?>[],
      'question': <Object?>[
        _question(
          id: ReleaseTestContentIds.question1,
          stem: 'Which number is even?',
          correct: '4',
          incorrect: '3',
        ),
        _question(
          id: ReleaseTestContentIds.question2,
          stem: 'Which number is greater?',
          correct: '9',
          incorrect: '6',
        ),
        _question(
          id: ReleaseTestContentIds.question3,
          stem: 'Which number is smaller?',
          correct: '2',
          incorrect: '5',
        ),
      ],
      'lesson': <Object?>[
        <String, Object?>{
          '_id': ReleaseTestContentIds.lesson,
          '_updatedAt': _updatedAt,
          'schemaVersion': SchemaVersions.lesson,
          'isActive': true,
          'topic': <String, Object?>{'_ref': ReleaseTestContentIds.topic},
          'title': 'Release E2E Lesson',
          'summary': 'A small deterministic lesson for release testing.',
          'estimatedMinutes': 2,
          'ordering': 1,
          'body': _portableText('Read this deterministic release lesson.'),
        },
      ],
      'mockBlueprint': <Object?>[
        <String, Object?>{
          '_id': ReleaseTestContentIds.mockBlueprint,
          '_updatedAt': _updatedAt,
          'schemaVersion': SchemaVersions.mockBlueprint,
          'isActive': true,
          'exam': <String, Object?>{'_ref': ReleaseTestContentIds.exam},
          'name': 'Release E2E Mock Blueprint',
          'durationMinutes': 5,
          'sections': <Object?>[
            <String, Object?>{
              'id': 'release-e2e-section',
              'name': 'Release E2E Section',
              'questionCount': 3,
              'suggestedMinutes': 5,
              'topicIds': <String>[ReleaseTestContentIds.topic],
            },
          ],
        },
      ],
      'mockExam': <Object?>[
        <String, Object?>{
          '_id': ReleaseTestContentIds.mockExam,
          '_updatedAt': _updatedAt,
          'schemaVersion': SchemaVersions.mockExam,
          'isActive': true,
          'blueprint': <String, Object?>{
            '_ref': ReleaseTestContentIds.mockBlueprint,
          },
          'name': 'Release E2E Mock Exam',
          'publishedAt': _updatedAt,
        },
      ],
      'diagnosticSet': <Object?>[],
    };

Map<String, Object?> _question({
  required String id,
  required String stem,
  required String correct,
  required String incorrect,
}) =>
    <String, Object?>{
      '_id': id,
      '_updatedAt': _updatedAt,
      'schemaVersion': SchemaVersions.question,
      'isActive': true,
      'topic': <String, Object?>{'_ref': ReleaseTestContentIds.topic},
      'lesson': <String, Object?>{'_ref': ReleaseTestContentIds.lesson},
      'language': 'en',
      'stem': _portableText(stem),
      'explanation': _portableText('The correct answer is $correct.'),
      'version': 1,
      'choices': <Object?>[
        <String, Object?>{
          '_key': '$id-correct',
          'label': 'A',
          'text': correct,
          'isCorrect': true,
          'rationale': 'This is correct.',
        },
        <String, Object?>{
          '_key': '$id-incorrect',
          'label': 'B',
          'text': incorrect,
          'isCorrect': false,
          'rationale': 'This is not correct.',
        },
      ],
      'examIds': <Object?>[
        <String, Object?>{'_ref': ReleaseTestContentIds.exam},
      ],
    };

List<Object?> _portableText(String text) => <Object?>[
      <String, Object?>{
        '_type': 'block',
        'children': <Object?>[
          <String, Object?>{'_type': 'span', 'text': text},
        ],
      },
    ];

// The picker reads the separate catalog asset, not the fixture's exam table.
final releaseTestCatalogOverride = examPickerCatalogProvider.overrideWith(
  (_) => Stream.value(const <ExamCatalogEntry>[
    ExamCatalogEntry(
      id: ReleaseTestContentIds.exam,
      name: 'Release E2E Exam',
      shortName: 'Release E2E',
      priceTier: 'standard',
      group: 'College entrance',
      comingSoon: false,
      publishedSittings: <PublishedExamSitting>[],
      hasContent: true,
    ),
  ]),
);
