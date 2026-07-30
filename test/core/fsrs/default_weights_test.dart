import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/fsrs/default_weights.dart';

void main() {
  group('FSRS-6 default weights and constants', () {
    test('vector has exactly 21 parameters', () {
      expect(kFsrsDefaultWeights.length, equals(21));
    });

    test('w[20] sits inside published decay bounds [0.1, 0.8]', () {
      expect(kFsrsDefaultWeights[20], inInclusiveRange(0.1, 0.8));
    });

    test('initial stabilities w[0..3] are positive and <= 100', () {
      for (var i = 0; i < 4; i++) {
        expect(kFsrsDefaultWeights[i], greaterThan(0.0));
        expect(kFsrsDefaultWeights[i], lessThanOrEqualTo(100.0));
      }
    });

    test('difficulty and stability bounds are preserved', () {
      expect(kFsrsMinDifficulty, equals(1.0));
      expect(kFsrsMaxDifficulty, equals(10.0));
      expect(kFsrsMinStability, equals(0.1));
      expect(kFsrsMaxStability, equals(36500.0));
      expect(kFsrsTargetRetention, equals(0.9));
    });

    test('decay and factor helpers derive correctly from w[20]', () {
      final decay = fsrsDecay(kFsrsDefaultWeights[20]);
      expect(decay, equals(-kFsrsDefaultWeights[20]));
      final factor = fsrsFactor(kFsrsDefaultWeights[20]);
      expect(factor, closeTo(0.9803, 1e-3));
    });
  });
}
