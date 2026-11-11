import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:pantas/core/dev/local_panel_types.dart';
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

const _channelName = 'pantas-local-panel';

/// The panel's channel, over the browser's `BroadcastChannel`.
LocalPanelChannel? openLocalPanelChannel() => _WebPanelChannel();

/// The browser page.
LocalPanelPage? localPanelPage() => const _WebPanelPage();

class _WebPanelChannel implements LocalPanelChannel {
  _WebPanelChannel() : _channel = web.BroadcastChannel(_channelName) {
    _channel.onmessage = ((web.MessageEvent event) {
      final data = event.data;
      if (data == null || !data.isA<JSString>()) return;
      try {
        final decoded = jsonDecode((data as JSString).toDart);
        if (decoded is Map<String, dynamic>) _messages.add(decoded);
      } on FormatException catch (error) {
        debugPrint('Local panel sent text that is not JSON: $error');
      }
    }).toJS;
  }

  final web.BroadcastChannel _channel;
  final StreamController<Map<String, Object?>> _messages =
      StreamController<Map<String, Object?>>.broadcast();

  @override
  Stream<Map<String, Object?>> get messages => _messages.stream;

  @override
  void send(Map<String, Object?> message) =>
      _channel.postMessage(jsonEncode(message).toJS);

  @override
  void close() {
    _channel.close();
    unawaited(_messages.close());
  }
}

class _WebPanelPage implements LocalPanelPage {
  const _WebPanelPage();

  @override
  String? takeStored(String key) {
    try {
      final value = web.window.localStorage.getItem(key);
      web.window.localStorage.removeItem(key);
      return value;
    } on Object catch (error) {
      debugPrint('Local panel could not read $key: $error');
      return null;
    }
  }

  @override
  void navigate(String url) => web.window.location.assign(url);
}
