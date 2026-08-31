import 'package:google_sign_in/google_sign_in.dart';
import 'package:pantas/core/auth/auth_repository.dart';

abstract interface class GoogleSignInClient {
  Future<void> initialize();

  Future<GoogleSignInAccount> authenticate();

  Future<void> signOut();
}

class GoogleSignInSdkClient implements GoogleSignInClient {
  GoogleSignInSdkClient({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final GoogleSignIn _googleSignIn;

  @override
  Future<void> initialize() => _googleSignIn.initialize();

  @override
  Future<GoogleSignInAccount> authenticate() => _googleSignIn.authenticate();

  @override
  Future<void> signOut() => _googleSignIn.signOut();
}

class FirebaseGoogleSignInGateway implements GoogleSignInGateway {
  FirebaseGoogleSignInGateway({GoogleSignInClient? client})
      : _client = client ?? GoogleSignInSdkClient();

  final GoogleSignInClient _client;
  Future<void>? _initializeFuture;

  Future<void> _initialize() {
    return _initializeFuture ??= _client.initialize();
  }

  @override
  Future<GoogleAuthTokens?> signIn() async {
    await _initialize();
    try {
      final account = await _client.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthGatewayException('missing-google-id-token');
      }
      return GoogleAuthTokens(idToken: idToken);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw AuthGatewayException('google-sign-in-${error.code.name}');
    }
  }

  @override
  Future<void> signOut() async {
    await _initialize();
    try {
      await _client.signOut();
    } on GoogleSignInException catch (error) {
      throw AuthGatewayException('google-sign-in-${error.code.name}');
    }
  }
}
