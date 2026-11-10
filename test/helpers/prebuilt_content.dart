import 'dart:io';

/// CI builds the content export and the seed database once per job, in the
/// setup step, and sets these two variables to their paths. Tests that need
/// the built corpus copy those files instead of running the export tools
/// again, which costs 7 to 12 seconds a file. When a variable is unset, or
/// names a file that is not there, the caller builds the file itself.
const _exportVariable = 'PANTAS_CONTENT_EXPORT';
const _seedVariable = 'PANTAS_CONTENT_SEED';

/// Copies the prebuilt export to [target]. Returns false when there is none.
bool copyPrebuiltExport(File target) => _copy(_exportVariable, target);

/// Copies the prebuilt seed database to [target]. Returns false when there is
/// none. The seed is built from the same export, by the same tool, as the one
/// the tests would build themselves.
bool copyPrebuiltSeed(File target) => _copy(_seedVariable, target);

bool _copy(String variable, File target) {
  final path = Platform.environment[variable];
  if (path == null || path.isEmpty) return false;
  final source = File(path);
  if (!source.existsSync()) return false;
  source.copySync(target.path);
  return true;
}
