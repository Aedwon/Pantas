import 'package:pantas/core/content/content_database.dart';

export 'package:pantas/core/content/content_seed_version.dart';

const contentDbFileName = 'content.db';

Future<ContentDatabase> openProtectedContentDatabase() async {
  // The native package requires a pinned bootstrap secret before rekeying.
  // Stop on web: never embed that secret or bypass package verification.
  throw UnimplementedError(
    'B3 content is stopped: the signed SQLCipher package requires a '
    'bootstrap secret that cannot be kept secret in a web bundle. '
    'No package or verification checks were changed.',
  );
}

@Deprecated('Use openProtectedContentDatabase after protected installation.')
Future<ContentDatabase> openContentDatabase() => openProtectedContentDatabase();
