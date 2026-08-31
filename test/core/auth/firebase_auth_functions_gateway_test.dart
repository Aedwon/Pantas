import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/firebase_auth_functions_gateway.dart';

void main() {
  test(
    'uses exact callable names and asia-southeast1 with no request body',
    () async {
      final client = RecordingFunctionsClient(
        responses: {
          'recordSignInEvent': {'logged': true},
          'deleteAccount': {'deletedAt': '2026-08-28T00:00:00Z'},
        },
      );
      final gateway = FirebaseAuthFunctionsGateway(client: client);

      await gateway.recordSignInEvent();
      await gateway.deleteAccount();

      expect(client.calls, [
        const CallableInvocation(
          region: 'asia-southeast1',
          name: 'recordSignInEvent',
        ),
        const CallableInvocation(
          region: 'asia-southeast1',
          name: 'deleteAccount',
        ),
      ]);
    },
  );

  test('parses exportData download URL', () async {
    final client = RecordingFunctionsClient(
      responses: {
        'exportData': {'downloadUrl': 'https://example.com/export.json'},
      },
    );

    final uri = await FirebaseAuthFunctionsGateway(client: client).exportData();

    expect(uri, Uri.parse('https://example.com/export.json'));
    expect(client.calls.single.name, 'exportData');
    expect(client.calls.single.region, 'asia-southeast1');
  });

  test('rejects malformed export responses', () async {
    final client = RecordingFunctionsClient(
      responses: {
        'exportData': {'expiresAt': 'later'},
      },
    );

    await expectLater(
      FirebaseAuthFunctionsGateway(client: client).exportData(),
      throwsA(
        isA<AuthGatewayException>().having(
          (error) => error.code,
          'code',
          'malformed-export-response',
        ),
      ),
    );
  });

  test('translates structured callable reason before generic code', () async {
    final client = RecordingFunctionsClient(
      error: FirebaseFunctionsException(
        code: 'failed-precondition',
        message: 'Recent sign-in required',
        details: {'reason': 'requires-recent-login'},
      ),
    );

    await expectLater(
      FirebaseAuthFunctionsGateway(client: client).deleteAccount(),
      throwsA(
        isA<AuthGatewayException>().having(
          (error) => error.code,
          'code',
          'requires-recent-login',
        ),
      ),
    );
  });

  test(
    'falls back to callable error code when no semantic reason exists',
    () async {
      final client = RecordingFunctionsClient(
        error: FirebaseFunctionsException(
          code: 'unavailable',
          message: 'Unavailable',
        ),
      );

      await expectLater(
        FirebaseAuthFunctionsGateway(client: client).recordSignInEvent(),
        throwsA(
          isA<AuthGatewayException>().having(
            (error) => error.code,
            'code',
            'unavailable',
          ),
        ),
      );
    },
  );
}

class CallableInvocation {
  const CallableInvocation({required this.region, required this.name});

  final String region;
  final String name;

  @override
  bool operator ==(Object other) {
    return other is CallableInvocation &&
        other.region == region &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(region, name);
}

class RecordingFunctionsClient implements AuthFunctionsCallableClient {
  RecordingFunctionsClient({this.responses = const {}, this.error});

  final Map<String, Object?> responses;
  final Object? error;
  final calls = <CallableInvocation>[];

  @override
  Future<Object?> call({required String region, required String name}) async {
    calls.add(CallableInvocation(region: region, name: name));
    if (error case final value?) throw value;
    return responses[name];
  }
}
