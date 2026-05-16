import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_coverage.dart' as coverage;

void main() {
  test('filters generated source files before calculating coverage', () {
    const lcov = '''
SF:lib/core/storage/data/app_database.g.dart
DA:1,0
DA:2,0
end_of_record
SF:lib/features/assessment/domain/use_cases/complete_assessment.dart
DA:10,1
DA:11,1
DA:12,0
end_of_record
''';

    final report = coverage.coverageReportFor(lcov);

    expect(report.coveredLines, equals(2));
    expect(report.totalLines, equals(3));
    expect(report.percent, closeTo(66.67, 0.01));
  });

  test('filters freezed and config generated files', () {
    const lcov = '''
SF:lib/features/foo/foo.freezed.dart
DA:1,0
end_of_record
SF:lib/firebase_options.config.dart
DA:1,0
end_of_record
SF:lib/main.dart
DA:1,1
end_of_record
''';

    final report = coverage.coverageReportFor(lcov);

    expect(report.coveredLines, equals(1));
    expect(report.totalLines, equals(1));
    expect(report.percent, equals(100));
  });

  test('supports lcov DA lines with optional checksums', () {
    const lcov = '''
SF:lib/main.dart
DA:1,1,checksum
DA:2,0,checksum
end_of_record
''';

    final report = coverage.coverageReportFor(lcov);

    expect(report.coveredLines, equals(1));
    expect(report.totalLines, equals(2));
    expect(report.percent, equals(50));
  });

  test('retains non-generated lcov records when filtering', () {
    const lcov = '''
SF:lib/generated_name_but_real.dart
DA:1,1
end_of_record
SF:lib/core/storage/data/app_database.g.dart
DA:1,0
end_of_record
''';

    final filtered = coverage.filterGeneratedRecords(lcov);

    expect(filtered, contains('SF:lib/generated_name_but_real.dart'));
    expect(
      filtered,
      isNot(contains('SF:lib/core/storage/data/app_database.g.dart')),
    );
  });
}
