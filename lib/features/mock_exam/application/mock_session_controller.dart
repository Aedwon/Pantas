import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/domain/mock_session_state.dart';

/// One timed part of the paper.
///
/// A roamable exam gets exactly one of these, covering everything, so the
/// boundary rules below need no branch and nothing reads an exam id.
class MockSessionPart {
  const MockSessionPart({
    required this.name,
    required this.startIndex,
    required this.count,
    this.minutes,
  });

  final String name;
  final int startIndex;
  final int count;

  /// The part's own limit. Null when the exam does not time its parts
  /// separately, in which case the exam's clock governs.
  final int? minutes;

  int get endIndex => startIndex + count - 1;

  bool contains(int index) => index >= startIndex && index <= endIndex;
}

class MockSessionController {
  MockSessionController._({
    required MockSessionState state,
    required List<MockSessionPart> parts,
    required void Function(MockTimeWarning warning)? onWarning,
    required void Function(MockSubmitReason reason)? onSubmit,
    Telemetry telemetry = const DisabledTelemetry(),
  })  : _state = state,
        _parts = parts,
        _onWarning = onWarning,
        _onSubmit = onSubmit,
        _telemetry = telemetry;

  factory MockSessionController.initial({
    required String attemptId,
    required int durationSeconds,
    required List<String> questionIds,
    List<MockSessionPart>? parts,
    bool strictMode = false,
    void Function(MockTimeWarning warning)? onWarning,
    void Function(MockSubmitReason reason)? onSubmit,
    Telemetry telemetry = const DisabledTelemetry(),
  }) {
    telemetry.log(TelemetryEvent.mockStarted);
    return MockSessionController._(
      parts: parts ??
          [
            MockSessionPart(
              name: '',
              startIndex: 0,
              count: questionIds.length,
            ),
          ],
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
      telemetry: telemetry,
    );
  }

  MockSessionState _state;
  final List<MockSessionPart> _parts;
  final void Function(MockTimeWarning warning)? _onWarning;

  /// The exam's elapsed seconds when the open part began, so the part
  /// clock counts the part rather than the exam.
  int _partStartedAtSeconds = 0;
  int _openPartIndex = 0;
  final void Function(MockSubmitReason reason)? _onSubmit;
  final Telemetry _telemetry;
  final _emittedWarnings = <MockTimeWarning>{};

  MockSessionState get state => _state;

  List<MockSessionPart> get parts => List.unmodifiable(_parts);

  int get currentPartIndex => _openPartIndex;

  MockSessionPart get currentPart => _parts[_openPartIndex];

  bool get canGoPrevious {
    final current = _state;
    if (current is! MockSessionInProgress) return false;
    return current.currentIndex > currentPart.startIndex;
  }

  bool get canGoNext {
    final current = _state;
    if (current is! MockSessionInProgress) return false;
    return current.currentIndex < currentPart.endIndex;
  }

  /// What is left of the open part, or of the exam when the parts are not
  /// timed separately.
  Duration get remainingInPart {
    final current = switch (_state) {
      final MockSessionInProgress inProgress => inProgress,
      final MockSessionPaused paused => paused.snapshot,
      final MockSessionSubmitted submitted => submitted.snapshot,
      _ => null,
    };
    if (current == null) return Duration.zero;
    final minutes = currentPart.minutes;
    if (minutes == null) {
      return Duration(seconds: current.remainingSeconds);
    }
    final spent = current.elapsedSeconds - _partStartedAtSeconds;
    final left = (minutes * 60) - spent;
    return Duration(seconds: left < 0 ? 0 : left);
  }

  void goPrevious() {
    if (!canGoPrevious) return;
    final current = _requireInProgress();
    _state = current.copyWith(currentIndex: current.currentIndex - 1);
  }

  void goNext() {
    if (!canGoNext) return;
    final current = _requireInProgress();
    _state = current.copyWith(currentIndex: current.currentIndex + 1);
  }

  /// The grid's destination, refused when it sits outside the open part.
  /// A part that has closed can never be reopened, which is what UPCAT
  /// means by not returning to a subtest once time is called.
  void goTo(int index) {
    final current = _requireInProgress();
    if (!currentPart.contains(index)) return;
    _state = current.copyWith(currentIndex: index);
  }

  /// Ends the open part and opens the next. Closing the last one ends the
  /// exam.
  void closeCurrentPart() {
    final current = _requireInProgress();
    if (_openPartIndex >= _parts.length - 1) {
      _submit(MockSubmitReason.timeUp);
      return;
    }
    _openPartIndex += 1;
    _partStartedAtSeconds = current.elapsedSeconds;
    _state = current.copyWith(currentIndex: currentPart.startIndex);
  }

  void endPartEarly() => closeCurrentPart();

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
      return;
    }
    // A part can run out while the exam has hours left.
    final minutes = currentPart.minutes;
    if (minutes != null &&
        next.elapsedSeconds - _partStartedAtSeconds >= minutes * 60) {
      closeCurrentPart();
    }
  }

  void strictBackgroundExceeded() {
    final current = _requireInProgress();
    if (!current.strictMode) return;
    _state = const MockSessionForfeited(MockSubmitReason.strictBackground);
    _telemetry.log(TelemetryEvent.mockAbandoned);
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
    final snapshot = _state as MockSessionInProgress;
    _state = MockSessionSubmitted(reason, snapshot);
    _telemetry.log(TelemetryEvent.mockCompleted);
    _onSubmit?.call(reason);
  }
}
