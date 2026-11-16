import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/core/dev/input_check.dart';
import 'package:pantas/core/dev/input_check_probe.dart';

class _MemoryStore implements InputCheckStore {
  final values = <String, String>{};

  @override
  String? read(String key) => values[key];

  @override
  void write(String key, String? value) {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
  }
}

Uri _staging(String query) => Uri.parse('https://staging.pantas.study/$query');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(InputCheck.reset);

  group('staging hosts', () {
    test('only the two staging hosts count', () {
      expect(isInputCheckStagingHost('staging.pantas.study'), isTrue);
      expect(isInputCheckStagingHost('pantas-staging.web.app'), isTrue);
      expect(isInputCheckStagingHost('pantas-staging-app.web.app'), isTrue);
      expect(isInputCheckStagingHost('app.pantas.study'), isFalse);
      expect(isInputCheckStagingHost('127.0.0.1'), isFalse);
      expect(isInputCheckStagingHost('pantas-prod.web.app'), isFalse);
      expect(isInputCheckStagingHost('staging.pantas.study.evil.com'), isFalse);
    });
  });

  group('parsing and gating', () {
    test('perf=1 turns the overlay on and is stored', () {
      final store = _MemoryStore();
      final settings = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging('?perf=1'),
        store: store,
      );
      expect(settings.perf, isTrue);
      expect(settings.resample, isFalse);
      expect(store.values, {'pantas.perf': '1'});
    });

    test('a stored choice survives the address rewrite', () {
      final store = _MemoryStore();
      InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging('?perf=1&resample=on&resampleOffset=30'),
        store: store,
      );
      final later = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging(''),
        store: store,
      );
      expect(later.perf, isTrue);
      expect(later.resample, isTrue);
      expect(later.resampleOffsetMs, 30);
    });

    test('perf=0 and resample=off clear a stored choice', () {
      final store = _MemoryStore();
      InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging('?perf=1&resample=on'),
        store: store,
      );
      final cleared = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging('?perf=0&resample=off'),
        store: store,
      );
      expect(cleared.perf, isFalse);
      expect(cleared.resample, isFalse);
      expect(store.values, isEmpty);
    });

    test("no parameter keeps today's behavior", () {
      final settings = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging(''),
        store: _MemoryStore(),
      );
      expect(settings.perf, isFalse);
      expect(settings.resample, isFalse);
      expect(settings.active, isFalse);
    });

    test('unusable values are ignored', () {
      final settings = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging('?perf=yes&resample=maybe&resampleOffset=abc'),
        store: _MemoryStore(),
      );
      expect(settings.active, isFalse);
      expect(settings.resampleOffsetMs, 20);
    });

    test('a prod host ignores every parameter and stores nothing', () {
      final store = _MemoryStore();
      final settings = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: Uri.parse(
          'https://app.pantas.study/?perf=1&resample=on&resampleOffset=30',
        ),
        store: store,
      );
      expect(settings.active, isFalse);
      expect(store.values, isEmpty);
    });

    test('a stored choice is not read on a prod host', () {
      final store = _MemoryStore()..values['pantas.perf'] = '1';
      final settings = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: Uri.parse('https://app.pantas.study/'),
        store: store,
      );
      expect(settings.perf, isFalse);
    });

    test('the prod and dev flavors ignore every parameter', () {
      for (final flavor in [Flavor.prod, Flavor.dev]) {
        final store = _MemoryStore();
        final settings = InputCheckSettings.resolve(
          flavor: flavor,
          base: _staging('?perf=1&resample=on'),
          store: store,
        );
        expect(settings.active, isFalse, reason: '$flavor');
        expect(store.values, isEmpty, reason: '$flavor');
      }
    });
  });

  group('resampling settings', () {
    tearDown(() {
      binding
        ..resamplingEnabled = false
        ..samplingOffset = const Duration(milliseconds: -38);
    });

    test('resample=on enables it with an offset of minus 20 ms', () {
      final settings = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging('?resample=on'),
        store: _MemoryStore(),
      );
      applyResampling(binding, settings);
      expect(binding.resamplingEnabled, isTrue);
      expect(binding.samplingOffset, const Duration(milliseconds: -20));
    });

    test('resampleOffset sets the offset in milliseconds, minus', () {
      final settings = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging('?resample=on&resampleOffset=12.5'),
        store: _MemoryStore(),
      );
      applyResampling(binding, settings);
      expect(binding.samplingOffset, const Duration(microseconds: -12500));
    });

    test('resample=off leaves the binding alone', () {
      final settings = InputCheckSettings.resolve(
        flavor: Flavor.staging,
        base: _staging('?resample=off&resampleOffset=30'),
        store: _MemoryStore(),
      );
      applyResampling(binding, settings);
      expect(binding.resamplingEnabled, isFalse);
      expect(binding.samplingOffset, const Duration(milliseconds: -38));
    });
  });

  group('startInputCheck', () {
    test('installs nothing without perf=1', () {
      var installs = 0;
      final settings = startInputCheck(
        Flavor.staging,
        base: _staging(''),
        store: _MemoryStore(),
        binding: binding,
        install: (_) => installs++,
      );
      expect(settings.perf, isFalse);
      expect(installs, 0);
      expect(InputCheck.probe, isNull);
    });

    test('installs nothing on a prod host even with perf=1', () {
      var installs = 0;
      startInputCheck(
        Flavor.staging,
        base: Uri.parse('https://app.pantas.study/?perf=1&resample=on'),
        store: _MemoryStore(),
        binding: binding,
        install: (_) => installs++,
      );
      expect(installs, 0);
      expect(InputCheck.probe, isNull);
      expect(binding.resamplingEnabled, isFalse);
    });

    test('installs one probe with perf=1', () {
      final seen = <InputCheckProbe>[];
      startInputCheck(
        Flavor.staging,
        base: _staging('?perf=1'),
        store: _MemoryStore(),
        binding: binding,
        install: seen.add,
      );
      expect(seen, hasLength(1));
      expect(InputCheck.probe, same(seen.single));
    });

    test('resample=on alone adds no probe', () {
      var installs = 0;
      startInputCheck(
        Flavor.staging,
        base: _staging('?resample=on'),
        store: _MemoryStore(),
        binding: binding,
        install: (_) => installs++,
      );
      expect(installs, 0);
      expect(binding.resamplingEnabled, isTrue);
      binding
        ..resamplingEnabled = false
        ..samplingOffset = const Duration(milliseconds: -38);
    });
  });
}
