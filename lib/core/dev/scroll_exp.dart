import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

// LOCAL EXPERIMENT ONLY (E-098). Never merged. Switches read from `?exp=a,b`.
final Set<String> scrollExp = <String>{};

void readScrollExp() {
  final raw = Uri.base.queryParameters['exp'];
  if (raw != null) scrollExp.addAll(raw.split(','));
}

// Per-frame scroll position log for the trace: [frame ms, pixels] pairs in
// globalThis.__scrollLog. Only with ?exp=...log...
double? _lastPixels;

bool onScrollExpNotification(ScrollNotification n) {
  if (n.depth == 0 && n.metrics.axis == Axis.vertical)
    _lastPixels = n.metrics.pixels;
  return false;
}

void startScrollExp() {
  if (scrollExp.contains('resample')) {
    GestureBinding.instance.resamplingEnabled = true;
  }
  if (!scrollExp.contains('log')) return;
  final log = <JSAny>[].toJS;
  globalContext['__scrollLog'] = log;
  SchedulerBinding.instance.addPersistentFrameCallback((stamp) {
    final px = _lastPixels;
    if (px == null) return;
    log.callMethod('push'.toJS, [stamp.inMicroseconds / 1000, px].jsify());
  });
}
