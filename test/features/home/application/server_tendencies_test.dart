import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/application/server_tendencies.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';

void main() {
  test('Free profile has its approved identity but no paid findings', () {
    final value = StudyInsights.decode(
      {
        'examId': 'e',
        'serverNow': 1,
        'proCovered': false,
        'revision': 'r',
        'profile': {'id': 'deep_thinker'},
        'performance': {
          'overall': {'correct': 0, 'answered': 0},
          'subjects': <Object?>[],
          'lessonLevelAvailable': true,
        },
      },
      examId: 'e',
    );
    final work = serverTendencies(value, name: 'Ana');
    expect(work.archetype, 'Deep Thinker');
    expect(work.archetypeLine, 'You take your sweet time, and it shows.');
    expect(work.tendencies, hasLength(5));
    expect(work.tendencies.every((t) => t.leftFigure == null), isTrue);
    expect(work.whenYouWork, isEmpty);
  });
  test('forming server evidence retains its state and never exposes figures',
      () {
    final value = StudyInsights.decode(
      {
        'examId': 'e',
        'serverNow': 1,
        'proCovered': true,
        'revision': 'r',
        'performance': {
          'overall': {'correct': 0, 'answered': 0},
          'subjects': <Object?>[],
          'lessonLevelAvailable': true,
        },
        'tendencies': {
          for (final key in ['pressure', 'stamina', 'study', 'speed', 'memory'])
            key: {
              'confidence': 'forming',
              'value': null,
              'unmetRequirements': <String>[],
            },
        },
      },
      examId: 'e',
    );
    final work = serverTendencies(value, name: null);
    expect(work.tendencies.every((t) => t.unlockAction.isEmpty), isTrue);
    expect(
      work.tendencies.every((t) => t.confidence == TendencyConfidence.forming),
      isTrue,
    );
    expect(
      work.tendencies.every((t) => t.sentence == null && t.leftFigure == null),
      isTrue,
    );
  });
}
