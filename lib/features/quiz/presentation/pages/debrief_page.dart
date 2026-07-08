import 'package:cse_cet_reviewer/features/paywall/paywall.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/debrief/miss_cause.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/debrief/session_debrief.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/quiz_session.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/debrief_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DebriefPage extends ConsumerWidget {
  const DebriefPage({
    required this.attemptId,
    this.proIsActive,
    this.sessionOverride,
    this.attemptOverride,
    super.key,
  });

  final String attemptId;
  final bool? proIsActive;
  final QuizSession? sessionOverride;
  final Attempt? attemptOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final entitlement =
        ref.watch(entitlementProvider).valueOrNull ?? const Entitlement.free();
    final effectiveProIsActive = proIsActive ?? entitlement.proIsActive;

    final debriefAsync = ref.watch(
      sessionDebriefProvider((
        attemptId: attemptId,
        proIsActive: effectiveProIsActive,
        sessionOverride: sessionOverride,
        attemptOverride: attemptOverride,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Close',
          icon: Icon(Icons.close, size: 17, color: colors.inkMuted),
          onPressed: () => _leave(context),
        ),
      ),
      body: debriefAsync.when(
        data: (debrief) => _DebriefBody(
          debrief: debrief,
          attemptId: attemptId,
          proIsActive: effectiveProIsActive,
        ),
        loading: () => const Center(child: FaintBars()),
        error: (err, _) => Center(child: Text('Error loading debrief: $err')),
      ),
    );
  }

  static void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/quiz');
    }
  }
}

class _DebriefBody extends ConsumerStatefulWidget {
  const _DebriefBody({
    required this.debrief,
    required this.attemptId,
    required this.proIsActive,
  });

  final SessionDebrief debrief;
  final String attemptId;
  final bool proIsActive;

  @override
  ConsumerState<_DebriefBody> createState() => _DebriefBodyState();
}

class _DebriefBodyState extends ConsumerState<_DebriefBody> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final debrief = widget.debrief;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(debrief.headline, style: styles.headlineMedium),
              const SizedBox(height: 16),
              StatsBand(
                figures: [
                  StatFigure(
                    value: '${debrief.correct}',
                    label: 'correct',
                  ),
                  StatFigure(
                    value: '${debrief.minutes} m',
                    label: 'taken',
                  ),
                ],
                centred: true,
                compact: true,
              ),
              const SizedBox(height: 12),
              Text(
                debrief.sourceLine,
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
              if (!debrief.isClean) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'To come back to',
                  trailing: Text(
                    '${debrief.misses.length}',
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ),
                const SizedBox(height: 8),
                for (final miss in debrief.misses)
                  _MissRow(
                    miss: miss,
                    proIsActive: widget.proIsActive,
                  ),
                if (debrief.returnPromise.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    debrief.returnPromise,
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colors.rule,
                        width: AppDimensions.hairline,
                      ),
                    ),
                  ),
                  child: InkTableRow(
                    title: 'Go through all ${debrief.total}',
                    bottomRule: false,
                    onTap: () =>
                        context.push('/review?attemptId=${widget.attemptId}'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              BoardButton(
                label: 'Done',
                onPressed: () => DebriefPage._leave(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissRow extends StatelessWidget {
  const _MissRow({
    required this.miss,
    required this.proIsActive,
  });

  final DebriefMiss miss;
  final bool proIsActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '✕',
              style: styles.bodyMedium.copyWith(color: colors.rust),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PortableTextRenderer(
                  text: miss.label,
                  maxLines: miss.labelIsStem ? 2 : null,
                ),
                const SizedBox(height: 2),
                Text(
                  '${miss.topicName} · you picked ${miss.pickedLabel}, '
                  'answer was ${miss.answerLabel}',
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
                if (proIsActive && miss.cause != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _causeLine(miss.cause!),
                    style: styles.bodySmall.copyWith(
                      color: colors.inkMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _causeLine(MissCause cause) {
    return switch (cause) {
      RushedCause(
        :final responseSeconds,
        :final usualSeconds,
        :final topicName
      ) =>
        'You answered in $responseSeconds seconds. You usually take $usualSeconds on $topicName.',
      SlippedCause(:final lastCorrectAt) =>
        'You had this right on ${_formatDay(lastCorrectAt)}.',
      NewCause() => "It's the first time you've seen this one.",
    };
  }

  String _formatDay(DateTime dt) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${dt.day} ${months[dt.month]}';
  }
}
