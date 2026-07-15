/// This build's number, the one the force-update gate compares against.
///
/// Passed at build time with `--dart-define=BUILD_NUMBER=<n>`, matching the
/// `+n` in `pubspec.yaml`'s version. A package that reads it back from the
/// bundle would be a second dependency for one integer, and CI already
/// knows the number it is building.
const int kBuildNumber = int.fromEnvironment('BUILD_NUMBER', defaultValue: 1);
