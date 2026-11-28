import 'dart:math';

import 'package:pantas/core/storage/domain/passage_set_filler.dart';
import 'package:pantas/features/mock_exam/data/blueprint_section.dart';
import 'package:pantas/features/mock_exam/domain/mock_sample.dart';

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
        // The server uses exam-specific IDs. Local exam-filtered pools keep
        // the shared UPCAT IDs for the same topics.
        final topicId = poolsByTopic.containsKey(entry.key)
            ? entry.key
            : entry.key.replaceFirst(
                RegExp('^topic_cse_(pro|sub)_'),
                'topic_upcat_',
              );
        final topicPool = poolsByTopic[topicId] ?? const <String>[];
        if (topicPool.isEmpty) continue;

        final filtered = topicPool
            .where((id) => !recentlySampledQuestionIds.contains(id))
            .toList(growable: false);
        final candidatePool = filtered.length >= entry.value
            ? filtered
            : topicPool.toList(growable: false);
        final shuffled = candidatePool.toList()..shuffle(random);

        final topicPassageSets = passageSetsByTopic?[topicId];
        if (topicPassageSets != null && topicPassageSets.isNotEmpty) {
          final passageByQuestionId = {
            for (final passage in topicPassageSets.entries)
              for (final id in passage.value) id: passage.key,
          };
          final freeStanding = <String>[];
          final setsByPassageId = <String, List<String>>{};
          for (final qid in shuffled) {
            final pid = passageByQuestionId[qid];
            if (pid != null) {
              setsByPassageId.putIfAbsent(pid, () => []).add(qid);
            } else {
              freeStanding.add(qid);
            }
          }
          // Filtering recent questions can leave only part of a passage set.
          setsByPassageId.removeWhere(
            (id, set) => set.length != topicPassageSets[id]!.length,
          );
          final filled = PassageSetFiller.fillGeneric(
            size: entry.value,
            freeStanding: freeStanding,
            setsByPassageId: setsByPassageId,
          );
          if (filled.length == entry.value) {
            questionIds.addAll(filled);
            continue;
          }

          final topicIds = topicPool.toSet();
          final shuffledIds = shuffled.toSet();
          final exact = _exactFit(
            size: entry.value,
            passageSets: [
              ...setsByPassageId.values,
              for (final passage in topicPassageSets.entries)
                if (!setsByPassageId.containsKey(passage.key) &&
                    passage.value.every(topicIds.contains))
                  passage.value,
            ],
            freeStanding: [
              ...freeStanding,
              for (final id in topicIds.difference(shuffledIds))
                if (!passageByQuestionId.containsKey(id)) id,
            ],
            recentlySampledQuestionIds: recentlySampledQuestionIds,
          );
          questionIds.addAll(exact ?? filled);
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

  List<String>? _exactFit({
    required int size,
    required List<List<String>> passageSets,
    required List<String> freeStanding,
    required Set<String> recentlySampledQuestionIds,
  }) {
    // Any recent passage costs more than all standalones in an exact fit.
    final groups = [
      for (final set in passageSets)
        (
          ids: set,
          cost: set.any(recentlySampledQuestionIds.contains) ? size + 1 : 0
        ),
      for (final id in freeStanding)
        (ids: [id], cost: recentlySampledQuestionIds.contains(id) ? 1 : 0),
    ];
    final fits = List<({List<String> ids, int cost})?>.filled(
      size + 1,
      null,
    );
    fits[0] = (ids: [], cost: 0);
    for (final group in groups) {
      // Work backward so each group can contribute only once.
      for (var slots = size; slots >= group.ids.length; slots--) {
        final previous = fits[slots - group.ids.length];
        if (previous == null) continue;
        final cost = previous.cost + group.cost;
        final current = fits[slots];
        if (current == null || cost < current.cost) {
          fits[slots] = (ids: [...previous.ids, ...group.ids], cost: cost);
        }
      }
    }
    return fits[size]?.ids;
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
