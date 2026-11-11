import 'package:pantas/core/content/security/content_package_verifier.dart';

Future<void> ensureProtectedContentInstalled({
  required ContentPackageVerifier verifier,
}) async {
  // The native installer and its pinned encrypted package remain unchanged.
  throw UnimplementedError(
    'B3 content is stopped: the signed SQLCipher package requires a '
    'bootstrap secret that cannot be kept secret in a web bundle. '
    'No package or verification checks were changed.',
  );
}
