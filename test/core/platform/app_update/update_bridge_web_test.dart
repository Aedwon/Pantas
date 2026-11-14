@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/app_update/update_bridge_web.dart';

@JS('pantasUpdate')
external set _update(JSObject? value);

extension type _Api._(JSObject _) implements JSObject {
  external factory _Api({required JSFunction check, required JSFunction apply});
}

extension type _Status._(JSObject _) implements JSObject {
  external factory _Status({required bool available, required String version});
}

void main() {
  tearDown(() => _update = null);

  test('web bridge reads version and invokes synchronous reload apply',
      () async {
    var reloads = 0;
    _update = _Api(
      check: (() => Future.value(
            _Status(available: true, version: 'new-build'),
          ).toJS).toJS,
      apply: (() {
        reloads++;
      }).toJS,
    );
    final bridge = createUpdateBridge();
    final status = await bridge.check();
    expect(status.available, isTrue);
    expect(status.version, 'new-build');
    await bridge.apply();
    expect(reloads, 1);
  });

  test('old pages without the bridge are a no-op', () async {
    _update = null;
    final bridge = createUpdateBridge();
    final status = await bridge.check();
    expect(status.available, isFalse);
    expect(status.version, isNull);
    await bridge.apply();
  });

  test('reload errors propagate so the coordinator can retry', () async {
    void failReload() => throw StateError('reload failed');
    _update = _Api(
      check: (() => Future.value(
            _Status(available: true, version: 'new-build'),
          ).toJS).toJS,
      apply: failReload.toJS,
    );
    await expectLater(createUpdateBridge().apply(), throwsA(anything));
  });
}
