import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/ci/shard_tests.dart' as shards;

void main() {
  final files = <String>[
    for (var i = 0; i < 30; i++)
      'test/f${i.toString().padLeft(2, '0')}_test.dart',
  ];
  final timings = <String, double>{
    for (var i = 0; i < 20; i++) files[i]: (i + 1).toDouble(),
  };

  group('assignShards', () {
    test('gives the same answer every time', () {
      final first = shards.assignShards(files, timings, 4);
      final second = shards.assignShards(files.reversed.toList(), timings, 4);
      expect(second, equals(first));
    });

    test('partitions the files exactly', () {
      final split = shards.assignShards(files, timings, 4);
      expect(shards.checkPartition(files, split), isEmpty);
      expect(split.expand((s) => s).toList()..sort(), equals(files));
    });

    test('gives a file with no recorded time the median', () {
      // Known times 10, 2 and 6 have the median 6, so u counts as 6. With
      // that, the split is x+y against u+z. Counted as 0, u would leave x
      // alone in its shard.
      final split = shards.assignShards(
        <String>['x', 'y', 'z', 'u'],
        <String, double>{'x': 10, 'y': 2, 'z': 6},
        2,
      );
      expect(split[0], <String>['x', 'y']);
      expect(split[1], <String>['u', 'z']);
    });

    test('balances load, longest file first', () {
      final split = shards.assignShards(
        <String>['a', 'b', 'c', 'd'],
        <String, double>{'a': 10, 'b': 6, 'c': 5, 'd': 5},
        2,
      );
      expect(split[0], <String>['a', 'd']);
      expect(split[1], <String>['b', 'c']);
    });
  });

  group('checkPartition', () {
    test('reports an empty shard, a duplicate and a missing file', () {
      final problems = shards.checkPartition(
        <String>['a', 'b', 'c'],
        <List<String>>[
          <String>['a'],
          <String>['a', 'b'],
          <String>[],
        ],
      );
      expect(problems, <String>[
        'a is in shard 0 and shard 1',
        'c is in no shard',
        'shard 2 is empty',
      ]);
    });
  });

  group('listTestFiles', () {
    test('lists test files and leaves goldens out', () {
      final root = Directory.systemTemp.createTempSync('shard_tests_');
      addTearDown(() => root.deleteSync(recursive: true));
      for (final path in <String>[
        'test/a_test.dart',
        'test/sub/b_test.dart',
        'test/sub/helper.dart',
        'test/goldens/c_test.dart',
      ]) {
        File('${root.path}/$path')
          ..createSync(recursive: true)
          ..writeAsStringSync('');
      }
      expect(
        shards.listTestFiles(root),
        <String>['test/a_test.dart', 'test/sub/b_test.dart'],
      );
    });
  });
}
