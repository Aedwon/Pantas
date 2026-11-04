import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/web_address.dart';

class _FakeHistory implements BrowserHistory {
  @override
  int? serial = 0;
  final moves = <int>[];
  @override
  void go(int delta) {
    moves.add(delta);
    serial = serial! + delta;
  }
}

class _FakeInner extends ChangeNotifier implements RouteInformationProvider {
  _FakeInner(this.history);
  final _FakeHistory history;
  final reported = <String>[];
  final types = <RouteInformationReportingType>[];
  @override
  RouteInformation value = RouteInformation(uri: Uri.parse('/'));

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    reported.add(routeInformation.uri.toString());
    types.add(type);
    history.serial = reported.length - 1;
    value = routeInformation;
  }

  void platformSays(String location) {
    value = RouteInformation(uri: Uri.parse(location));
    notifyListeners();
  }
}

RouteInformation _at(String location, int depth) => RouteInformation(
      uri: Uri.parse(location),
      state: <Object?, Object?>{
        'location': '/study',
        'imperativeMatches': List<Object?>.filled(depth, <Object?, Object?>{}),
      },
    );

void main() {
  late _FakeHistory history;
  late _FakeInner inner;
  late WebAddressProvider provider;
  late int notified;

  void report(FakeAsync async, String location, int depth) {
    provider.routerReportsNewRouteInformation(_at(location, depth));
    async.elapse(Duration.zero);
  }

  void start() {
    history = _FakeHistory();
    inner = _FakeInner(history);
    provider = WebAddressProvider(inner, history: history);
    notified = 0;
    provider.addListener(() => notified++);
  }

  test('closing a page steps back instead of adding an entry', () {
    fakeAsync((async) {
      start();
      report(async, '/study', 0);
      report(async, '/lesson/a', 1);
      report(async, '/study', 0);
      expect(inner.reported, ['/study', '/lesson/a']);
      expect(history.moves, [-1]);
    });
  });

  test('the step back does not come back to the router', () {
    fakeAsync((async) {
      start();
      report(async, '/study', 0);
      report(async, '/lesson/a', 1);
      report(async, '/study', 0);
      inner.platformSays('/study');
      expect(notified, 0);
    });
  });

  test('a real browser Back still reaches the router', () {
    fakeAsync((async) {
      start();
      report(async, '/study', 0);
      report(async, '/lesson/a', 1);
      history.serial = 0;
      inner.platformSays('/study');
      expect(notified, 1);
    });
  });

  test('a stale echo does not swallow a later address', () {
    fakeAsync((async) {
      start();
      report(async, '/study', 0);
      report(async, '/lesson/a', 1);
      report(async, '/study', 0);
      async.elapse(const Duration(seconds: 1));
      inner.platformSays('/study');
      expect(notified, 1);
    });
  });

  test('closing two pages at once steps back two', () {
    fakeAsync((async) {
      start();
      report(async, '/home', 0);
      report(async, '/plan', 1);
      report(async, '/plan/week/1', 2);
      report(async, '/home', 0);
      expect(history.moves, [-2]);
    });
  });

  test('switching tabs back to one seen earlier is a new entry', () {
    fakeAsync((async) {
      start();
      report(async, '/home', 0);
      report(async, '/study', 0);
      report(async, '/home', 0);
      expect(inner.reported, ['/home', '/study', '/home']);
      expect(history.moves, isEmpty);
    });
  });

  test('leaving to an address not behind us is a new entry', () {
    fakeAsync((async) {
      start();
      report(async, '/lesson/a', 1);
      report(async, '/study', 0);
      expect(inner.reported, ['/lesson/a', '/study']);
      expect(history.moves, isEmpty);
    });
  });

  test('a page that replaces itself replaces its entry too', () {
    fakeAsync((async) {
      start();
      report(async, '/quiz/viewer/a', 0);
      WebAddressProvider.replaceNextEntry();
      report(async, '/quiz/all/a', 0);
      expect(inner.types, [
        RouteInformationReportingType.none,
        RouteInformationReportingType.neglect,
      ]);
    });
  });

  test('only the next address replaces; later ones add entries', () {
    fakeAsync((async) {
      start();
      report(async, '/quiz/viewer/a', 0);
      WebAddressProvider.replaceNextEntry();
      report(async, '/quiz/all/a', 0);
      report(async, '/quiz', 0);
      expect(inner.types.last, RouteInformationReportingType.none);
    });
  });

  test('a replace that never came is forgotten', () {
    fakeAsync((async) {
      start();
      report(async, '/quiz/viewer/a', 0);
      WebAddressProvider.replaceNextEntry();
      async.elapse(const Duration(seconds: 2));
      report(async, '/quiz/all/a', 0);
      expect(inner.types.last, RouteInformationReportingType.none);
    });
  });
}
