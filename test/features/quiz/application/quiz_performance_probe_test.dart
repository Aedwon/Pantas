import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/quiz/application/quiz_performance_probe.dart';

void main() {
  test('disabled probe delegates operations without collecting samples',
      () async {
    const probe = QuizPerformanceProbe.disabled();
    var calls = 0;

    final asyncResult = await probe.measureAsync(
      QuizPerformancePhase.scopeResolution,
      () async {
        calls += 1;
        return 7;
      },
    );
    final syncResult = probe.measureSync(
      QuizPerformancePhase.selection,
      () {
        calls += 1;
        return 11;
      },
    );

    expect(probe.enabled, isFalse);
    expect(asyncResult, 7);
    expect(syncResult, 11);
    expect(calls, 2);
  });

  test('recording probe emits fixed structured phase samples', () async {
    final samples = <QuizPerformanceSample>[];
    final probe = QuizPerformanceProbe.recording(samples.add);

    await probe.measureAsync(
      QuizPerformancePhase.hydration,
      () async => 1,
    );
    probe.measureSync(QuizPerformancePhase.selection, () => 2);

    expect(probe.enabled, isTrue);
    expect(
      samples.map((sample) => sample.phase),
      [QuizPerformancePhase.hydration, QuizPerformancePhase.selection],
    );
    expect(samples.every((sample) => sample.elapsed >= Duration.zero), isTrue);
    expect(samples.first.toJson().keys, {'phase', 'elapsed_us'});
    expect(samples.first.toJson()['phase'], 'hydration');
  });
}
