@TestOn('browser')
library;

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/app_update/update_bridge_web.dart';
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

@JS('pantasUpdate')
external set _update(JSObject value);

extension type _Api._(JSObject _) implements JSObject {
  external factory _Api({required JSFunction check, required JSFunction apply});
}

extension type _Status._(JSObject _) implements JSObject {
  external factory _Status({required bool available, required String version});
}

void main() {
  test('web bridge reads version and holds input through activation', () async {
    final activation = Completer<JSAny?>();
    _update = _Api(
      check: (() => Future.value(
            _Status(available: true, version: 'new-build'),
          ).toJS).toJS,
      apply: (() => activation.future.toJS).toJS,
    );
    final bridge = createUpdateBridge();
    final status = await bridge.check();
    expect(status.available, isTrue);
    expect(status.version, 'new-build');
    final applying = bridge.apply();
    for (final type in ['click', 'keydown', 'touchend', 'compositionend']) {
      final event = web.Event(type, web.EventInit(cancelable: true));
      expect(web.window.dispatchEvent(event), isFalse, reason: type);
    }
    activation.complete();
    await applying;
    expect(
      web.window.dispatchEvent(
        web.Event('click', web.EventInit(cancelable: true)),
      ),
      isTrue,
    );
  });

  test('web bridge releases input when activation fails', () async {
    final activation = Completer<JSAny?>();
    _update = _Api(
      check: (() => Future.value(
            _Status(available: true, version: 'new-build'),
          ).toJS).toJS,
      apply: (() => activation.future.toJS).toJS,
    );
    final applying = createUpdateBridge().apply();
    activation.completeError(Exception('activation failed'));
    await expectLater(applying, throwsA(anything));
    expect(
      web.window.dispatchEvent(
        web.Event('keydown', web.EventInit(cancelable: true)),
      ),
      isTrue,
    );
  });
}
