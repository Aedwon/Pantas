import 'dart:math';

import 'package:cse_cet_reviewer/core/storage/domain/passage_set_filler.dart';
import 'package:cse_cet_reviewer/features/mock_exam/data/blueprint_section.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_sample.dart';

class MockSamplingException implements Exception {
  const MockSamplingException(this.message);

  final String message;

  @override
  String toString() => 'MockSamplingException: $message';
}

class MockSampler {
  MockSample sample({
    required List<BlueprintSection> sections,
    required Map<String, List<String>> poolsByTopic,
    required Set<String> recentlySampledQuestionIds,
    required int seed,
    Map<String, Map<String, List<String>>>? passageSetsByTopic,
  }) {
    final random = Random(seed);
    final sampledSections = <SampledMockSection>[];
    var expectedTotal = 0;

    for (final section in sections) {
      expectedTotal += section.questionCount;
      final allocations = _allocate(section);
      final questionIds = <String>[];

      for (final entry in allocations.entries) {
        final topicPool = poolsByTopic[entry.key] ?? const <String>[];
        if (topicPool.isEmpty) continue;

        final filtered = topicPool
            .where((id) => !recentlySampledQuestionIds.contains(id))
            .toList(growable: false);
        final candidatePool = filtered.length >= entry.value
            ? filtered
            : topicPool.toList(growable: false);
        final shuffled = candidatePool.toList()..shuffle(random);

        final topicPassageSets = passageSetsByTopic?[entry.key];
        if (topicPassageSets != null && topicPassageSets.isNotEmpty) {
          final freeStanding = <String>[];
          final setsByPassageId = <String, List<String>>{};
          for (final qid in shuffled) {
            final pid = topicPassageSets.entries
                .firstWhere(
                  (e) => e.value.contains(qid),
                  orElse: () => const MapEntry('', <String>[]),
                )
                .key;
            if (pid.isNotEmpty) {
              setsByPassageId.putIfAbsent(pid, () => []).add(qid);
            } else {
              freeStanding.add(qid);
            }
          }
          final filled = PassageSetFiller.fillGeneric(
            size: entry.value,
            freeStanding: freeStanding,
            setsByPassageId: setsByPassageId,
          );
          questionIds.addAll(filled);
        } else {
          questionIds.addAll(shuffled.take(entry.value));
        }
      }

      if (questionIds.isEmpty) {
        throw MockSamplingException(
          'Section ${section.id} has no available questions',
        );
      }

      questionIds.shuffle(random);
      sampledSections.add(
        SampledMockSection(
          sectionId: section.id,
          name: section.name,
          questionIds: List.unmodifiable(questionIds),
        ),
      );
    }

    return MockSample(
      sections: List.unmodifiable(sampledSections),
      expectedQuestionCount: expectedTotal,
    );
  }

  Map<String, int> _allocate(BlueprintSection section) {
    final totalWeight = section.topicIds.fold<double>(
      0,
      (sum, topicId) => sum + (section.topicWeights[topicId] ?? 1),
    );
    final allocationRows = [
      for (final topicId in section.topicIds)
        _AllocationRow(
          topicId: topicId,
          exact: section.questionCount *
              ((section.topicWeights[topicId] ?? 1) / totalWeight),
        ),
    ];

    final allocations = <String, int>{
      for (final row in allocationRows) row.topicId: row.floor,
    };
    var remaining = section.questionCount -
        allocations.values.fold<int>(0, (sum, value) => sum + value);
    final byRemainder = allocationRows.toList()
      ..sort((a, b) {
        final compare = b.remainder.compareTo(a.remainder);
        return compare == 0 ? a.topicId.compareTo(b.topicId) : compare;
      });

    for (final row in byRemainder) {
      if (remaining == 0) break;
      allocations[row.topicId] = allocations[row.topicId]! + 1;
      remaining -= 1;
    }
    return allocations;
  }
}

class _AllocationRow {
  const _AllocationRow({
    required this.topicId,
    required this.exact,
  });

  final String topicId;
  final double exact;

  int get floor => exact.floor();
  double get remainder => exact - floor;
}
