import 'dart:ui';
import 'package:cse_cet_reviewer/core/storage/domain/choice.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/ui/components/answer_reveal.dart';
import 'package:cse_cet_reviewer/core/ui/components/pennant_mark.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum ReviewFilter { all, wrong, flagged }

/// One question as the review lists it.
class ReviewEntry {
  const ReviewEntry({
    required this.number,
    required this.question,
    required this.isFlagged,
    required this.subjectName,
    required this.label,
    required this.labelIsStem,
    this.chosenChoiceId,
  });

  final int number;
  final Question question;

  /// Null where the question was left blank, which a mock allows and a
  /// practice session does not.
  final ChoiceId? chosenChoiceId;

  final bool isFlagged;
  final String subjectName;

  /// The authored short label, or the stem when the content pass has not
  /// reached this question.
  final String label;
  final bool labelIsStem;

  bool get isAnswered => chosenChoiceId != null;

  bool get isCorrect =>
      chosenChoiceId != null && chosenChoiceId == question.correctChoice.id;
}

class ReviewCounts {
  const ReviewCounts({
    required this.all,
    required this.wrong,
    required this.flagged,
  });

  final int all;
  final int wrong;
  final int flagged;
}

abstract final class FilterReviewEntries {
  /// A blank counts as wrong.
  ///
  /// Not because it is graded the same, but because the student opening this
  /// filter is looking for what they did not get, and a question they never
  /// answered is one of those. The opposite reading is defensible; this one is
  /// chosen and stated so a later reader does not have to guess.
  static bool _isMiss(ReviewEntry entry) => !entry.isCorrect;

  static List<ReviewEntry> call(
    List<ReviewEntry> entries,
    ReviewFilter filter,
  ) =>
      switch (filter) {
        ReviewFilter.all => entries,
        ReviewFilter.wrong => entries.where(_isMiss).toList(),
        ReviewFilter.flagged =>
          entries.where((entry) => entry.isFlagged).toList(),
      };

  static ReviewCounts count(List<ReviewEntry> entries) => ReviewCounts(
        all: entries.length,
        wrong: entries.where(_isMiss).length,
        flagged: entries.where((entry) => entry.isFlagged).length,
      );

  /// First-seen order, so the groups follow the paper rather than the
  /// alphabet.
  static Map<String, List<ReviewEntry>> groupBySubject(
    List<ReviewEntry> entries,
  ) {
    final grouped = <String, List<ReviewEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.subjectName, () => []).add(entry);
    }
    return grouped;
  }
}

class ReviewList extends StatefulWidget {
  const ReviewList({
    required this.entries,
    required this.proIsActive,
    required this.grouped,
    required this.onToggleFlag,
    this.header,
    this.footer,
    this.initialFilter = ReviewFilter.wrong,
    this.showFilters = true,
    super.key,
  });

  final List<ReviewEntry> entries;
  final bool proIsActive;
  final bool grouped;
  final ValueChanged<QuestionId> onToggleFlag;
  final Widget? header;
  final Widget? footer;
  final ReviewFilter initialFilter;
  final bool showFilters;

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  late ReviewFilter _filter;
  final Set<int> _expandedNumbers = {};

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  void _toggleExpanded(int number) {
    setState(() {
      if (_expandedNumbers.contains(number)) {
        _expandedNumbers.remove(number);
      } else {
        _expandedNumbers.add(number);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final counts = FilterReviewEntries.count(widget.entries);
    final filteredEntries = FilterReviewEntries.call(widget.entries, _filter);

    Widget buildGroup(String? subjectName, List<ReviewEntry> entriesInGroup) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.grouped && subjectName != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    subjectName,
                    style: styles.headlineSmall.copyWith(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entriesInGroup.length}',
                    style: styles.bodySmall.copyWith(
                      color: colors.inkMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: AppDimensions.hairline, color: colors.rule),
          ],
          for (final entry in entriesInGroup) ...[
            ReviewRow(
              entry: entry,
              isExpanded: _expandedNumbers.contains(entry.number),
              proIsActive: widget.proIsActive,
              onToggleExpanded: () => _toggleExpanded(entry.number),
              onToggleFlag: widget.onToggleFlag,
            ),
            Container(height: AppDimensions.hairline, color: colors.ruleFaint),
          ],
        ],
      );
    }

    final groupedMap = widget.grouped
        ? FilterReviewEntries.groupBySubject(filteredEntries)
        : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) ...[
            widget.header!,
            const SizedBox(height: 16),
          ],
          if (widget.showFilters) ...[
            _FilterRow(
              active: _filter,
              counts: counts,
              onChanged: (newFilter) {
                setState(() {
                  _filter = newFilter;
                });
              },
            ),
            const SizedBox(height: 12),
          ],
          if (widget.grouped && groupedMap != null) ...[
            for (final entry in groupedMap.entries)
              buildGroup(entry.key, entry.value),
          ] else ...[
            buildGroup(null, filteredEntries),
          ],
          if (widget.footer != null) ...[
            const SizedBox(height: 24),
            widget.footer!,
          ],
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.active,
    required this.counts,
    required this.onChanged,
  });

  final ReviewFilter active;
  final ReviewCounts counts;
  final ValueChanged<ReviewFilter> onChanged;

  String _label(ReviewFilter filter, ReviewCounts counts) {
    return switch (filter) {
      ReviewFilter.all => 'All ${counts.all}',
      ReviewFilter.wrong => 'Wrong ${counts.wrong}',
      ReviewFilter.flagged => 'Flagged ${counts.flagged}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    // Plain labels with rule ticks between them. No pills: a pill is a
    // filled shape, and the only filled shapes in this identity are the
    // board button and a set mark.
    return Row(
      children: [
        for (var i = 0; i < ReviewFilter.values.length; i++) ...[
          if (i > 0)
            Container(
              width: AppDimensions.hairline,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 9),
              color: colors.rule,
            ),
          InkWell(
            onTap: () => onChanged(ReviewFilter.values[i]),
            child: Text(
              _label(ReviewFilter.values[i], counts),
              style: styles.bodySmall.copyWith(
                color: active == ReviewFilter.values[i]
                    ? colors.ink
                    : colors.inkMuted,
                fontWeight: active == ReviewFilter.values[i]
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ReviewRow extends StatelessWidget {
  const ReviewRow({
    required this.entry,
    required this.isExpanded,
    required this.proIsActive,
    required this.onToggleExpanded,
    required this.onToggleFlag,
    super.key,
  });

  final ReviewEntry entry;
  final bool isExpanded;
  final bool proIsActive;
  final VoidCallback onToggleExpanded;
  final ValueChanged<QuestionId> onToggleFlag;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            // Expands in place. A pushed detail route loses the student's
            // position, which is the whole reason this is a list they work
            // down rather than a stack they climb.
            onTap: onToggleExpanded,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${entry.number}',
                    style: styles.headlineSmall.copyWith(
                      fontSize: 14,
                      color: colors.inkMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                Expanded(
                  child: PortableTextRenderer(
                    text: entry.label,
                    maxLines: entry.labelIsStem ? 2 : null,
                  ),
                ),
                _OutcomeMark(entry: entry),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onToggleFlag(entry.question.id),
                  child: PennantMark(isSet: entry.isFlagged),
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AnswerReveal(
                question: entry.question,
                chosenChoiceId: entry.chosenChoiceId ?? '',
                proIsActive: proIsActive,
                // Nothing was just scheduled here, so there is no interval to
                // state and no verdict to deliver: the marks already said it.
                nextReviewIntervalDays: null,
              ),
            ),
        ],
      ),
    );
  }
}

class _OutcomeMark extends StatelessWidget {
  const _OutcomeMark({required this.entry});

  final ReviewEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    if (!entry.isAnswered) {
      return SizedBox(
        width: 16,
        child: Text(
          '–',
          style: styles.bodyMedium.copyWith(color: colors.inkMuted),
        ),
      );
    }
    if (entry.isCorrect) {
      return SizedBox(
        width: 16,
        child: Text(
          '✓',
          style: styles.bodyMedium.copyWith(
            color: colors.board,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return SizedBox(
      width: 16,
      child: Text(
        '✕',
        style: styles.bodyMedium.copyWith(
          color: colors.rust,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
