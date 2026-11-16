import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// What was counted over one finger drag, or over the fling after it.
class InputWindow {
  const InputWindow({
    required this.elapsed,
    required this.frames,
    required this.vsyncs,
    required this.movedFrames,
    required this.moves,
    required this.batches,
    required this.stamps,
  });

  final Duration elapsed;

  /// Frames Flutter drew.
  final int frames;

  /// Screen refreshes, counted whether or not Flutter drew.
  final int vsyncs;

  /// Drawn frames in which the scroll position changed.
  final int movedFrames;

  /// Pointer move events as Flutter received them, one per expanded sample.
  final int moves;

  /// Groups of move events delivered together.
  final int batches;

  /// Distinct timestamps among the move events.
  final int stamps;

  double _perSecond(int count) =>
      elapsed.inMicroseconds == 0 ? 0 : count * 1e6 / elapsed.inMicroseconds;

  double get framesPerSecond => _perSecond(frames);
  double get vsyncsPerSecond => _perSecond(vsyncs);
  double get movesPerSecond => _perSecond(moves);
  double get batchesPerSecond => _perSecond(batches);

  /// Share of drawn frames in which the list moved, or null with no frames.
  double? get movedShare => frames == 0 ? null : movedFrames / frames;

  /// Screen refreshes in which the list did not move: vsyncs minus the drawn
  /// frames that moved. A refresh Flutter skipped counts here.
  int get vsyncsWithoutMove => vsyncs - movedFrames;

  Map<String, Object?> toJson() => {
        'ms': elapsed.inMilliseconds,
        'frames': frames,
        'vsyncs': vsyncs,
        'movedFrames': movedFrames,
        'moves': moves,
        'batches': batches,
        'stamps': stamps,
      };
}

/// The last finger drag and the last fling, either of which may not exist yet.
class InputCheckReport {
  const InputCheckReport({this.drag, this.fling});

  final InputWindow? drag;
  final InputWindow? fling;

  Map<String, Object?> toJson() => {
        'drag': drag?.toJson(),
        'fling': fling?.toJson(),
      };
}

enum _Phase { idle, drag, fling }

/// Counts frames, screen refreshes, pointer moves and scroll movement for the
/// last drag and fling. It owns no listeners: [installInputCheckProbe] and the
/// overlay feed it, so tests can feed it directly.
///
/// A drag runs from a finger down to its release. A fling runs from the
/// release to the scroll ending, or to the next finger down. A drag in which
/// nothing scrolled (a tap, a drag off any list) is dropped.
class InputCheckProbe {
  InputCheckProbe({Duration Function()? clock, this.onPublish})
      : _clock = clock ?? _wallClock();

  final Duration Function() _clock;

  /// Called with the report as plain data each time a window closes.
  final void Function(Map<String, Object?> data)? onPublish;

  final report = ValueNotifier<InputCheckReport>(const InputCheckReport());

  /// Every closed window in order, for headless runs.
  final List<Map<String, Object?>> log = [];

  _Phase _phase = _Phase.idle;
  bool _disposed = false;
  int? _pointer;
  Duration _start = Duration.zero;
  bool _sawScroll = false;
  bool _moveSinceFrame = false;
  bool _inBatch = false;
  Duration? _lastStamp;
  int _frames = 0;
  int _vsyncs = 0;
  int _movedFrames = 0;
  int _moves = 0;
  int _batches = 0;
  int _stamps = 0;

  static Duration Function() _wallClock() {
    final watch = Stopwatch()..start();
    return () => watch.elapsed;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    report.dispose();
  }

  /// A pointer event from the pointer router, after Flutter's own handling.
  void onPointer(PointerEvent event) {
    if (_disposed) return;
    if (event is PointerDownEvent) {
      if (_phase == _Phase.drag) return; // a second finger
      if (_phase == _Phase.fling) _closeFling();
      _pointer = event.pointer;
      _open(_Phase.drag);
      return;
    }
    if (_phase != _Phase.drag || event.pointer != _pointer) return;
    if (event is PointerMoveEvent) {
      _moves++;
      if (!_inBatch) {
        _inBatch = true;
        _batches++;
        scheduleMicrotask(() => _inBatch = false);
      }
      if (event.timeStamp != _lastStamp) {
        _lastStamp = event.timeStamp;
        _stamps++;
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      _closeDrag();
    }
  }

  /// A scroll notification, from the root of the app.
  void onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      onScrollUpdate(notification.scrollDelta ?? 0);
    } else if (notification is ScrollEndNotification) {
      onScrollEnd();
    }
  }

  void onScrollUpdate(double delta) {
    if (_disposed || _phase == _Phase.idle || delta == 0) return;
    _moveSinceFrame = true;
    _sawScroll = true;
  }

  void onScrollEnd() {
    if (_disposed || _phase != _Phase.fling) return;
    _closeFling();
  }

  /// One frame Flutter drew.
  void onFrame() {
    if (_disposed) return;
    if (_phase != _Phase.idle) {
      _frames++;
      if (_moveSinceFrame) _movedFrames++;
    }
    _moveSinceFrame = false;
  }

  /// One screen refresh.
  void onVsync() {
    if (_disposed || _phase == _Phase.idle) return;
    _vsyncs++;
  }

  void _open(_Phase phase) {
    _phase = phase;
    _start = _clock();
    _sawScroll = false;
    _frames = _vsyncs = _movedFrames = _moves = _batches = _stamps = 0;
    _inBatch = false;
    _lastStamp = null;
  }

  InputWindow _snapshot() => InputWindow(
        elapsed: _clock() - _start,
        frames: _frames,
        vsyncs: _vsyncs,
        movedFrames: _movedFrames,
        moves: _moves,
        batches: _batches,
        stamps: _stamps,
      );

  void _closeDrag() {
    final window = _snapshot();
    final scrolled = _sawScroll;
    _phase = _Phase.idle;
    if (!scrolled) return;
    _publish('drag', window, drag: window);
    _open(_Phase.fling);
  }

  void _closeFling() {
    final window = _snapshot();
    final scrolled = _sawScroll;
    _phase = _Phase.idle;
    // A drag that ended with no speed has no fling to show.
    _publish(
      'fling',
      scrolled ? window : null,
      fling: scrolled ? window : null,
    );
  }

  void _publish(
    String kind,
    InputWindow? window, {
    InputWindow? drag,
    InputWindow? fling,
  }) {
    final previous = report.value;
    report.value = InputCheckReport(
      drag: kind == 'drag' ? drag : previous.drag,
      fling: kind == 'fling' ? fling : previous.fling,
    );
    if (window != null) log.add({'kind': kind, ...window.toJson()});
    onPublish?.call({
      ...report.value.toJson(),
      'log': List<Object?>.of(log),
    });
  }
}

/// Connects [probe] to the real binding: every pointer event, every drawn
/// frame and, when [startVsync] is given, every screen refresh. Returns a
/// function that disconnects it.
void Function() installInputCheckProbe(
  InputCheckProbe probe, {
  required GestureBinding gestures,
  required SchedulerBinding scheduler,
  void Function() Function(void Function() onVsync)? startVsync,
}) {
  gestures.pointerRouter.addGlobalRoute(probe.onPointer);
  // A persistent frame callback cannot be removed. The probe's own disposed
  // flag ends its effect.
  scheduler.addPersistentFrameCallback((_) => probe.onFrame());
  final stopVsync = startVsync?.call(probe.onVsync);
  return () {
    gestures.pointerRouter.removeGlobalRoute(probe.onPointer);
    stopVsync?.call();
  };
}
