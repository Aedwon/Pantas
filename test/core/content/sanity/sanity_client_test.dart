import 'dart:convert';
import 'dart:typed_data';

import 'package:cse_cet_reviewer/core/content/sanity/sanity_client.dart';
import 'package:cse_cet_reviewer/core/content/sanity/sanity_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SanityConfig.fromEnvironment returns null when missing values', () {
    expect(
      SanityConfig.fromValues(projectId: '', dataset: 'production'),
      isNull,
    );
    expect(SanityConfig.fromValues(projectId: 'abc', dataset: ''), isNull);
  });

  test('SanityClient encodes query and params for apicdn endpoint', () async {
    final adapter = RecordingAdapter(
      body: jsonEncode({
        'ms': 10,
        'result': [
          {'_id': 'exam_cse'},
        ],
      }),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final client = SanityClient(
      dio,
      config: const SanityConfig(projectId: 'abc123', dataset: 'production'),
    );

    final response = await client.query<String>(
      r'*[_type == "exam" && _updatedAt > $since]',
      doctype: 'exam',
      parse: (doc) => doc['_id']! as String,
      params: {'since': '2026-05-17T00:00:00Z'},
    );

    expect(response, isA<SanityOk<String>>());
    expect((response as SanityOk<String>).docs, equals(['exam_cse']));
    expect(adapter.lastUri.host, equals('abc123.apicdn.sanity.io'));
    expect(adapter.lastUri.path, equals('/v2024-01-01/data/query/production'));
    expect(adapter.lastUri.queryParameters['query'], contains('_type'));
    expect(
      adapter.lastUri.queryParameters[r'$since'],
      equals('2026-05-17T00:00:00Z'),
    );
  });

  test('SanityClient returns networkError for Dio failures', () async {
    final dio = Dio()..httpClientAdapter = ThrowingAdapter();
    final client = SanityClient(
      dio,
      config: const SanityConfig(projectId: 'abc123', dataset: 'production'),
    );

    final response = await client.query<String>(
      '*[]',
      doctype: 'exam',
      parse: (_) => 'unused',
    );

    expect(response, isA<SanityNetworkError<String>>());
  });

  test('SanityClient returns parseError when parser throws', () async {
    final adapter = RecordingAdapter(
      body: jsonEncode({
        'result': [
          {'_id': 'bad'},
        ],
      }),
    );
    final dio = Dio()..httpClientAdapter = adapter;
    final client = SanityClient(
      dio,
      config: const SanityConfig(projectId: 'abc123', dataset: 'production'),
    );

    final response = await client.query<String>(
      '*[]',
      doctype: 'exam',
      parse: (_) => throw StateError('bad doc'),
    );

    expect(response, isA<SanityParseError<String>>());
  });
}

class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter({required this.body});

  final String body;
  late Uri lastUri;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastUri = options.uri;
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException(requestOptions: options);
  }

  @override
  void close({bool force = false}) {}
}
