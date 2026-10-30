import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/presentation/record_page.dart';
import 'package:pantas/features/home/presentation/widgets/accuracy_line.dart';
import 'package:pantas/features/home/presentation/widgets/progress_skeletons.dart';

/// Shared MY_* header and scroll inset inside the existing sidebar shell.
class WebMyPage extends StatelessWidget {
  const WebMyPage({
    required this.title,
    required this.onBack,
    required this.child,
    super.key,
  });
  final String title;
  final VoidCallback onBack;
  final Widget child;
  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {const SingleActivator(LogicalKeyboardKey.escape): onBack},
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: context.webTokens.colors.background,
            body: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onBack,
                          icon: const Icon(Icons.chevron_left, size: 20),
                          label: const Text('Home'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 40),
                            foregroundColor: context.webTokens.colors.accent,
                            textStyle: context.webTokens.style(17),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      WebText(title, kind: WebTextKind.h1),
                      const SizedBox(height: 26),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class WebRecordLayout extends StatelessWidget {
  const WebRecordLayout({
    required this.record,
    required this.mocks,
    required this.onBack,
    required this.onMock,
    super.key,
  });
  final StudentRecord record;
  final List<RecordMockRow> mocks;
  final VoidCallback onBack;
  final ValueChanged<String> onMock;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final hours = record.sessionMinutes ~/ 60;
    final minutes = record.sessionMinutes % 60;
    final time = hours == 0
        ? '${minutes}m'
        : minutes == 0
            ? '${hours}h'
            : '${hours}h ${minutes}m';
    Widget figure(
      String value,
      String label, {
      bool big = false,
      bool streak = false,
    }) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style:
                  (big ? t.big : t.style(28, weight: FontWeight.w700)).copyWith(
                color: streak ? t.colors.accent : null,
                fontFeatures: [const FontFeature.tabularFigures()],
                letterSpacing: big ? -1.2 : -.56,
              ),
            ),
            SizedBox(height: big ? 4 : 2),
            Text(label, style: big ? t.sub : t.sm),
          ],
        );
    final totals = <({String value, String label})>[
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
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WebText('Since you started', kind: WebTextKind.eyebrow),
        WebCard(
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 22,
                    ),
                    child: figure(
                      '${record.weeksIn}',
                      record.weeksIn == 1 ? 'week in' : 'weeks in',
                      big: true,
                    ),
                  ),
                ),
                Container(
                  width: .5,
                  margin: const EdgeInsets.symmetric(vertical: 18),
                  color: t.colors.separator,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        figure(
                          '${record.dayStreak}',
                          'day streak',
                          big: true,
                          streak: true,
                        ),
                        if (record.streakStartedOn != null)
                          Text(
                            'since ${DateFormat('MMM d, y', 'en_US').format(
                              record.streakStartedOn!,
                            )}',
                            style: t.sub,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const WebText('Your totals', kind: WebTextKind.eyebrow),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final total in totals)
                SizedBox(
                  width: (constraints.maxWidth - 24) / 3,
                  child: WebCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    child: figure(total.value, total.label),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const WebText('Accuracy across your prep', kind: WebTextKind.eyebrow),
        WebCard(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: record.accuracySeries.length < 2
              ? SizedBox(
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 60,
                        child: CustomPaint(
                          painter: _EarlyRecordLine(t.strongDivider),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your line starts after two weeks of answers.',
                        style: t.sub,
                      ),
                    ],
                  ),
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
                          style: t.style(28, weight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Text('this week', style: t.sub),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AccuracyLine(series: record.accuracySeries, web: true),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM d', 'en_US').format(
                            record.accuracySeries.first.weekStart,
                          ),
                          style: t.sm,
                        ),
                        Text('This week', style: t.sm),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mocks.isNotEmpty) ...[
          const WebText('Your mocks', kind: WebTextKind.eyebrow),
          WebCard(
            child: Column(
              children: [
                for (final (i, mock) in mocks.indexed)
                  WebRow(
                    title: mock.name,
                    subtitle: DateFormat('MMM d, y', 'en_US').format(mock.date),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${mock.percent}%',
                          style: t.style(17, weight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: t.colors.chevron,
                        ),
                      ],
                    ),
                    divider: i < mocks.length - 1,
                    onPressed: () => onMock(mock.id),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
    return WebMyPage(
      title: 'Your record',
      onBack: onBack,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The board's 520 + 320 + 28 basis wraps below 868 content pixels.
          if (constraints.maxWidth < 868) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [left, const SizedBox(height: 28), right],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 520 + (constraints.maxWidth - 868) * 1.6 / 2.6,
                child: left,
              ),
              const SizedBox(width: 28),
              Expanded(child: right),
            ],
          );
        },
      ),
    );
  }
}

class _EarlyRecordLine extends CustomPainter {
  const _EarlyRecordLine(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(4, 46)
      ..cubicTo(50, 40, 80, 30, 110, 32)
      ..cubicTo(140, 34, 170, 18, 216, 12);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += 11) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_EarlyRecordLine oldDelegate) =>
      oldDelegate.color != color;
}

/// L_ProgressSlow: no invented figures while history is being read.
class WebMyLoading extends StatelessWidget {
  const WebMyLoading({this.record = false, super.key});

  /// Your record has its own column layout; Your tendencies follows the board.
  final bool record;
  @override
  Widget build(BuildContext context) =>
      record ? const WebRecordLoading() : const WebTendenciesLoading();
}

class WebMyFailure extends StatelessWidget {
  const WebMyFailure({required this.onRetry, super.key});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => WebCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
        child: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 28,
              color: context.webTokens.colors.tertiaryLabel,
            ),
            const SizedBox(height: 14),
            Text(
              'Could not load your progress.',
              style: context.webTokens.style(17),
            ),
            const SizedBox(height: 18),
            WebButton(
              label: 'Try Again',
              variant: WebButtonVariant.secondary,
              onPressed: onRetry,
            ),
          ],
        ),
      );
}
