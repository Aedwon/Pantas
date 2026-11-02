import 'package:flutter/foundation.dart';

String? _start;

/// Records the page address before routing rewrites it. Only the guardian
/// link is honored: it is the one address a person opens from an email, and
/// every other address keeps the normal start at Home.
void rememberStartLocation(Uri url, {bool isWeb = kIsWeb}) {
  _start = isWeb && url.path == '/guardian'
      ? (url.hasQuery ? '${url.path}?${url.query}' : url.path)
      : null;
}

@visibleForTesting
void forgetStartLocation() => _start = null;

/// Where the router starts.
String get initialRouterLocation => _start ?? '/home';
