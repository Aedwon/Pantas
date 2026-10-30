import 'package:cloud_functions/cloud_functions.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/platform/callable_options.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_paper.dart';
import 'package:pantas/features/mock_exam/domain/server_mock_results.dart';

/// Calls one named callable and returns its decoded data.
typedef ServerMockCallable = Future<Object?> Function(
  String name,
  Map<String, Object?> data,
);

/// A refusal or failure from the callable itself, with the server's code
/// (for example `failed-precondition` when a Free account has used its mock).
class ServerMockException implements Exception {
  const ServerMockException({required this.code, this.message});
  final String code;
  final String? message;

  @override
  String toString() => 'ServerMockException($code): $message';
}

enum ServerMockAction { save, pause, resume, discard }

enum ServerMockEndReason {
  student('student'),
  strictExit('strict-exit');

  const ServerMockEndReason(this.wire);
  final String wire;
}

enum ServerMockEndedBy {
  student('student'),
  strictExit('strict-exit'),
  timeOut('time-out');

  const ServerMockEndedBy(this.wire);
  final String wire;
}

@immutable
class ServerMockStart {
  const ServerMockStart({required this.paper, required this.resumed});
  final ServerMockPaper paper;

  /// True when an open mock already existed and this is it, not a new one.
  final bool resumed;
}

/// What getMockPaper found.
sealed class ServerMockRead {
  const ServerMockRead();
}

class ServerMockOpen extends ServerMockRead {
  const ServerMockOpen(this.paper);
  final ServerMockPaper paper;
}

class ServerMockNone extends ServerMockRead {
  const ServerMockNone();
}

/// A strict mock that ran out of time while the student was away. The server
/// has already submitted it.
class ServerMockEnded extends ServerMockRead {
  const ServerMockEnded(this.ended);
  final ServerMockEndedRecord ended;
}

@immutable
class ServerMockEndedRecord {
  const ServerMockEndedRecord({
    required this.mockId,
    required this.endedBy,
    required this.submittedAt,
    required this.correct,
    required this.answered,
    required this.total,
  });
  final String mockId;
  final ServerMockEndedBy endedBy;
  final int submittedAt;
  final int correct;
  final int answered;
  final int total;
}

@immutable
class ServerMockSubmission {
  const ServerMockSubmission({required this.mockId, required this.status});
  final String mockId;
  final String status;
}

/// The four published mock callables: startMock, getMockPaper, controlMock
/// and submitMock. Nothing here invents a callable; the paper, the clock and
/// the identity all come back from the server.
class ServerMockApi {
  const ServerMockApi(this._call);

  /// The deployed callables, in the region the server publishes them.
  factory ServerMockApi.firebase() => ServerMockApi((name, data) async {
        try {
          final result = await FirebaseFunctions.instanceFor(
            region: 'asia-southeast1',
          )
              .httpsCallable(name, options: callableOptionsFor(name))
              .call<Object?>(data);
          return result.data;
        } on FirebaseFunctionsException catch (error) {
          throw ServerMockException(code: error.code, message: error.message);
        }
      });

  final ServerMockCallable _call;

  static final _mockId = RegExp(r'^[A-Za-z0-9]{10,40}$');
  static const _maxIdLength = 128;
  static const _maxChosenLength = 64;
  static const _dayMs = 86400000;

  Future<ServerMockResult> results(String mockId) async {
    _checkMockId(mockId);
    final result = ServerMockResult.decode(
      await _call('getMockResults', {'mockId': mockId}),
    );
    if (result.mockId != mockId) {
      throw const ServerMockFormatException('Result identity differs');
    }
    return result;
  }

  Future<ServerMockHistoryPage> history({Map<String, Object?>? before}) async =>
      ServerMockHistoryPage(
        await _call('getMockHistory', {
          'limit': 100,
          if (before != null) 'before': before,
        }),
      );

  Future<Map<String, Object?>> availability(
    String examId, {
    bool includeSetup = false,
  }) async =>
      serverMockObject(
        await _call(
          'getMockAvailability',
          {'examId': examId, if (includeSetup) 'includeSetup': true},
        ),
      );

  Future<void> saveReview({
    required String mockId,
    required String questionId,
    String? missReason,
    String? blankReason,
    String? reasonNote,
  }) async {
    _checkMockId(mockId);
    final result = serverMockObject(
      await _call('updateMockReview', {
        'mockId': mockId,
        'questionId': questionId,
        'missReason': missReason,
        'blankReason': blankReason,
        'reasonNote': reasonNote,
      }),
    );
    if (result['stored'] != true) {
      throw const ServerMockFormatException('Review note was not saved');
    }
  }

  Future<ServerMockStart> start({
    required String examId,
    required bool strict,
  }) async {
    final reply =
        await _call('startMock', {'examId': examId, 'strict': strict});
    final map = _object(reply);
    final resumed = map['resumed'];
    if (resumed is! bool) {
      throw const ServerMockFormatException('resumed must be a flag');
    }
    return ServerMockStart(
      paper: ServerMockPaper.decode(map),
      resumed: resumed,
    );
  }

  Future<ServerMockRead> read() async {
    final map = _object(await _call('getMockPaper', {}));
    final open = map['open'];
    if (open == true) return ServerMockOpen(ServerMockPaper.decode(map));
    if (open != false) {
      throw const ServerMockFormatException('open must be a flag');
    }
    final ended = map['ended'];
    if (ended == null) return const ServerMockNone();
    final record = _object(ended);
    final score = _object(record['score']);
    final endedBy = ServerMockEndedBy.values
        .where((value) => value.wire == record['endedBy'])
        .firstOrNull;
    final mockId = record['mockId'];
    final submittedAt = record['submittedAt'];
    int whole(Object? value) {
      if (value is int && value >= 0) return value;
      throw const ServerMockFormatException('a count must be whole');
    }

    if (endedBy == null || mockId is! String || !_mockId.hasMatch(mockId)) {
      throw const ServerMockFormatException('the ended mock does not fit');
    }
    return ServerMockEnded(
      ServerMockEndedRecord(
        mockId: mockId,
        endedBy: endedBy,
        submittedAt: whole(submittedAt),
        correct: whole(score['correct']),
        answered: whole(score['answered']),
        total: whole(score['total']),
      ),
    );
  }

  Future<ServerMockPaper> control({
    required String mockId,
    required ServerMockAction action,
    List<ServerMockAnswer>? answers,
  }) async {
    _checkMockId(mockId);
    if (action == ServerMockAction.save) {
      if (answers == null || answers.isEmpty) {
        throw ArgumentError('A save needs at least one answer.');
      }
      _checkAnswers(answers);
    } else if (answers != null) {
      throw ArgumentError('Only a save carries answers.');
    }
    final reply = await _call('controlMock', {
      'mockId': mockId,
      'action': action.name,
      if (answers != null) 'answers': [for (final a in answers) a.toJson()],
    });
    return ServerMockPaper.decode(reply);
  }

  Future<ServerMockSubmission> submit({
    required String mockId,
    required List<ServerMockAnswer> answers,
    required int durationMs,
    required ServerMockEndReason reason,
  }) async {
    _checkMockId(mockId);
    if (reason == ServerMockEndReason.student && answers.isEmpty) {
      throw ArgumentError('A submission needs at least one answer.');
    }
    if (durationMs < 0 || durationMs > _dayMs) {
      throw ArgumentError('The time used must be within a day.');
    }
    _checkAnswers(answers);
    final reply = _object(
      await _call('submitMock', {
        'mockId': mockId,
        'answers': [for (final a in answers) a.toJson()],
        'durationMs': durationMs,
        'reason': reason.wire,
      }),
    );
    final id = reply['mockId'];
    final status = reply['status'];
    if (id != mockId || status != 'submitted') {
      throw const ServerMockFormatException('the mock was not submitted');
    }
    return ServerMockSubmission(mockId: mockId, status: status! as String);
  }

  static void _checkMockId(String mockId) {
    if (!_mockId.hasMatch(mockId)) throw ArgumentError('Bad mock id.');
  }

  static void _checkAnswers(List<ServerMockAnswer> answers) {
    if (answers.length > ServerMockPaper.maxAnswers) {
      throw ArgumentError('Too many answers.');
    }
    for (final answer in answers) {
      final chosen = answer.chosen;
      if (answer.questionId.isEmpty ||
          answer.questionId.length > _maxIdLength ||
          (chosen != null && chosen.length > _maxChosenLength)) {
        throw ArgumentError('An answer does not fit.');
      }
    }
  }

  static Map<String, Object?> _object(Object? value) {
    if (value is! Map) {
      throw const ServerMockFormatException('the reply is not an object');
    }
    return value.cast<String, Object?>();
  }
}
