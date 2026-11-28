// Analytics may never stop or delay the work that logs it.
//
// Nov 22 2026, prod: SubmitAnswer awaited a question_answered event before
// saving the answer, and the property check threw on question ids longer than
// 64 characters, so answers to 261 questions were never saved ("Could not
// save your progress"). The gate now drops a bad property and never throws or
// waits. This check keeps app code from depending on that again: no `await`
// on an analytics event, and no throwing property check outside telemetry.
import 'check.dart';

// `await` followed, within one statement, by an analytics `.log(`: either on
// a receiver named like telemetry (`_telemetry?.log(`, `ref.read(
// telemetryProvider).log(`, `Future.wait([telemetry.log(...)])`) or with an
// event argument. Limit: a log future stored in a variable and awaited later,
// on a receiver not named like telemetry, is not seen; the gate's own tests
// (analytics_never_blocks_test.dart) still keep that from blocking.
final _awaitedLog = RegExp(
  r'\bawait\b[^;]*?(?:[Tt]elemetry[^;]*?\.log\(|\.log\(\s*(?:TelemetryEvent\.|event\b))',
);

final _throwingCheck = RegExp(r'\bassertPropertiesAllowed\(');

const _telemetryDir = 'lib/core/telemetry/';

class AnalyticsNeverBlocksCheck extends Check {
  const AnalyticsNeverBlocksCheck();

  @override
  String get name => 'analytics-never-blocks';

  @override
  String get origin =>
      'Nov 22 2026 prod: an awaited analytics event threw on long question '
      'ids before the answer was saved, so 261 questions could not be saved';

  @override
  List<Violation> run(String root) => [
        for (final entry in libSources(root).entries)
          ...findBlockingAnalytics(entry.key, entry.value),
      ];
}

List<Violation> findBlockingAnalytics(String path, String source) {
  // The telemetry seam itself forwards events between its own layers.
  if (path.startsWith(_telemetryDir)) return const [];
  final code = withoutLineComments(source);
  return [
    for (final match in _awaitedLog.allMatches(code))
      Violation(
        '$path:${lineAt(code, match.start)}',
        'awaits an analytics event. Log with unawaited(...), after the work '
            'is done, so analytics can never stop or delay it.',
      ),
    for (final match in _throwingCheck.allMatches(code))
      Violation(
        '$path:${lineAt(code, match.start)}',
        'calls the throwing property check in app code. Use '
            'allowedProperties, which drops a bad property instead.',
      ),
  ];
}
