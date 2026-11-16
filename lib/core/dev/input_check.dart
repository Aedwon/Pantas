import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/core/dev/input_check_platform.dart';
import 'package:pantas/core/dev/input_check_probe.dart';

// Staging-only input diagnostics, for finding out why a drag looks like 60 fps
// on a 120 Hz phone. Two switches, read from the page address:
//
//   ?perf=1             show the numbers overlay and publish __pantasPerf
//   ?resample=on|off    turn Flutter's pointer resampling on or off
//   ?resampleOffset=<ms> how far back resampling looks, default 20
//
// Both need the staging flavor and a staging host. Anywhere else the
// parameters are ignored and nothing is stored, listened to or installed.

/// The staging hosts. Same rule as web/pantas_pixel_ratio.js.
bool isInputCheckStagingHost(String host) =>
    host == 'staging.pantas.study' ||
    RegExp(r'^pantas-staging[a-z0-9-]*\.web\.app$').hasMatch(host);

/// Where the choice is kept so it survives the address rewrite.
abstract interface class InputCheckStore {
  String? read(String key);

  /// A null [value] removes the key.
  void write(String key, String? value);
}

/// Keeps nothing.
class NoInputCheckStore implements InputCheckStore {
  const NoInputCheckStore();

  @override
  String? read(String key) => null;

  @override
  void write(String key, String? value) {}
}

class InputCheckSettings {
  const InputCheckSettings({
    this.perf = false,
    this.resample = false,
    this.resampleOffsetMs = defaultResampleOffsetMs,
  });

  /// Reads the switches from [base], keeping them in [store]. Returns the
  /// off settings, and touches nothing, unless this is the staging flavor on a
  /// staging host.
  factory InputCheckSettings.resolve({
    required Flavor flavor,
    required Uri base,
    required InputCheckStore store,
  }) {
    if (flavor != Flavor.staging || !isInputCheckStagingHost(base.host)) {
      return const InputCheckSettings();
    }
    final query = base.queryParameters;
    switch (query['perf']) {
      case '1':
        store.write(_perfKey, '1');
      case '0':
        store.write(_perfKey, null);
    }
    switch (query['resample']) {
      case 'on':
        store.write(_resampleKey, 'on');
      case 'off':
        store.write(_resampleKey, null);
    }
    final offset = _parseOffset(query['resampleOffset']);
    if (offset != null) store.write(_offsetKey, offset.toString());
    return InputCheckSettings(
      perf: store.read(_perfKey) == '1',
      resample: store.read(_resampleKey) == 'on',
      resampleOffsetMs:
          _parseOffset(store.read(_offsetKey)) ?? defaultResampleOffsetMs,
    );
  }

  /// Why 20: touch arrives in a batch about every 17 ms on a 120 Hz iPhone in
  /// Safari. Looking back just over one batch means every frame has a batch on
  /// each side of the sample time, so it can interpolate between two batches.
  /// Flutter's own default is 38 ms (`_defaultSamplingOffset` in
  /// gestures/binding.dart), sized for a 60 Hz sensor plus one frame of
  /// lead time, and it adds that much delay.
  static const defaultResampleOffsetMs = 20.0;

  /// Larger than this is a typo, not an offset.
  static const maxResampleOffsetMs = 100.0;

  static const _perfKey = 'pantas.perf';
  static const _resampleKey = 'pantas.resample';
  static const _offsetKey = 'pantas.resampleOffset';

  final bool perf;
  final bool resample;
  final double resampleOffsetMs;

  bool get active => perf || resample;

  /// The value for [GestureBinding.samplingOffset]: minus, as Flutter expects.
  Duration get samplingOffset =>
      Duration(microseconds: -(resampleOffsetMs * 1000).round());

  static double? _parseOffset(String? raw) {
    final value = raw == null ? null : double.tryParse(raw);
    if (value == null || !value.isFinite) return null;
    if (value < 0 || value > maxResampleOffsetMs) return null;
    return value;
  }
}

/// Turns pointer resampling on with the chosen offset. Does nothing when the
/// settings do not ask for it.
void applyResampling(GestureBinding binding, InputCheckSettings settings) {
  if (!settings.resample) return;
  binding
    ..resamplingEnabled = true
    ..samplingOffset = settings.samplingOffset;
}

/// The running probe, set only by [startInputCheck].
abstract final class InputCheck {
  static InputCheckProbe? probe;

  @visibleForTesting
  static void reset() => probe = null;
}

/// Reads the switches and installs what they ask for. Call first thing at
/// startup, before routing rewrites the address. Returns the settings.
InputCheckSettings startInputCheck(
  Flavor flavor, {
  Uri? base,
  InputCheckStore? store,
  GestureBinding? binding,
  void Function(InputCheckProbe probe)? install,
}) {
  final settings = InputCheckSettings.resolve(
    flavor: flavor,
    base: base ?? Uri.base,
    store: store ?? createInputCheckStore(),
  );
  if (!settings.active) return settings;
  applyResampling(binding ?? GestureBinding.instance, settings);
  if (settings.perf) {
    void publish(Map<String, Object?> data) => publishInputCheck({
          ...data,
          'resample': settings.resample,
          'resampleOffsetMs': settings.resampleOffsetMs,
        });
    final probe = InputCheckProbe(onPublish: publish);
    InputCheck.probe = probe;
    publish({...probe.report.value.toJson(), 'log': <Object?>[]});
    (install ?? _installForReal)(probe);
  }
  return settings;
}

void _installForReal(InputCheckProbe probe) => installInputCheckProbe(
      probe,
      gestures: GestureBinding.instance,
      scheduler: SchedulerBinding.instance,
      startVsync: startVsyncCounter,
    );
