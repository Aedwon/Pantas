import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: focusAsync.when(
        data: (focus) {
          final exam = focus.exam;
          if (exam == null) {
            return _noExamFallback(context);
          }
          final attemptsAsync = ref.watch(countForExamProvider(exam.id));
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    Text(
                      exam.shortName,
                      style: styles.displaySmall.copyWith(
                        fontFamily: 'SourceSerif4',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.ink,
                      ),
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
            loading: () => _loadingState(),
            error: (error, stack) => _errorState(context, ref, exam.id),
          );
        },
        loading: () => _loadingState(),
        error: (error, stack) => _errorState(context, ref, null),
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
          body:
              'Take the assessment and this fills in. It takes about twenty minutes and it is how Pantas learns where you are.',
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: const ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: 'Could not load your progress. Pull down to try again.',
          ),
        ),
      ),
    );
  }

  Widget _yourPaceSection(BuildContext context, WidgetRef ref) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Your pace'),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _performanceSection(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }

  Widget _whyYouMissSection(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }

  Widget _goDeeperSection(BuildContext context, WidgetRef ref) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Go deeper'),
      ],
    );
  }
}
