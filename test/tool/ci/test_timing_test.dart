import 'package:flutter_test/flutter_test.dart';

import '../../../tool/ci/test_timing.dart' as timing;

// A cut-down JSON reporter log: two suites, one skipped test, one failure,
// one hidden setUpAll, and a line that is not JSON.
const _log = r'''
{"protocolVersion":"0.1.1","runnerVersion":"1.26.0","type":"start","time":0}
{"suite":{"id":0,"platform":"vm","path":"/work/repo/test/a_test.dart"},"type":"suite","time":0}
{"test":{"id":1,"name":"loading /work/repo/test/a_test.dart","suiteID":0,"groupIDs":[],"metadata":{"skip":false,"skipReason":null},"line":null,"column":null,"url":null},"type":"testStart","time":10}
{"suite":{"id":2,"platform":"vm","path":"/work/repo/test/b_test.dart"},"type":"suite","time":12}
{"test":{"id":3,"name":"loading /work/repo/test/b_test.dart","suiteID":2,"groupIDs":[],"metadata":{"skip":false,"skipReason":null},"line":null,"column":null,"url":null},"type":"testStart","time":12}
{"testID":1,"result":"success","skipped":false,"hidden":true,"type":"testDone","time":1010}
not json at all
{"test":{"id":4,"name":"(setUpAll)","suiteID":0,"groupIDs":[],"metadata":{"skip":false,"skipReason":null},"line":null,"column":null,"url":null},"type":"testStart","time":1011}
{"testID":4,"result":"success","skipped":false,"hidden":true,"type":"testDone","time":1111}
{"test":{"id":5,"name":"group adds","suiteID":0,"groupIDs":[],"metadata":{"skip":false,"skipReason":null},"line":3,"column":3,"url":null},"type":"testStart","time":1112}
{"testID":5,"result":"success","skipped":false,"hidden":false,"type":"testDone","time":1612}
{"test":{"id":6,"name":"group later","suiteID":0,"groupIDs":[],"metadata":{"skip":true,"skipReason":"x"},"line":9,"column":3,"url":null},"type":"testStart","time":1613}
{"testID":6,"result":"success","skipped":true,"hidden":false,"type":"testDone","time":1613}
{"testID":3,"result":"success","skipped":false,"hidden":true,"type":"testDone","time":412}
{"test":{"id":7,"name":"tab\there","suiteID":2,"groupIDs":[],"metadata":{"skip":false,"skipReason":null},"line":3,"column":3,"url":null},"type":"testStart","time":420}
{"testID":7,"result":"failure","skipped":false,"hidden":false,"type":"testDone","time":520}
{"success":false,"type":"done","time":2000}
''';

void main() {
  final report = timing.analyzeReporterLines(
    _log.split('\n'),
    root: '/work/repo',
  );

  test('splits load time from run time per file', () {
    final a = report.files['test/a_test.dart']!;
    expect(a.loadMs, 1000);
    // setUpAll (100) plus two tests (500 and 0).
    expect(a.runMs, 600);
    final b = report.files['test/b_test.dart']!;
    expect(b.loadMs, 400);
    expect(b.runMs, 100);
  });

  test('lists identities with outcome and skip, hidden entries left out', () {
    expect(report.testCount, 3);
    expect(report.toIdentityText(), '''
test/a_test.dart\tgroup adds\tsuccess\tran
test/a_test.dart\tgroup later\tsuccess\tskipped
test/b_test.dart\ttab\\there\tfailure\tran
''');
  });

  test('ranks the slowest files first', () {
    expect(report.slowest(1).single.path, 'test/a_test.dart');
  });

  test('writes the timing json the sharder reads', () {
    final files = report.toTimingJson()['files']! as Map<String, Object?>;
    expect(files['test/b_test.dart'], <String, int>{
      'load_ms': 400,
      'run_ms': 100,
      'total_ms': 500,
    });
  });

  test('keeps a path outside the root as it is', () {
    final other = timing.analyzeReporterLines(
      _log.split('\n'),
      root: '/elsewhere',
    );
    expect(other.files.keys, contains('/work/repo/test/a_test.dart'));
  });
}
