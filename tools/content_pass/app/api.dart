import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Talks to the local Content Pass server that served this page.
class ContentPassApi {
  ContentPassApi()
      : _dio = Dio(
          BaseOptions(
            baseUrl: Uri.base.origin,
            validateStatus: (code) => code != null && code < 500,
          ),
        );

  final Dio _dio;

  Future<Map<String, Object?>> _map(Future<Response<Object?>> call) async {
    final response = await call;
    return Map<String, Object?>.from(response.data! as Map);
  }

  Future<Map<String, Object?>> state() => _map(_dio.get('/api/state'));

  Future<Map<String, Object?>> manifest() => _map(_dio.get('/api/manifest'));

  Future<Map<String, Object?>> refresh() => _map(_dio.post('/api/refresh'));

  Future<Map<String, Object?>> figure(String id) =>
      _map(_dio.get('/api/figure', queryParameters: {'id': id}));

  Future<void> saveNote(Map<String, Object?> record) =>
      _dio.post<Object?>('/api/note', data: record);

  Future<void> savePosition(Map<String, Object?> position) =>
      _dio.post<Object?>('/api/position', data: position);

  Future<Uint8List> contentDb() async {
    final response = await _dio.get<List<int>>(
      '/snapshot/content.db',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }
}
