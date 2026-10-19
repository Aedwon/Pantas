import 'package:cloud_functions/cloud_functions.dart';
import 'package:meta/meta.dart';
import 'package:pantas/core/content/remote/content_item.dart';

/// The server limit on ids in one `getContent` call.
const maxContentIdsPerCall = 20;

@immutable
class RemoteEntry {
  const RemoteEntry.ok({required this.version, required this.data})
      : status = RemoteStatus.ok;
  const RemoteEntry.unchanged({required this.version})
      : status = RemoteStatus.unchanged,
        data = null;
  const RemoteEntry.missing()
      : status = RemoteStatus.missing,
        version = null,
        data = null;

  final RemoteStatus status;
  final String? version;
  final Map<String, Object?>? data;
}

enum RemoteStatus { ok, unchanged, missing }

@immutable
class ContentFetch {
  const ContentFetch({required this.tier, required this.entries});

  final String tier;
  final Map<String, RemoteEntry> entries;
}

// ignore: one_member_abstracts
abstract interface class ContentRemote {
  /// At most [maxContentIdsPerCall] ids.
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  );
}

class CallableContentRemote implements ContentRemote {
  CallableContentRemote({FirebaseFunctions? functions})
      : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  final FirebaseFunctions _functions;

  @override
  Future<ContentFetch> fetch(
    ContentKind kind,
    List<String> ids,
    Map<String, String> knownVersions,
  ) async {
    final result = await _functions.httpsCallable('getContent').call<Object?>({
      'kind': kind.wire,
      'ids': ids,
      'knownVersions': knownVersions,
    });
    return parseContentResponse(result.data);
  }
}

ContentFetch parseContentResponse(Object? raw) {
  final body = _map(raw);
  final items = _map(body['items']);
  return ContentFetch(
    tier: body['tier'] == 'pro' ? 'pro' : 'free',
    entries: {
      for (final entry in items.entries) entry.key: _entry(_map(entry.value)),
    },
  );
}

RemoteEntry _entry(Map<String, Object?> raw) {
  switch (raw['status']) {
    case 'ok':
      return RemoteEntry.ok(
        version: raw['version']! as String,
        data: _map(raw['data']),
      );
    case 'unchanged':
      return RemoteEntry.unchanged(version: raw['version']! as String);
    default:
      return const RemoteEntry.missing();
  }
}

/// Callable results arrive as `Map<Object?, Object?>`; convert deeply.
Map<String, Object?> _map(Object? value) {
  if (value is! Map) throw const FormatException('Expected an object.');
  return {
    for (final entry in value.entries) entry.key! as String: _deep(entry.value),
  };
}

Object? _deep(Object? value) {
  if (value is Map) return _map(value);
  if (value is List) return [for (final item in value) _deep(item)];
  return value;
}
