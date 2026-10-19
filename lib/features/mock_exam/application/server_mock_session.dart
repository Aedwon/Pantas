import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pantas/features/mock_exam/data/server_mock_api.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';

/// Where the web paper keeps what the server does not: which question the
/// student is on and which they flagged. It never holds the paper, the clock
/// or an answer, and every key carries the account and mock it belongs to.
// ignore: one_member_abstracts
abstract interface class ServerMockViewStore {
  Future<void> write({
    required String uid,
    required String mockId,
    required int cursor,
    required Set<String> flags,
  });
}

enum ServerMockOperation { save, pause, resume, discard, submit }

/// The last operation the server did not take, kept so Retry sends exactly
/// what was meant at the time.
@immutable
class ServerMockFailure {
  const ServerMockFailure({required this.operation, required this.error});
  final ServerMockOperation operation;
  final Object error;
}

/// An answer held on this device until the server has it.
@immutable
class ServerMockLocalAnswer {
  const ServerMockLocalAnswer({
    required this.chosen,
    required this.correct,
    required this.answeredAt,
  });
  final String? chosen;
  final bool correct;
  final int answeredAt;
}

/// The one open mock on the web. The server owns the paper, the clock and
/// the answers; this keeps the student's view of them and sends changes in
/// order.
///
/// - Every response replaces the paper and clock. The clock between
///   responses is a display-only count from a monotonic reading; the server
///   is never called on a tick.
/// - Changes go out one at a time in the order they were made, so a slow
///   earlier save cannot land after a newer one or after the submission.
/// - A change that fails keeps the exact payload it was made with. Retry
///   sends that payload, never one rebuilt from newer state.
/// - Everything is bound to the account that opened it. If the account
///   changes or the session is disposed, queued work is dropped and nothing
///   is published or cached.
class ServerMockSession extends ChangeNotifier {
  ServerMockSession({
    required this.api,
    required ServerMockPaper paper,
    required this.uid,
    required String? Function() currentUid,
    required Duration Function() elapsed,
    Map<String, int> restoredIndexes = const {},
    int cursor = 0,
    Set<String> flags = const {},
    this.viewStore,
    this.saveDelay = const Duration(milliseconds: 600),
  })  : _paper = paper,
        _currentUid = currentUid,
        _elapsed = elapsed,
        _anchor = elapsed(),
        _cursor = cursor.clamp(0, paper.questionIds.length - 1),
        _flags = {
          for (final id in flags)
            if (paper.questionIds.contains(id)) id,
        },
        _indexes = {
          for (final entry in restoredIndexes.entries)
            if (paper.answers[entry.key]?.chosen != null)
              entry.key: entry.value,
        } {
    _answers = _fromServer(paper);
  }

  final ServerMockApi api;
  final String uid;
  final ServerMockViewStore? viewStore;
  final Duration saveDelay;
  final String? Function() _currentUid;
  final Duration Function() _elapsed;

  ServerMockPaper _paper;
  Duration _anchor;
  late Map<String, ServerMockLocalAnswer> _answers;
  final Map<String, int> _indexes;
  int _cursor;
  final Set<String> _flags;

  Timer? _saveTimer;
  final _queue = <_Operation>[];
  var _running = false;
  _Operation? _failedOperation;
  ServerMockFailure? _failure;
  var _saveCounter = 0;
  var _lastAckedSave = 0;
  var _disposed = false;
  var _stale = false;
  var _submitted = false;
  Duration? _frozenAt;

  ServerMockPaper get paper => _paper;
  String get mockId => _paper.mockId;
  bool get strict => _paper.strict;
  bool get paused => _paper.paused;
  bool get submitted => _submitted;

  /// True once the account changed under this session. The paper is then
  /// neither shown nor written to.
  bool get stale => _stale;
  ServerMockFailure? get failure => _failure;
  int get cursor => _cursor;
  Set<String> get flags => Set.unmodifiable(_flags);
  Map<String, ServerMockLocalAnswer> get answers => Map.unmodifiable(_answers);
  int? selectedIndexOf(String questionId) => _indexes[questionId];
  bool get hasPendingWork =>
      _saveTimer != null || _queue.isNotEmpty || _running;

  /// What the clock shows. It stands still while paused or once a pause has
  /// been asked for, and it never drops below zero.
  Duration get remaining {
    final frozen = _frozenAt;
    if (frozen != null) return frozen;
    if (_paper.paused || _submitted) return _paper.remaining;
    final left = _paper.remaining - (_elapsed() - _anchor);
    return left.isNegative ? Duration.zero : left;
  }

  bool get timeIsUp => remaining == Duration.zero;

  Duration get used => _paper.limit - remaining;

  // ---- what the student does ----------------------------------------------

  void goTo(int index) {
    if (_blocked) return;
    final next = index.clamp(0, _paper.questionIds.length - 1);
    if (next == _cursor) return;
    _cursor = next;
    _remember();
    notifyListeners();
  }

  void toggleFlag(String questionId) {
    if (_blocked || !_paper.questionIds.contains(questionId)) return;
    if (!_flags.add(questionId)) _flags.remove(questionId);
    _remember();
    notifyListeners();
  }

  /// Records a choice and schedules one save of every answer so far.
  void answer(
    String questionId, {
    required String chosen,
    required int selectedIndex,
    required bool correct,
  }) {
    if (_blocked || _paper.paused || _frozenAt != null) return;
    if (!_paper.questionIds.contains(questionId) ||
        chosen.isEmpty ||
        chosen.length > 64) {
      return;
    }
    _answers = {
      ..._answers,
      questionId: ServerMockLocalAnswer(
        chosen: chosen,
        correct: correct,
        answeredAt: _paper.startedAt + used.inMilliseconds,
      ),
    };
    _indexes[questionId] = selectedIndex;
    notifyListeners();
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, _queueSave);
  }

  /// Sends the pending save now and waits for everything queued.
  Future<void> flush() {
    if (_saveTimer != null) _queueSave();
    return _idle();
  }

  Future<bool> pause() async {
    if (_blocked || _paper.strict || _paper.paused) return false;
    _frozenAt = remaining;
    notifyListeners();
    final ok = await _enqueue(_Operation.control(ServerMockOperation.pause));
    if (!ok) _unfreeze();
    return ok;
  }

  Future<bool> resume() async {
    if (_blocked || _paper.strict || !_paper.paused) return false;
    return _enqueue(_Operation.control(ServerMockOperation.resume));
  }

  /// Clears the answers and restarts the clock on the same paper.
  Future<bool> discard() async {
    if (_blocked || _paper.strict) return false;
    _cancelSave();
    return _enqueue(_Operation.control(ServerMockOperation.discard));
  }

  /// Submits every pinned question: the answers given, and a blank for each
  /// question left. A strict exit may carry nothing.
  Future<bool> submit(ServerMockEndReason reason) async {
    if (_blocked) return false;
    _cancelSave();
    for (final queued in _queue) {
      queued.superseded = true;
    }
    final answers = reason == ServerMockEndReason.strictExit
        ? <ServerMockAnswer>[]
        : _everyAnswer();
    return _enqueue(
      _Operation.submit(
        answers: List.unmodifiable(answers),
        durationMs: used.inMilliseconds.clamp(0, 86400000),
        reason: reason,
      ),
    );
  }

  /// Sends the failed operation again with the payload it first had.
  Future<bool> retry() async {
    final failed = _failedOperation;
    if (failed == null || _blocked) return false;
    _failedOperation = null;
    _failure = null;
    notifyListeners();
    if (failed.kind == ServerMockOperation.save &&
        failed.saveNumber < _lastAckedSave) {
      return true;
    }
    return _enqueue(failed.again());
  }

  // ---- internals ----------------------------------------------------------

  bool get _blocked => _disposed || _stale || _submitted;

  void _unfreeze() {
    _frozenAt = null;
    notifyListeners();
  }

  void _cancelSave() {
    _saveTimer?.cancel();
    _saveTimer = null;
  }

  List<ServerMockAnswer> _everyAnswer() => [
        for (final id in _paper.questionIds)
          ServerMockAnswer(
            questionId: id,
            chosen: _answers[id]?.chosen,
            correct: _answers[id]?.correct ?? false,
            answeredAt: _answers[id]?.answeredAt ??
                _paper.startedAt + used.inMilliseconds,
          ),
      ];

  void _queueSave() {
    _saveTimer = null;
    if (_blocked) return;
    final answered = [
      for (final id in _paper.questionIds)
        if (_answers[id]?.chosen != null)
          ServerMockAnswer(
            questionId: id,
            chosen: _answers[id]!.chosen,
            correct: _answers[id]!.correct,
            answeredAt: _answers[id]!.answeredAt,
          ),
    ];
    if (answered.isEmpty) return;
    for (final queued in _queue) {
      if (queued.kind == ServerMockOperation.save) queued.superseded = true;
    }
    unawaited(_enqueue(_Operation.save(++_saveCounter, answered)));
  }

  Future<void> _idle() async {
    while (_running || _queue.isNotEmpty) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  Future<bool> _enqueue(_Operation operation) {
    _queue.add(operation);
    unawaited(_pump());
    return operation.done.future;
  }

  Future<void> _pump() async {
    if (_running) return;
    _running = true;
    try {
      while (_queue.isNotEmpty) {
        final operation = _queue.removeAt(0);
        if (operation.superseded || _blocked) {
          operation.done.complete(false);
          continue;
        }
        await _run(operation);
      }
    } finally {
      _running = false;
    }
  }

  bool _actorChanged() => _currentUid() != uid;

  Future<void> _run(_Operation operation) async {
    if (_actorChanged()) {
      _stale = true;
      operation.done.complete(false);
      if (!_disposed) notifyListeners();
      return;
    }
    try {
      switch (operation.kind) {
        case ServerMockOperation.submit:
          await api.submit(
            mockId: mockId,
            answers: operation.answers,
            durationMs: operation.durationMs,
            reason: operation.reason,
          );
          if (_publishable) {
            _submitted = true;
            _frozenAt = null;
            _failure = null;
            _failedOperation = null;
            notifyListeners();
          }
        case ServerMockOperation.save:
          final view = await api.control(
            mockId: mockId,
            action: ServerMockAction.save,
            answers: operation.answers,
          );
          if (_publishable) {
            _lastAckedSave = operation.saveNumber;
            _adopt(view, replaceAnswers: false);
            if (_failedOperation?.kind == ServerMockOperation.save) {
              _failedOperation = null;
              _failure = null;
            }
            notifyListeners();
          }
        case ServerMockOperation.pause:
        case ServerMockOperation.resume:
        case ServerMockOperation.discard:
          final view = await api.control(
            mockId: mockId,
            action: ServerMockAction.values.byName(operation.kind.name),
          );
          if (_publishable) {
            _frozenAt = null;
            _adopt(
              view,
              replaceAnswers: operation.kind == ServerMockOperation.discard,
            );
            _failedOperation = null;
            _failure = null;
            notifyListeners();
          }
      }
      operation.done.complete(_publishable || _submitted);
    } on Object catch (error) {
      if (_publishable) {
        _failedOperation = operation;
        _failure = ServerMockFailure(
          operation: operation.kind,
          error: error,
        );
        notifyListeners();
      }
      operation.done.complete(false);
    }
  }

  /// A response may only be shown while it still belongs to this account.
  bool get _publishable {
    if (_disposed || _stale) return false;
    if (_actorChanged()) {
      _stale = true;
      return false;
    }
    return true;
  }

  void _adopt(ServerMockPaper view, {required bool replaceAnswers}) {
    if (view.mockId != _paper.mockId) {
      throw const ServerMockFormatException('the response is for another mock');
    }
    _paper = view;
    _anchor = _elapsed();
    if (replaceAnswers) {
      _answers = _fromServer(view);
      _indexes.clear();
      _flags.clear();
      _cursor = 0;
      _remember();
    }
  }

  static Map<String, ServerMockLocalAnswer> _fromServer(
    ServerMockPaper paper,
  ) =>
      {
        for (final entry in paper.answers.entries)
          if (entry.value.chosen != null)
            entry.key: ServerMockLocalAnswer(
              chosen: entry.value.chosen,
              correct: entry.value.correct,
              answeredAt: entry.value.answeredAt,
            ),
      };

  void _remember() {
    final store = viewStore;
    if (store == null || _disposed || _stale || _actorChanged()) return;
    unawaited(
      store
          .write(
            uid: uid,
            mockId: mockId,
            cursor: _cursor,
            flags: Set.of(_flags),
          )
          .catchError((Object _) {}),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _saveTimer?.cancel();
    for (final queued in _queue) {
      queued.superseded = true;
    }
    super.dispose();
  }
}

class _Operation {
  _Operation._({
    required this.kind,
    this.answers = const [],
    this.durationMs = 0,
    this.reason = ServerMockEndReason.student,
    this.saveNumber = 0,
  });

  factory _Operation.control(ServerMockOperation kind) =>
      _Operation._(kind: kind);

  factory _Operation.save(int number, List<ServerMockAnswer> answers) =>
      _Operation._(
        kind: ServerMockOperation.save,
        answers: List.unmodifiable(answers),
        saveNumber: number,
      );

  factory _Operation.submit({
    required List<ServerMockAnswer> answers,
    required int durationMs,
    required ServerMockEndReason reason,
  }) =>
      _Operation._(
        kind: ServerMockOperation.submit,
        answers: answers,
        durationMs: durationMs,
        reason: reason,
      );

  final ServerMockOperation kind;
  final List<ServerMockAnswer> answers;
  final int durationMs;
  final ServerMockEndReason reason;
  final int saveNumber;
  bool superseded = false;
  Completer<bool> done = Completer<bool>();

  /// The same payload, ready to send again.
  _Operation again() => _Operation._(
        kind: kind,
        answers: answers,
        durationMs: durationMs,
        reason: reason,
        saveNumber: saveNumber,
      );
}
