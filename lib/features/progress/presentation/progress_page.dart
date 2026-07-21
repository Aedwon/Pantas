import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/navigational_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/tab_header.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/progress/application/how_you_work_provider.dart';
import 'package:cse_cet_reviewer/features/progress/application/record_provider.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/performance_section.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/why_you_miss_section.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/widgets/your_pace_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;

    final focusAsync = ref.watch(activeExamFocusProvider);

    // No AppBar: it took the Material default for its height, its background
    // and its title size, so Progress sat lower than Quiz and printed its
    // name larger than either neighbour.
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TabHeader(title: 'Progress'),
            ),
            Expanded(
              child: focusAsync.when(
                data: (focus) {
                  final exam = focus.exam;
                  if (exam == null) {
                    return _noExamFallback(context);
                  }
                  final attemptsAsync =
                      ref.watch(countForExamProvider(exam.id));
                  return attemptsAsync.when(
                    data: (count) {
                      if (count == 0) {
                        return _dayOne(context, ref, exam.id);
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(countForExamProvider(exam.id));
                        },
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          children: [
                            Text(
                              exam.shortName,
                              // Was respelled in full here. `displaySmall`
                              // is already sans at 22/700 now that there is
                              // one family, so the override said the same
                              // thing twice and could drift from it.
                              style: styles.displaySmall,
                            ),
                            const SizedBox(height: 16),
                            _yourPaceSection(context, ref),
                            _performanceSection(context, ref),
                            _whyYouMissSection(context, ref),
                            _goDeeperSection(context, ref),
                          ],
                        ),
                      );
                    },
                    loading: _loadingState,
                    error: (error, stack) => _errorState(context, ref, exam.id),
                  );
                },
                loading: _loadingState,
                error: (error, stack) => _errorState(context, ref, null),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noExamFallback(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Choose your exam', style: styles.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Pick the exam you are reviewing for.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 20),
          BoardButton(
            label: 'Choose exam',
            onPressed: () => context.push('/settings/exam'),
            secondary: true,
          ),
        ],
      ),
    );
  }

  Widget _dayOne(BuildContext context, WidgetRef ref, String examId) {
    final styles = context.textStyles;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmptyState(
          headline: 'Nothing to report yet',
          body: 'Take the assessment and this fills in. It takes about twenty '
              'minutes and it is how Pantas learns where you are.',
          ctaLabel: 'Take the assessment',
          onCta: () => context.push('/assessment/$examId'),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: InkWell(
            onTap: () => context.push('/mock-exam'),
            child: Text(
              'Or take a mock exam',
              style: styles.bodyMedium.copyWith(
                color: colors.board,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingState() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: FaintBars(),
    );
  }

  Widget _errorState(BuildContext context, WidgetRef ref, String? examId) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: RefreshIndicator(
        onRefresh: () async {
          if (examId != null) {
            ref.invalidate(countForExamProvider(examId));
          } else {
            ref.invalidate(activeExamFocusProvider);
          }
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: 'Could not load your progress. Pull down to try again.',
          ),
        ),
      ),
    );
  }

  Widget _yourPaceSection(BuildContext context, WidgetRef ref) =>
      const YourPacePanel();

  Widget _performanceSection(BuildContext context, WidgetRef ref) =>
      const PerformanceSection();

  Widget _whyYouMissSection(BuildContext context, WidgetRef ref) =>
      const WhyYouMissSection();

  Widget _goDeeperSection(BuildContext context, WidgetRef ref) {
    // **These subtitles printed the spec's illustrative example as though it
    // were the student's own reading.** With no archetype and no measured
    // hours the row said "Night-Owl Sprinter. Sharpest at 9 pm, in 8 minute
    // sits.", and the page behind it correctly said there was not enough data
    // yet. Aedwon found the contradiction; the invented figure is the graver
    // half of it, and it was also the error fallback.
    //
    // Nothing measured means nothing claimed. An empty subtitle is not drawn
    // at all, which is the right answer while a value is still loading or has
    // failed to load.
    final howYouWorkAsync = ref.watch(howYouWorkProvider);
    final subtitle = howYouWorkAsync.when(
      data: (work) {
        final parts = <String>[];
        if (work.archetype != null) parts.add(work.archetype!);
        for (final row in work.whenYouWork) {
          parts.add('${row.title} at ${row.meta}');
        }
        if (parts.isEmpty) return 'Not enough data yet';
        return parts.join('. ');
      },
      loading: () => '',
      error: (_, __) => '',
    );

    final recordAsync = ref.watch(recordProvider);
    final recordSubtitle = recordAsync.when(
      data: (record) {
        final parts = <String>['Day ${record.daysActive}'];
        if (record.bestMockPercent != null) {
          parts.add('Best mock ${record.bestMockPercent}%');
        }
        return parts.join('. ');
      },
      loading: () => '',
      // "Day 1." is a figure, and a failed read has not measured it.
      error: (_, __) => '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Go deeper'),
        NavigationalRow(
          title: 'How you work',
          subtitle: subtitle,
          onTap: () => context.push('/progress/how-you-work'),
        ),
        NavigationalRow(
          title: 'Your record',
          subtitle: recordSubtitle,
          onTap: () => context.push('/progress/your-record'),
        ),
      ],
    );
  }
}
