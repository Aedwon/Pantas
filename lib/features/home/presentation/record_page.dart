import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/presentation/widgets/accuracy_line.dart';
import 'package:pantas/features/home/presentation/widgets/web_record_layout.dart';

class RecordMockRow {
  const RecordMockRow({
    required this.id,
    required this.name,
    required this.date,
    required this.percent,
  });
  final String id;
  final String name;
  final DateTime date;
  final int percent;
}

class RecordPage extends StatelessWidget {
  const RecordPage({
    required this.record,
    required this.mocks,
    required this.onBack,
    required this.onMock,
    this.wrappedRow,
    super.key,
  });
  final StudentRecord record;
  final List<RecordMockRow> mocks;
  final VoidCallback onBack;
  final ValueChanged<String> onMock;
  final Widget? wrappedRow;
  @override
  Widget build(BuildContext context) {
    if (context.wideWeb) {
      return WebRecordLayout(
        record: record,
        mocks: mocks,
        onBack: onBack,
        onMock: onMock,
      );
    }
    final hours = record.sessionMinutes ~/ 60;
    final minutes = record.sessionMinutes % 60;
    final time = hours == 0
        ? '${minutes}m'
        : minutes == 0
            ? '${hours}h'
            : '${hours}h ${minutes}m';
    final figures = <({String value, String label})>[
      (
        value: NumberFormat.decimalPattern('en_US')
            .format(record.questionsAnswered),
        label: 'questions answered'
      ),
      (value: time, label: 'time in sessions'),
      (value: '${record.lessonsRead}', label: 'lessons read'),
      (value: '${record.daysActive}', label: 'days active'),
      (value: '${record.longestStreak}', label: 'longest streak'),
      if (record.bestMockPercent != null)
        (value: '${record.bestMockPercent}%', label: 'best mock'),
    ];
    return PantasPage(
      title: 'Your record',
      backLabel: 'Home',
      onBack: onBack,
      bottomInset: 104,
      children: [
        GroupedSection(
          header: 'Since you started',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _sinceCell(
                        context,
                        value: '${record.weeksIn}',
                        label: record.weeksIn == 1 ? 'week in' : 'weeks in',
                      ),
                    ),
                    const SizedBox(width: 16),
                    _divider(context),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _sinceCell(
                        context,
                        value: '${record.dayStreak}',
                        label: 'day streak',
                        flame: true,
                        since: record.streakStartedOn == null
                            ? null
                            : 'since ${DateFormat('MMM d, y', 'en_US').format(
                                record.streakStartedOn!,
                              )}',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          header: 'Your totals',
          children: [
            for (var i = 0; i < figures.length; i += 2) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _totalCell(context, figures[i])),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _divider(context),
                    ),
                    Expanded(
                      child: i + 1 < figures.length
                          ? _totalCell(context, figures[i + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              if (i + 2 < figures.length)
                Divider(
                  height: .5,
                  thickness: .5,
                  color: context.colors.separator,
                ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          header: 'Accuracy across your prep',
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: record.accuracySeries.length < 2
                  ? Column(
                      children: [
                        SizedBox(
                          height: 95,
                          width: double.infinity,
                          child: CustomPaint(
                            painter: _PlaceholderLine(
                              context.colors.separator,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your line starts after two weeks of answers.',
                          style: context.type.footnote,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${record.accuracySeries.last.accuracy.round()}%',
                              style: context.type.sectionHero,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'this week',
                              style: context.type.footnote,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AccuracyLine(series: record.accuracySeries),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM d', 'en_US').format(
                                record.accuracySeries.first.weekStart,
                              ),
                              style: context.type.footnote,
                            ),
                            Text(
                              'This week',
                              style: context.type.footnote,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ),
        if (mocks.isNotEmpty) ...[
          const SizedBox(height: 24),
          GroupedSection(
            header: 'Your mocks',
            children: [
              for (var i = 0; i < mocks.length; i++)
                ListRow(
                  title: mocks[i].name,
                  subtitle:
                      DateFormat('MMM d, y', 'en_US').format(mocks[i].date),
                  value: '${mocks[i].percent}%',
                  divider: i < mocks.length - 1,
                  onTap: () => onMock(mocks[i].id),
                ),
            ],
          ),
        ],
        if (wrappedRow != null) ...[const SizedBox(height: 24), wrappedRow!],
      ],
    );
  }

  // YR_Full: a half-point hairline between cells.
  Widget _divider(BuildContext context) =>
      SizedBox(width: .5, child: ColoredBox(color: context.colors.separator));

  Widget _sinceCell(
    BuildContext context, {
    required String value,
    required String label,
    bool flame = false,
    String? since,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (flame) ...[
                Transform.translate(
                  offset: const Offset(-2, 0),
                  child: IconTheme(
                    data: IconThemeData(
                      color: context.colors.warningText,
                      size: 26,
                    ),
                    child: PantasIcons.streak,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  value,
                  style: context.type.largeTitle.tabular.copyWith(
                    fontSize: 40,
                    letterSpacing: -1.2,
                    height: 1.05,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.type.subhead.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: context.colors.label,
            ),
          ),
          if (since != null) Text(since, style: context.type.footnote),
        ],
      );

  Widget _totalCell(
    BuildContext context,
    ({String value, String label}) figure,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              figure.value,
              style: context.type.sectionHero.tabular
                  .copyWith(letterSpacing: -.48),
            ),
            const SizedBox(height: 1),
            Text(figure.label, style: context.type.footnote),
          ],
        ),
      );
}

class _PlaceholderLine extends CustomPainter {
  _PlaceholderLine(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var x = 0.0; x < size.width; x += 9) {
      canvas.drawLine(
        Offset(x, size.height * .55),
        Offset(x + 3, size.height * .55),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PlaceholderLine old) => old.color != color;
}
