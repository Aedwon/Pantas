import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/data_row_tile.dart';
import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/presentation/widgets/accuracy_line.dart';

class YourRecordPage extends ConsumerWidget {
  const YourRecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(recordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your record'),
      ),
      body: recordAsync.when(
        data: (record) => _buildBody(context, record),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, StudentRecord record) {
    final mockFormat = DateFormat.yMMMd();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Panel 1: "Since you started"
          RuledPanel(
            heading: 'Since you started',
            child: Column(
              children: [
                DataRowTile(
                  title: 'weeks in',
                  primaryFigure: '${record.weeksIn}',
                ),
                DataRowTile(
                  title: 'day streak',
                  primaryFigure: '${record.dayStreak}',
                ),
                if (record.streakStartedOn != null)
                  DataRowTile(
                    title:
                        'since ${mockFormat.format(record.streakStartedOn!)}',
                  ),
              ],
            ),
          ),

          // Panel 2: "Your totals"
          RuledPanel(
            heading: 'Your totals',
            child: Column(
              children: [
                DataRowTile(
                  title: 'questions answered',
                  primaryFigure: '${record.questionsAnswered}',
                ),
                DataRowTile(
                  title: 'time in sessions',
                  primaryFigure: '${record.sessionMinutes}m',
                ),
                DataRowTile(
                  title: 'lessons read',
                  primaryFigure: '${record.lessonsRead}',
                ),
                DataRowTile(
                  title: 'days active',
                  primaryFigure: '${record.daysActive}',
                ),
                DataRowTile(
                  title: 'longest streak',
                  primaryFigure: '${record.longestStreak}',
                ),
                if (record.bestMockPercent != null)
                  DataRowTile(
                    title: 'best mock',
                    primaryFigure: '${record.bestMockPercent}%',
                  ),
              ],
            ),
          ),

          // Panel 3: "Accuracy across your prep"
          RuledPanel(
            heading: 'Accuracy across your prep',
            child: AccuracyLine(series: record.accuracySeries),
          ),

          // Panel 4: "Your mocks" (absent if no mock)
          if (record.mocks.isNotEmpty)
            RuledPanel(
              heading: 'Your mocks',
              child: Column(
                children: [
                  for (final mock in record.mocks)
                    DataRowTile(
                      title: mock.blueprintName,
                      subtext: mockFormat.format(mock.takenOn),
                      primaryFigure: '${mock.percent}%',
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
