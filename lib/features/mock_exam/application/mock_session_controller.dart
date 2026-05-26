import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_results.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_session_state.dart';

class MockSessionController {
  MockSessionController._({
    required MockSessionState state,
    required void Function(MockTimeWarning warning)? onWarning,
    required void Function(MockSubmitReason reason)? onSubmit,
  })  : _state = state,
        _onWarning = onWarning,
        _onSubmit = onSubmit;

  factory MockSessionController.initial({
    required String attemptId,
    required int durationSeconds,
    required List<String> questionIds,
    bool strictMode = false,
    void Function(MockTimeWarning warning)? onWarning,
    void Function(MockSubmitReason reason)? onSubmit,
  }) {
    return MockSessionController._(
      state: MockSessionInProgress(
        attemptId: attemptId,
        durationSeconds: durationSeconds,
        questionIds: List.unmodifiable(questionIds),
        currentIndex: 0,
        elapsedSeconds: 0,
        answers: const {},
        flags: const {},
        strictMode: strictMode,
      ),
      onWarning: onWarning,
      onSubmit: onSubmit,
    );
  }

  MockSessionState _state;
  final void Function(MockTimeWarning warning)? _onWarning;
  final void Function(MockSubmitReason reason)? _onSubmit;
  final _emittedWarnings = <MockTimeWarning>{};

  MockSessionState get state => _state;

  bool get canPause {
    final current = _state;
    return current is MockSessionInProgress && !current.strictMode;
  }

  void answerCurrent(int selectedIndex) {
    final current = _requireInProgress();
    final answers = Map<String, MockAnswer>.of(current.answers)
      ..[current.currentQuestionId] = MockAnswer(
        selectedIndex: selectedIndex,
        atSec: current.elapsedSeconds,
      );
    _state = current.copyWith(answers: Map.unmodifiable(answers));
  }

  void toggleFlag() {
    final current = _requireInProgress();
    final flags = Set<String>.of(current.flags);
    if (!flags.add(current.currentQuestionId)) {
      flags.remove(current.currentQuestionId);
    }
    _state = current.copyWith(flags: Set.unmodifiable(flags));
  }

  void pause() {
    final current = _requireInProgress();
    if (current.strictMode) {
      throw StateError('Strict mock sessions cannot pause');
    }
    _state = MockSessionPaused(current);
  }

  void resume() {
    final current = _state;
    if (current is! MockSessionPaused) {
      throw StateError('Mock session is not paused');
    }
    _state = current.snapshot;
  }

  void tickTo(int elapsedSeconds) {
    final current = _requireInProgress();
    final nextElapsed = elapsedSeconds > current.durationSeconds
        ? current.durationSeconds
        : elapsedSeconds;
    final next = current.copyWith(elapsedSeconds: nextElapsed);
    _state = next;
    _emitWarnings(next);
    if (next.remainingSeconds <= 0) {
      _submit(MockSubmitReason.timeUp);
    }
  }

  void strictBackgroundExceeded() {
    final current = _requireInProgress();
    if (!current.strictMode) return;
    _state = const MockSessionForfeited(MockSubmitReason.strictBackground);
    _onSubmit?.call(MockSubmitReason.strictBackground);
  }

  MockSessionInProgress _requireInProgress() {
    final current = _state;
    if (current is MockSessionInProgress) return current;
    throw StateError('Mock session is not in progress');
  }

  void _emitWarnings(MockSessionInProgress state) {
    final remaining = state.remainingSeconds;
    if (remaining == 300) _emitWarning(MockTimeWarning.fiveMinutes);
    if (remaining == 60) _emitWarning(MockTimeWarning.oneMinute);
  }

  void _emitWarning(MockTimeWarning warning) {
    if (_emittedWarnings.add(warning)) _onWarning?.call(warning);
  }

  void _submit(MockSubmitReason reason) {
    _state = MockSessionSubmitted(reason);
    _onSubmit?.call(reason);
  }
}
