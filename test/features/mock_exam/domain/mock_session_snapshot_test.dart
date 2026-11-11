import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

void main() {
  test('snapshot round-trip keeps answers flags and sectional clock', () {
    const codec = MockSessionSnapshotCodec();
    const sample = MockSample(
      expectedQuestionCount: 3,
      sections: [
        SampledMockSection(
          sectionId: 's1',
          name: 'Part 1',
          questionIds: ['q1', 'q2'],
        ),
        SampledMockSection(
          sectionId: 's2',
          name: 'Part 2',
          questionIds: ['q3'],
        ),
      ],
    );
    const answers = {
      'q1': MockAnswer(selectedIndex: 1, atSec: 42),
    };
    final backgroundedAt = DateTime.utc(2026, 9, 4, 12);

    final restored = codec.decode(
      sampledQuestionsJson: codec.encodeSample(
        sample,
        currentPartIndex: 1,
        partStartedAtSeconds: 120,
        partsTimedSeparately: true,
        parts: const [
          MockPersistedPart(
            name: 'Part 1',
            startIndex: 0,
            count: 2,
            minutes: 2,
          ),
          MockPersistedPart(
            name: 'Part 2',
            startIndex: 2,
            count: 1,
            minutes: 1,
          ),
        ],
        strictBackgroundedAt: backgroundedAt,
      ),
      answersJson: codec.encodeAnswers(answers),
      flagsJson: codec.encodeFlags(const {'q2'}),
    );

    expect(restored.sample.sections[1].questionIds, ['q3']);
    expect(restored.answers, answers);
    expect(restored.flags, {'q2'});
    expect(restored.currentPartIndex, 1);
    expect(restored.partStartedAtSeconds, 120);
    expect(restored.partsTimedSeparately, isTrue);
    expect(restored.parts, const [
      MockPersistedPart(
        name: 'Part 1',
        startIndex: 0,
        count: 2,
        minutes: 2,
      ),
      MockPersistedPart(
        name: 'Part 2',
        startIndex: 2,
        count: 1,
        minutes: 1,
      ),
    ]);
    expect(restored.strictBackgroundedAt, backgroundedAt);
  });
}
