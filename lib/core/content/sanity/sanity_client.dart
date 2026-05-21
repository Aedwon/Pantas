import 'package:cse_cet_reviewer/core/content/sanity/sanity_config.dart';
import 'package:dio/dio.dart';

class SanityClient {
  SanityClient(this._dio, {required this.config});

  static const apiVersion = 'v2024-01-01';

  final Dio _dio;
  final SanityConfig config;

  Future<SanityResponse<T>> query<T>(
    String groq, {
    Map<String, Object?> params = const {},
    required String doctype,
    required T Function(Map<String, Object?> doc) parse,
  }) async {
    final uri = Uri.https(
      '${config.projectId}.apicdn.sanity.io',
      '/$apiVersion/data/query/${config.dataset}',
      {
        'query': groq,
        for (final entry in params.entries)
          r'$' '${entry.key}': '${entry.value}',
      },
    );
    try {
      final response = await _dio.getUri<Map<String, Object?>>(uri);
      final data = response.data;
      final result = data?['result'];
      if (result is! List) {
        return SanityParseError<T>(doctype, StateError('missing result list'));
      }
      final docs = <T>[];
      for (final doc in result) {
        if (doc is! Map<String, Object?>) {
          return SanityParseError<T>(
            doctype,
            StateError('result item is not an object'),
          );
        }
        docs.add(parse(doc));
      }
      return SanityOk<T>(docs: docs, serverTime: DateTime.now().toUtc());
    } on DioException catch (e) {
      return SanityNetworkError<T>(e);
    } catch (e) {
      return SanityParseError<T>(doctype, e);
    }
  }
}

sealed class SanityResponse<T> {
  const SanityResponse();
}

class SanityOk<T> extends SanityResponse<T> {
  const SanityOk({required this.docs, required this.serverTime});

  final List<T> docs;
  final DateTime serverTime;
}

class SanityNetworkError<T> extends SanityResponse<T> {
  const SanityNetworkError(this.error);

  final Object error;
}

class SanityParseError<T> extends SanityResponse<T> {
  const SanityParseError(this.doctype, this.error);

  final String doctype;
  final Object error;
}

class SanitySchemaVersionMismatch<T> extends SanityResponse<T> {
  const SanitySchemaVersionMismatch({
    required this.doctype,
    required this.got,
    required this.expected,
  });

  final String doctype;
  final int got;
  final int expected;
}
