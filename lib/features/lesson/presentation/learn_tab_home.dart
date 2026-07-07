import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/page_scaffold.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/lesson/application/study_map_providers.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/pinned_topic_bar.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/study_head_block.dart';
import 'package:cse_cet_reviewer/features/lesson/presentation/widgets/study_topic_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LearnTabHome extends ConsumerWidget {
  const LearnTabHome({this.openTopicId, super.key});

  final TopicId? openTopicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StudyTabHome(openTopicId: openTopicId);
  }
}

class StudyTabHome extends ConsumerStatefulWidget {
  const StudyTabHome({this.openTopicId, super.key});

  final TopicId? openTopicId;

  @override
  ConsumerState<StudyTabHome> createState() => _StudyTabHomeState();
}

class _StudyTabHomeState extends ConsumerState<StudyTabHome> {
  final _scrollController = ScrollController();
  final _topicKeys = <TopicId, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    final requested = widget.openTopicId;
    if (requested != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(openTopicProvider.notifier).toggle(requested);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollBackTo(TopicId topicId) {
    final context = _topicKeys[topicId]?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  GlobalKey _keyFor(TopicId topicId) =>
      _topicKeys.putIfAbsent(topicId, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final asyncMap = ref.watch(studyMapProvider);

    return asyncMap.when(
      loading: () => const PageScaffold(body: FaintBars()),
      error: (e, _) => const PageScaffold(
        body: ErrorBanner(
          variant: ErrorBannerVariant.error,
          message: 'Could not load your topics. Pull down to try again.',
        ),
      ),
      data: (map) {
        if (map == null) {
          return const PageScaffold(body: _ChooseExamFallback());
        }

        if (map.isEmpty) {
          return PageScaffold(
            body: EmptyState(
              headline: 'Nothing to study yet',
              body:
                  'This exam has no lessons on your device yet. Check back after the next content update.',
              ctaLabel: 'Try a quick quiz',
              onCta: () => context.push('/quiz'),
            ),
          );
        }

        final openTopicId = ref.watch(openTopicProvider).valueOrNull;
        StudyTopic? openTopic;
        if (openTopicId != null) {
          for (final subject in map.subjects) {
            for (final topic in subject.topics) {
              if (topic.id == openTopicId) {
                openTopic = topic;
                break;
              }
            }
          }
        }

        return PageScaffold(
          body: Column(
            children: [
              if (openTopic != null)
                PinnedTopicBar(
                  topic: openTopic,
                  onScrollBack: () => _scrollBackTo(openTopic!.id),
                ),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  children: [
                    StudyHeadBlock(map: map),
                    for (final subject in map.subjects)
                      StudySubjectSection(
                        subject: subject,
                        keyForTopic: _keyFor,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChooseExamFallback extends StatelessWidget {
  const _ChooseExamFallback();

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          onPressed: () => context.go('/onboarding'),
        ),
      ],
    );
  }
}
