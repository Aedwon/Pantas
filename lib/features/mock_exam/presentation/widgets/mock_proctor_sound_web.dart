import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('AudioContext')
external JSFunction get _audioContext;

/// The clock's three short tones. Unlock audio during a paper interaction,
/// because browsers can suspend audio created outside a user gesture.
class MockProctorSound {
  JSObject? _context;

  void prime() {
    try {
      final context = _context ??= _audioContext.callAsConstructor<JSObject>();
      context.callMethod<JSPromise<JSAny?>>('resume'.toJS).toDart.ignore();
    } on Object {
      // Audio can be blocked by the browser. The visible warning still works.
    }
  }

  void play() {
    final context = _context;
    if (context == null) return;
    try {
      final now =
          context.getProperty<JSNumber>('currentTime'.toJS).toDartDouble;
      final destination = context.getProperty<JSObject>('destination'.toJS);
      for (var i = 0; i < 3; i++) {
        final oscillator =
            context.callMethod<JSObject>('createOscillator'.toJS);
        final gain = context.callMethod<JSObject>('createGain'.toJS);
        oscillator
            .getProperty<JSObject>('frequency'.toJS)
            .setProperty('value'.toJS, 660.toJS);
        gain
            .getProperty<JSObject>('gain'.toJS)
            .setProperty('value'.toJS, .06.toJS);
        oscillator.callMethod<JSAny?>('connect'.toJS, gain);
        gain.callMethod<JSAny?>('connect'.toJS, destination);
        final start = now + i * .16;
        oscillator
          ..callMethod<JSAny?>('start'.toJS, start.toJS)
          ..callMethod<JSAny?>('stop'.toJS, (start + .08).toJS);
      }
    } on Object {
      // A muted or unavailable audio device must not interrupt the exam.
    }
  }

  void dispose() {
    final context = _context;
    _context = null;
    if (context == null) return;
    try {
      context.callMethod<JSPromise<JSAny?>>('close'.toJS).toDart.ignore();
    } on Object {
      // The browser may already have closed the context.
    }
  }
}
