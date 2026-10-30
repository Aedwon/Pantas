import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _figure(
                      context,
                      '${record.weeksIn}',
                      record.weeksIn == 1 ? 'week in' : 'weeks in',
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${record.dayStreak}',
                                style: context.type.largeTitle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 22,
                              height: 26,
                              child: PantasIcons.streak,
                            ),
                          ],
                        ),
                        Text(
                          'day streak',
                          style: context.type.subhead.copyWith(
                            color: context.colors.secondaryLabel,
                          ),
                        ),
                        if (record.streakStartedOn != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'since ${DateFormat('MMM d, y', 'en_US').format(
                                record.streakStartedOn!,
                              )}',
                              style: context.type.footnote,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GroupedSection(
          header: 'Your totals',
          children: [
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                children: [
                  for (final figure in figures)
                    SizedBox(
                      width: constraints.maxWidth / 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _figure(
                          context,
                          figure.value,
                          figure.label,
                        ),
                      ),
                    ),
                ],
              ),
            ),
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

  Widget _figure(BuildContext context, String value, String label) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: context.type.largeTitle),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.type.subhead
                .copyWith(color: context.colors.secondaryLabel),
          ),
        ],
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
