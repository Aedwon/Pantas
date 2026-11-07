import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/core/telemetry/perf_timeline_stub.dart'
    if (dart.library.js_interop) 'package:pantas/core/telemetry/perf_timeline_web.dart'
    as platform;

/// One timing in the speed report: a contract name and whole milliseconds.
@immutable
class PerfEntry {
  const PerfEntry(this.name, this.ms);

  final String name;
  final int ms;

  @override
  bool operator ==(Object other) =>
      other is PerfEntry && other.name == name && other.ms == ms;

  @override
  int get hashCode => Object.hash(name, ms);

  @override
  String toString() => '$name=$ms';
}

/// The startup and screen timings this page has seen, for the speed report
/// (`docs/superpowers/specs/2026-11-07-load-speed-and-telemetry-design.md`,
/// T1). It answers one question: where does the time go before a student can
/// use the app? It records names and times only, never who or what.
///
/// A mark is milliseconds since the page began loading. A measure is a
/// duration. On the web the page's own script marks (`page.*`, `splash.*`)
/// are read in too. Nothing here can throw or slow a screen.
abstract final class PerfTimeline {
  /// Every name the report accepts. The server refuses anything else.
  static const knownNames = <String>{
    'page.helpers',
    'page.worker',
    'page.loader',
    'boot.firebase',
    'boot.appcheck',
    'boot.storage',
    'boot.contentdb',
    'boot.flags',
    'boot.auth',
    'boot.content',
    'boot.consent',
    'boot.payments',
    'boot.sync',
    'boot.gates',
    'boot.runapp',
    'beta.resolved',
    'home.firstframe',
    'home.data',
    'splash.ready',
    'splash.removed',
    'screen.home',
    'screen.lesson',
    'screen.quizstart',
    'screen.quizend',
  };

  /// The most entries kept. A long session cannot grow this without limit.
  static const maxEntries = 100;

  /// The most the report accepts for one time: ten minutes.
  static const _maxMs = 600000;

  static final List<PerfEntry> _entries = [];
  static final Set<String> _marked = {};

  /// Milliseconds since the page began loading. Tests replace it.
  @visibleForTesting
  static int Function() nowMs = platform.nowMs;

  /// Records that [name] has been reached. Only the first time counts, so a
  /// screen that rebuilds does not move its own mark.
  static void mark(String name) {
    if (!_accept(name) || !_marked.add(name)) return;
    platform.browserMark(name);
    _add(PerfEntry(name, _clamp(nowMs())));
  }

  /// Records that [name] took [d]. Every call counts.
  static void measure(String name, Duration d) {
    if (!_accept(name)) return;
    _add(PerfEntry(name, _clamp(d.inMilliseconds)));
  }

  /// The page's own marks, then everything recorded here, oldest first.
  static List<PerfEntry> entries() => List.unmodifiable([
        for (final (name, ms) in platform.pageMarks())
          if (knownNames.contains(name) && !_marked.contains(name))
            PerfEntry(name, _clamp(ms)),
        ..._entries,
      ]);

  @visibleForTesting
  static void reset() {
    _entries.clear();
    _marked.clear();
    nowMs = platform.nowMs;
  }

  static bool _accept(String name) {
    assert(
      knownNames.contains(name),
      'Unknown timing name "$name". Add it to the report contract first.',
    );
    return knownNames.contains(name);
  }

  static void _add(PerfEntry entry) {
    if (_entries.length < maxEntries) _entries.add(entry);
  }

  static int _clamp(int ms) => ms.clamp(0, _maxMs);
}

/// Measures one screen from the moment it is created, which is when its route
/// is pushed, to the first frame drawn after its data is ready.
///
/// Hold one in the screen's `State`. Call [settled] from `build` next to the
/// screen's other "ready" signal. It records once.
class ScreenTimer {
  ScreenTimer(this.name) : _startMs = PerfTimeline.nowMs();

  /// A contract name such as `screen.lesson`.
  final String name;
  final int _startMs;
  bool _done = false;

  void settled({bool ready = true}) {
    if (_done || !ready) return;
    _done = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      PerfTimeline.measure(
        name,
        Duration(milliseconds: PerfTimeline.nowMs() - _startMs),
      );
    });
  }
}
