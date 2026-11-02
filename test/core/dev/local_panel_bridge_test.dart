import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/dev/local_panel_bridge.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';

class _FakeChannel implements LocalPanelChannel {
  final StreamController<Map<String, Object?>> incoming =
      StreamController<Map<String, Object?>>.broadcast();
  final List<Map<String, Object?>> sent = [];
  int listened = 0;
  bool closed = false;

  @override
  Stream<Map<String, Object?>> get messages {
    listened++;
    return incoming.stream;
  }

  @override
  void send(Map<String, Object?> message) => sent.add(message);

  @override
  void close() => closed = true;

  Map<String, Object?> get lastStatus =>
      sent.lastWhere((message) => message['type'] == 'status');
}

class _FakePage implements LocalPanelPage {
  final Map<String, String> stored = {};
  final List<String> navigated = [];

  @override
  String? takeStored(String key) => stored.remove(key);

  @override
  void navigate(String url) => navigated.add(url);
}

GoRouter _router() => GoRouter(
      initialLocation: '/home',
      routes: [
        for (final path in const [
          '/home',
          '/plan',
          '/study',
          '/lesson/:lessonId',
          '/quiz/today/:examId',
          '/settings/about',
          '/quiz/mock/setup',
        ])
          GoRoute(path: path, builder: (_, __) => const SizedBox()),
      ],
    );

void main() {
  late _FakeChannel channel;
  late _FakePage page;
  late GoRouter router;
  late ProviderContainer container;
  late LocalPanelBridge bridge;

  setUp(() {
    channel = _FakeChannel();
    page = _FakePage();
    router = _router();
    container = ProviderContainer(
      overrides: [
        routerProvider.overrideWithValue(router),
        activeExamFocusProvider.overrideWith(
          (ref) async => const ActiveExamFocus.selected(
            Exam(
              id: 'exam_cse_pro',
              code: 'cse-pro',
              name: 'CSE Professional',
              shortName: 'CSE Pro',
              language: 'en',
              isActive: true,
              subjects: [],
            ),
          ),
        ),
      ],
    );
    bridge = LocalPanelBridge(
      container: container,
      channel: channel,
      page: page,
    );
  });

  /// A router needs a running app before it knows where it is.
  void routed(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await body(tester);
    });
  }

  tearDown(() {
    bridge.dispose();
    container.dispose();
    devProOverride.value = null;
    applyLocalPreset = null;
  });

  String where() {
    final shown = router.routerDelegate.currentConfiguration;
    return shown.lastOrNull?.matchedLocation ?? '';
  }

  /// A jump to a screen outside the tab shell waits 100 ms of fake time.
  Future<void> jump(WidgetTester tester, String path) async {
    final done = bridge.handle({'type': 'go', 'path': path});
    await tester.pump(const Duration(milliseconds: 150));
    await done;
    await tester.pumpAndSettle();
  }

  routed('a normal build never opens the channel', (tester) async {
    expect(localEmulators, isFalse);
    await startLocalPanelBridge(container, channel: channel, page: page);
    expect(channel.listened, 0);
    expect(channel.sent, isEmpty);
  });

  group('ping', () {
    routed('replies with the current route and plan', (tester) async {
      await handlePanelMessage(
        {'type': 'ping'},
        container,
        channel,
        page: page,
      );
      expect(channel.lastStatus, {
        'type': 'status',
        'route': '/home',
        'plan': 'real',
      });
    });

    routed('reports the plan the switch holds', (tester) async {
      devProOverride.value = true;
      await bridge.handle({'type': 'ping'});
      expect(channel.lastStatus['plan'], 'pro');
      devProOverride.value = false;
      await bridge.handle({'type': 'ping'});
      expect(channel.lastStatus['plan'], 'free');
    });

    routed('answers messages that arrive on the channel', (tester) async {
      bridge.start();
      channel.incoming.add({'type': 'ping'});
      await tester.pump();
      expect(channel.sent.single['type'], 'status');
    });
  });

  group('go', () {
    routed('goes to a tab screen without stacking it', (tester) async {
      await bridge.handle({'type': 'go', 'path': '/study'});
      expect(where(), '/study');
      expect(router.canPop(), isFalse);
    });

    routed('goes to a Home page inside the tab shell', (tester) async {
      await bridge.handle({'type': 'go', 'path': '/plan'});
      expect(where(), '/plan');
      expect(router.canPop(), isFalse);
    });

    routed('pushes a screen outside the tab shell on top of Home',
        (tester) async {
      await jump(tester, '/settings/about');
      expect(where(), '/settings/about');
      expect(router.canPop(), isTrue);
      router.pop();
      await tester.pumpAndSettle();
      expect(where(), '/home');
    });

    routed('two jumps in a row do not stack', (tester) async {
      await jump(tester, '/settings/about');
      await jump(tester, '/lesson/lesson-12');
      expect(where(), '/lesson/lesson-12');
      router.pop();
      await tester.pumpAndSettle();
      expect(where(), '/home');
    });

    routed('fills :examId with the active exam', (tester) async {
      await jump(tester, '/quiz/today/:examId');
      expect(where(), '/quiz/today/exam_cse_pro');
    });

    routed('opens Mock setup with the active exam as the examId query',
        (tester) async {
      await jump(tester, '/quiz/mock/setup');
      final top = router.routerDelegate.currentConfiguration.last;
      expect(top, isA<ImperativeRouteMatch>());
      final pushed = (top as ImperativeRouteMatch).matches.uri;
      expect(pushed.path, '/quiz/mock/setup');
      expect(pushed.queryParameters, {'examId': 'exam_cse_pro'});
    });

    routed('keeps an ID the panel already filled in', (tester) async {
      await jump(tester, '/lesson/lesson-12');
      expect(where(), '/lesson/lesson-12');
    });

    routed('ignores a path that is not an app path', (tester) async {
      for (final path in <Object?>[
        null,
        42,
        '',
        'home',
        'https://example.com/home',
        '//example.com/home',
        '/lesson/:lessonId',
      ]) {
        await bridge.handle({'type': 'go', 'path': path});
        expect(where(), '/home', reason: '$path');
      }
    });

    routed('does nothing when there is no active exam to fill in',
        (tester) async {
      final empty = ProviderContainer(
        overrides: [
          routerProvider.overrideWithValue(router),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
      );
      addTearDown(empty.dispose);
      await handlePanelMessage(
        {'type': 'go', 'path': '/quiz/today/:examId'},
        empty,
        channel,
        page: page,
      );
      expect(where(), '/home');
    });

    routed('sends the new route when the screen changes', (tester) async {
      bridge
        ..start()
        ..attachRouter();
      router.go('/study');
      await tester.pump();
      expect(channel.lastStatus['route'], '/study');
    });
  });

  group('plan', () {
    routed('sets the switch to Pro, Free and Real', (tester) async {
      await bridge.handle({'type': 'plan', 'value': 'pro'});
      expect(devProOverride.value, isTrue);
      await bridge.handle({'type': 'plan', 'value': 'free'});
      expect(devProOverride.value, isFalse);
      await bridge.handle({'type': 'plan', 'value': 'real'});
      expect(devProOverride.value, isNull);
    });

    routed('replies with the new plan', (tester) async {
      await bridge.handle({'type': 'plan', 'value': 'pro'});
      expect(channel.lastStatus['plan'], 'pro');
    });

    routed('ignores an unknown value', (tester) async {
      devProOverride.value = true;
      await bridge.handle({'type': 'plan', 'value': 'gold'});
      await bridge.handle({'type': 'plan'});
      expect(devProOverride.value, isTrue);
    });
  });

  group('fresh', () {
    routed('acknowledges, then opens the reset page', (tester) async {
      await bridge.handle({'type': 'fresh'});
      expect(channel.sent.single, {'type': 'ack'});
      expect(page.navigated, ['/local-reset.html']);
    });
  });

  routed('ignores unknown or malformed messages', (tester) async {
    for (final message in <Map<String, Object?>>[
      {'type': 'reload'},
      {'type': 'preset', 'id': 'welcome'},
      {'type': 'student', 'id': 'new'},
      {'type': 7},
      <String, Object?>{},
    ]) {
      await bridge.handle(message);
    }
    expect(channel.sent, isEmpty);
    expect(page.navigated, isEmpty);
    expect(where(), '/home');
  });

  group('stored preset', () {
    routed('is read, removed and handed to the hook', (tester) async {
      final applied = <String>[];
      applyLocalPreset = (given, id) async {
        expect(given, container);
        applied.add(id);
      };
      page.stored['pantas.local.preset'] = 'dateDay';

      await bridge.applyStoredPreset();

      expect(applied, ['dateDay']);
      expect(page.stored, isEmpty);
    });

    routed('is removed even when no hook is set', (tester) async {
      page.stored['pantas.local.preset'] = 'welcome';
      await bridge.applyStoredPreset();
      expect(page.stored, isEmpty);
    });

    routed('does nothing when no preset is stored', (tester) async {
      var called = false;
      applyLocalPreset = (_, __) async => called = true;
      await bridge.applyStoredPreset();
      expect(called, isFalse);
    });

    routed('a failing hook does not stop the app', (tester) async {
      applyLocalPreset = (_, __) async => throw StateError('bad preset');
      page.stored['pantas.local.preset'] = 'days';
      await bridge.applyStoredPreset();
      expect(page.stored, isEmpty);
    });
  });
}
