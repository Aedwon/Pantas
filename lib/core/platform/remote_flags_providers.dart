import 'dart:async';

import 'package:pantas/core/platform/remote_flags.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The flags this launch fetched, or the fallback.
///
/// It defaults rather than throwing because the router reads it on every
/// route: a missing override would lock every student out of the app over
/// a wiring mistake, and the fallback blocks nobody. Bootstrap still
/// overrides it with what the server actually said.
final remoteFlagsProvider = Provider<RemoteFlags>(
  (ref) => RemoteFlags.fallback,
);

/// Prefetches Remote Config once at bootstrap with a short timeout.
///
/// Yields `RemoteFlags.fallback` if fetching throws or times out.
Future<RemoteFlags> fetchRemoteFlags({
  FirebaseRemoteConfig? remoteConfig,
  Duration timeout = const Duration(seconds: 3),
}) async {
  try {
    final config = remoteConfig ?? FirebaseRemoteConfig.instance;
    await config
        .setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: timeout,
            minimumFetchInterval: const Duration(hours: 1),
          ),
        )
        .timeout(timeout);

    await config.setDefaults(const {
      'minimum_supported_build': 0,
      'service_message': '',
    }).timeout(timeout);

    await config.fetchAndActivate().timeout(timeout);

    final minimum = config.getInt('minimum_supported_build');
    final message = config.getString('service_message');

    return RemoteFlags.parse(minimum, message);
  } catch (error, stackTrace) {
    debugPrint('Remote flags fetch failed or timed out: $error\n$stackTrace');
    return RemoteFlags.fallback;
  }
}

/// Helper to build ProviderContainer overrides for RemoteFlags.
Future<List<Override>> bootstrapRemoteFlagsOverrides({
  FirebaseRemoteConfig? remoteConfig,
}) async {
  final flags = await fetchRemoteFlags(remoteConfig: remoteConfig);
  return [remoteFlagsProvider.overrideWithValue(flags)];
}
