import 'dart:async';

import 'package:cse_cet_reviewer/core/telemetry/error_boundary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what the boundary forwards. The repo has no mocking package, so a
/// plain recorder is the house style.
class _Recorder {
  final errors = <Object>[];
  final stacks = <StackTrace>[];

  void call(Object error, StackTrace stack) {
    errors.add(error);
    stacks.add(stack);
  }
}

void main() {
  late FlutterExceptionHandler? originalFlutterOnError;
  late bool Function(Object, StackTrace)? originalPlatformOnError;

  setUp(() {
    originalFlutterOnError = FlutterError.onError;
    originalPlatformOnError = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    FlutterError.onError = originalFlutterOnError;
    PlatformDispatcher.instance.onError = originalPlatformOnError;
  });

  test('an error inside the widget framework reaches onError', () async {
    final recorder = _Recorder();

    await runGuarded(() async {}, onError: recorder.call);

    // Stands in for a throw during build: the framework routes those here.
    FlutterError.onError!(
      FlutterErrorDetails(
        exception: StateError('build blew up'),
        stack: StackTrace.current,
      ),
    );

    expect(recorder.errors, hasLength(1));
    expect(recorder.errors.single, isA<StateError>());
  });

  test('an error outside the widget framework reaches onError', () async {
    final recorder = _Recorder();

    await runGuarded(() async {}, onError: recorder.call);

    final handled = PlatformDispatcher.instance.onError!(
      StateError('platform blew up'),
      StackTrace.current,
    );

    expect(handled, isTrue, reason: 'the boundary must claim the error');
    expect(recorder.errors, hasLength(1));
    expect(recorder.errors.single, isA<StateError>());
  });

  test('an asynchronous error escaping both reaches onError', () async {
    final recorder = _Recorder();

    await runGuarded(
      () async {
        // Escapes the awaited chain, so only the guarded zone can catch it.
        unawaited(Future<void>.error(StateError('async blew up')));
      },
      onError: recorder.call,
    );

    // Let the microtask queue drain so the zone sees it.
    await Future<void>.delayed(Duration.zero);

    expect(recorder.errors, hasLength(1));
    expect(recorder.errors.single, isA<StateError>());
  });

  test('onError receives the stack, not just the error', () async {
    final recorder = _Recorder();

    await runGuarded(() async {}, onError: recorder.call);

    FlutterError.onError!(
      FlutterErrorDetails(
        exception: StateError('x'),
        stack: StackTrace.current,
      ),
    );

    expect(recorder.stacks, hasLength(1));
    expect(recorder.stacks.single, isNot(StackTrace.empty));
  });

  test('a FlutterErrorDetails with no stack still reports', () async {
    final recorder = _Recorder();

    await runGuarded(() async {}, onError: recorder.call);

    // `stack` is nullable on FlutterErrorDetails. Dropping the report because
    // the stack is absent would lose the error entirely.
    FlutterError.onError!(FlutterErrorDetails(exception: StateError('x')));

    expect(recorder.errors, hasLength(1));
    expect(recorder.stacks, hasLength(1));
  });

  test('the body runs, and its result is awaited', () async {
    final recorder = _Recorder();
    var ran = false;

    await runGuarded(
      () async {
        await Future<void>.delayed(Duration.zero);
        ran = true;
      },
      onError: recorder.call,
    );

    expect(ran, isTrue);
    expect(recorder.errors, isEmpty);
  });
}
