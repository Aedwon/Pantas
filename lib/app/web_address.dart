import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/web_address_stub.dart'
    if (dart.library.js_interop) 'package:pantas/app/web_address_web.dart'
    as browser;

/// The browser's history as this file needs it.
abstract interface class BrowserHistory {
  /// The number of the current entry, or null before the engine has numbered
  /// one.
  int? get serial;
  void go(int delta);
}

class _RealBrowserHistory implements BrowserHistory {
  const _RealBrowserHistory();
  @override
  int? get serial => browser.browserHistorySerial();
  @override
  void go(int delta) => browser.browserHistoryGo(delta);
}

/// Keeps the browser's history the same shape as the pages the student walked
/// through.
///
/// Flutter's router treats every address it reports as a new history entry, so
/// leaving a page added an entry too, and browser Back then reopened the page
/// the student had just closed. Here, when the page stack gets shorter and the
/// new address is an entry already behind this one, the browser steps back to
/// it instead.
///
/// That step comes back to the router as a new address. The router has already
/// done the pop, and an address cannot carry a page's in-memory arguments, so
/// that echo is not passed on. A real browser Back or Forward still is.
class WebAddressProvider extends ChangeNotifier
    implements RouteInformationProvider {
  WebAddressProvider(
    this._inner, {
    BrowserHistory history = const _RealBrowserHistory(),
    Duration echoWindow = const Duration(milliseconds: 300),
  })  : _history = history,
        _echoWindow = echoWindow {
    _inner.addListener(_onInner);
    _current = this;
  }

  static WebAddressProvider? _current;

  /// Makes the next address replace the current history entry instead of
  /// adding one. A page that closes itself by `pushReplacement` calls this
  /// first, so browser Back skips the page it replaced.
  static void replaceNextEntry() => _current?._replaceNext();

  bool _replacing = false;
  Timer? _replacingTimer;

  void _replaceNext() {
    _replacing = true;
    _replacingTimer?.cancel();
    _replacingTimer = Timer(_replaceWindow, () => _replacing = false);
  }

  static const _replaceWindow = Duration(milliseconds: 500);

  final RouteInformationProvider _inner;
  final BrowserHistory _history;
  final Duration _echoWindow;

  /// What each history entry holds, by the engine's number for it.
  final _entries = <int, ({String location, int depth})>{};
  String? _echo;
  Timer? _echoTimer;

  @override
  RouteInformation get value => _inner.value;

  static int _depth(RouteInformation information) {
    final state = information.state;
    if (state is! Map) return 0;
    final matches = state['imperativeMatches'];
    return matches is List ? matches.length : 0;
  }

  void _onInner() {
    final echo = _echo;
    _echo = null;
    _echoTimer?.cancel();
    if (echo != null && echo == _inner.value.uri.toString()) return;
    notifyListeners();
  }

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    final location = routeInformation.uri.toString();
    final depth = _depth(routeInformation);
    if (_replacing) {
      _replacing = false;
      _replacingTimer?.cancel();
      _inner.routerReportsNewRouteInformation(
        routeInformation,
        type: RouteInformationReportingType.neglect,
      );
      Timer.run(() {
        final now = _history.serial;
        if (now != null) _entries[now] = (location: location, depth: depth);
      });
      return;
    }
    final serial = _history.serial;
    final here = serial == null ? null : _entries[serial];
    if (serial != null && here != null && depth < here.depth) {
      for (var back = 1; _entries.containsKey(serial - back); back++) {
        final entry = _entries[serial - back]!;
        if (entry.location == location && entry.depth == depth) {
          _echo = location;
          _echoTimer?.cancel();
          _echoTimer = Timer(_echoWindow, () => _echo = null);
          _history.go(-back);
          return;
        }
      }
    }
    _inner.routerReportsNewRouteInformation(routeInformation, type: type);
    // The engine numbers the entry once it has handled the message.
    Timer.run(() {
      final now = _history.serial;
      if (now != null) _entries[now] = (location: location, depth: depth);
    });
  }

  @override
  void dispose() {
    if (identical(_current, this)) _current = null;
    _replacingTimer?.cancel();
    _echoTimer?.cancel();
    _inner.removeListener(_onInner);
    super.dispose();
  }
}

/// Points the current history entry at [location] without adding one, for a
/// page that changes what it shows in place (the reader moving to the next
/// lesson). A reload then lands on what the student sees.
void replaceWebAddress(BuildContext context, Uri location) {
  if (!kIsWeb) return;
  final router = GoRouter.maybeOf(context);
  unawaited(
    SystemNavigator.routeInformationUpdated(
      uri: location,
      state: router?.routeInformationProvider.value.state,
      replace: true,
    ),
  );
}

/// `context.pushReplacement`, and the browser's history entry for the page
/// being left is replaced too, so browser Back does not reopen it.
Future<T?> pushReplacementEntry<T extends Object?>(
  BuildContext context,
  String location,
) {
  WebAddressProvider.replaceNextEntry();
  return GoRouter.of(context).pushReplacement<T>(location);
}
