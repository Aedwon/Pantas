import 'dart:io';

const _defaultInputPath = 'coverage/lcov.info';
const _defaultMinimum = 70.0;
const _generatedSuffixes = <String>[
  '.g.dart',
  '.freezed.dart',
  '.config.dart',
];

void main(List<String> args) {
  final options = _Options.parse(args);
  final input = File(options.inputPath);
  if (!input.existsSync()) {
    stderr.writeln('no coverage produced at ${options.inputPath}');
    exit(1);
  }

  final lcov = input.readAsStringSync();
  final filtered = filterGeneratedRecords(lcov);
  if (options.writeFilteredPath != null) {
    File(options.writeFilteredPath!).writeAsStringSync(filtered);
  }

  final report = coverageReportFor(lcov);
  if (report.totalLines == 0) {
    stderr.writeln('no DA lines in lcov after filtering generated files');
    exit(1);
  }

  stdout.writeln(
    'Coverage: ${report.percent.toStringAsFixed(1)}% '
    '(${report.coveredLines}/${report.totalLines} lines, generated filtered)',
  );
  if (report.percent < options.minimumPercent) {
    stderr.writeln(
      'coverage ${report.percent.toStringAsFixed(1)}% '
      '< ${options.minimumPercent.toStringAsFixed(1)}%',
    );
    exit(1);
  }
}

CoverageReport coverageReportFor(String lcov) {
  final filtered = filterGeneratedRecords(lcov);
  var covered = 0;
  var total = 0;

  for (final line in filtered.split('\n')) {
    if (!line.startsWith('DA:')) continue;
    final parts = line.split(',');
    if (parts.length < 2) continue;
    total++;
    final hits = int.tryParse(parts[1].trim()) ?? 0;
    if (hits != 0) covered++;
  }

  final percent = total == 0 ? 0.0 : (covered / total) * 100;
  return CoverageReport(
    coveredLines: covered,
    totalLines: total,
    percent: percent,
  );
}

String filterGeneratedRecords(String lcov) {
  final filtered = <String>[];
  final current = <String>[];

  for (final line in lcov.split('\n')) {
    if (line.isEmpty && current.isEmpty) continue;
    current.add(line);
    if (line == 'end_of_record') {
      if (!_isGeneratedRecord(current)) {
        filtered.addAll(current);
      }
      current.clear();
    }
  }

  if (current.isNotEmpty && !_isGeneratedRecord(current)) {
    filtered.addAll(current);
  }

  return filtered.isEmpty ? '' : '${filtered.join('\n')}\n';
}

bool _isGeneratedRecord(List<String> record) {
  final source = record.where((line) => line.startsWith('SF:')).firstOrNull;
  if (source == null) return false;
  final path = source.substring(3).replaceAll(r'\', '/');
  return _generatedSuffixes.any(path.endsWith);
}

class CoverageReport {
  const CoverageReport({
    required this.coveredLines,
    required this.totalLines,
    required this.percent,
  });

  final int coveredLines;
  final int totalLines;
  final double percent;
}

class _Options {
  const _Options({
    required this.inputPath,
    required this.minimumPercent,
    required this.writeFilteredPath,
  });

  factory _Options.parse(List<String> args) {
    var inputPath = _defaultInputPath;
    var minimumPercent = _defaultMinimum;
    String? writeFilteredPath;

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      switch (arg) {
        case '--input':
          inputPath = _valueFor(args, ++i, arg);
        case '--min':
          final raw = _valueFor(args, ++i, arg);
          minimumPercent = double.tryParse(raw) ?? _usage(arg);
        case '--write-filtered':
          writeFilteredPath = _valueFor(args, ++i, arg);
        case '--help':
        case '-h':
          stdout.writeln(
            'Usage: dart run tool/check_coverage.dart '
            '[--input coverage/lcov.info] [--min 70] '
            '[--write-filtered coverage/lcov.filtered.info]',
          );
          exit(0);
        default:
          _usage(arg);
      }
    }

    return _Options(
      inputPath: inputPath,
      minimumPercent: minimumPercent,
      writeFilteredPath: writeFilteredPath,
    );
  }

  final String inputPath;
  final double minimumPercent;
  final String? writeFilteredPath;

  static String _valueFor(List<String> args, int index, String flag) {
    if (index >= args.length) _usage(flag);
    return args[index];
  }

  static Never _usage(String flag) {
    stderr.writeln('invalid coverage option: $flag');
    exit(2);
  }
}
