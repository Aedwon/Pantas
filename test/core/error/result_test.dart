import 'package:cse_cet_reviewer/core/error/error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok holds value and reports isOk', () {
      const r = Ok<int, AppException>(42);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      expect(r.unwrap(), 42);
    });

    test('Err holds AppException and reports isErr', () {
      final ex = NetworkException(code: 'net/timeout');
      final r = Err<int, AppException>(ex);
      expect(r.isOk, isFalse);
      expect(r.isErr, isTrue);
      expect(r.unwrapErr(), ex);
    });

    test('unwrap on Err throws', () {
      final r = Err<int, AppException>(NetworkException(code: 'x'));
      expect(r.unwrap, throwsStateError);
    });

    test('unwrapErr on Ok throws', () {
      const r = Ok<int, AppException>(1);
      expect(r.unwrapErr, throwsStateError);
    });

    test('map transforms Ok values, leaves Err unchanged', () {
      const ok = Ok<int, AppException>(2);
      final mapped = ok.map((v) => v * 10);
      expect(mapped.unwrap(), 20);

      final err = Err<int, AppException>(NetworkException(code: 'x'));
      final mappedErr = err.map((v) => v * 10);
      expect(mappedErr.isErr, isTrue);
    });
  });

  group('AppException subclasses', () {
    test('NetworkException carries code and optional technical', () {
      final ex = NetworkException(
        code: 'net/timeout',
        technical: 'DioException at line 42',
      );
      expect(ex.code, 'net/timeout');
      expect(ex.technical, 'DioException at line 42');
      expect(ex, isA<AppException>());
    });

    test('exhaustive switch compiles', () {
      final AppException ex = NetworkException(code: 'x');
      final label = switch (ex) {
        NetworkException() => 'network',
        AuthException() => 'auth',
        EntitlementException() => 'entitlement',
        SyncException() => 'sync',
        StorageException() => 'storage',
        ContentException() => 'content',
        ValidationException() => 'validation',
        IntegrityException() => 'integrity',
      };
      expect(label, 'network');
    });
  });
}
