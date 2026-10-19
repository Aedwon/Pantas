class SeedInstaller {
  SeedInstaller({this.assetPath = 'assets/seed/content.db'});

  final String assetPath;

  Future<bool> install({
    required String? installedVersion,
    required String bundledVersion,
  }) async {
    throw UnimplementedError(
      'B3 content is stopped: the signed SQLCipher package requires a '
      'bootstrap secret that cannot be kept secret in a web bundle. '
      'No package or verification checks were changed.',
    );
  }
}
