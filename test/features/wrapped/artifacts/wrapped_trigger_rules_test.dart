import 'package:pantas/features/wrapped/artifacts/mastery_crossing_artifact.dart';
import 'package:pantas/features/wrapped/artifacts/post_exam_debrief_artifact.dart';
import 'package:pantas/features/wrapped/artifacts/post_mock_recap_artifact.dart';
import 'package:pantas/features/wrapped/artifacts/streak_milestone_artifact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('post mock recap fires for first mock or new personal best only', () {
    const artifact = PostMockRecapArtifact();

    expect(
      artifact.shouldFire(scorePercent: 0.6, previousBestPercent: null),
      isTrue,
    );
    expect(
      artifact.shouldFire(scorePercent: 0.8, previousBestPercent: 0.7),
      isTrue,
    );
    expect(
      artifact.shouldFire(scorePercent: 0.7, previousBestPercent: 0.8),
      isFalse,
    );
  });

  test('streak milestone fires only at locked thresholds', () {
    const artifact = StreakMilestoneArtifact();

    expect(artifact.shouldFire(7), isTrue);
    expect(artifact.shouldFire(30), isTrue);
    expect(artifact.shouldFire(100), isTrue);
    expect(artifact.shouldFire(365), isTrue);
    expect(artifact.shouldFire(31), isFalse);
  });

  test('mastery crossing fires only weak to strong at stability 14 days', () {
    const artifact = MasteryCrossingArtifact();

    expect(
      artifact.shouldFire(previousStability: 8, nextStability: 14),
      isTrue,
    );
    expect(
      artifact.shouldFire(previousStability: 13.9, nextStability: 13.95),
      isFalse,
    );
    expect(
      artifact.shouldFire(previousStability: 15, nextStability: 20),
      isFalse,
    );
  });

  test('post exam debrief fires day after exam once per prep cycle', () {
    const artifact = PostExamDebriefArtifact();
    final examDate = DateTime(2026, 6, 10);

    expect(
      artifact.shouldFire(
        localDate: DateTime(2026, 6, 11),
        examDate: examDate,
        alreadyFired: false,
      ),
      isTrue,
    );
    expect(
      artifact.shouldFire(
        localDate: DateTime(2026, 6, 11),
        examDate: examDate,
        alreadyFired: true,
      ),
      isFalse,
    );
    expect(
      artifact.shouldFire(
        localDate: DateTime(2026, 6, 10),
        examDate: examDate,
        alreadyFired: false,
      ),
      isFalse,
    );
  });
}
