import 'dart:async';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/empty_state.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ink_magnifier.dart';
import 'package:pantas/core/ui/components/page_scaffold.dart';
import 'package:pantas/core/ui/components/tab_header.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/lesson/application/study_map_providers.dart';
import 'package:pantas/features/lesson/domain/use_cases/build_study_map.dart';
import 'package:pantas/features/lesson/presentation/widgets/bookmarks_section.dart';
import 'package:pantas/features/lesson/presentation/widgets/pinned_topic_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_field_bar.dart';
import 'package:pantas/features/lesson/presentation/widgets/search_results.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_head_block.dart';
import 'package:pantas/features/lesson/presentation/widgets/study_topic_section.dart';
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
  final _listKey = GlobalKey();
  bool _searching = false;

  /// Whether the open topic's row has left the screen.
  ///
  /// The pinned bar exists to get you back to a topic you can no longer see.
  /// It used to appear the instant a topic opened, which is the one moment
  /// you are looking straight at it, and it announced that by pushing the
  /// whole list down.
  final _openTopicOffScreen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncPinnedBar);
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
    _openTopicOffScreen.dispose();
    super.dispose();
  }

  /// A notifier rather than `setState`: this runs on every scroll frame and
  /// the list below it must not rebuild for it.
  void _syncPinnedBar() {
    final topicId = ref.read(openTopicProvider).valueOrNull;
    if (topicId == null) {
      _openTopicOffScreen.value = false;
      return;
    }
    _openTopicOffScreen.value = !_isOnScreen(topicId);
  }

  bool _isOnScreen(TopicId topicId) {
    final rowContext = _topicKeys[topicId]?.currentContext;
    final listContext = _listKey.currentContext;
    final row = rowContext?.findRenderObject() as RenderBox?;
    final list = listContext?.findRenderObject() as RenderBox?;
    if (row == null || list == null || !row.attached || !list.attached) {
      // Unknown, so say it is visible: a bar that appears on a guess is
      // worse than one that arrives a frame late.
      return true;
    }
    final rowTop = row.localToGlobal(Offset.zero).dy;
    final rowBottom = rowTop + row.size.height;
    final listTop = list.localToGlobal(Offset.zero).dy;
    final listBottom = listTop + list.size.height;
    return rowBottom > listTop && rowTop < listBottom;
  }

  /// Toggles a topic and leaves the row the student tapped exactly where
  /// it was on screen.
  ///
  /// Only one topic is open at a time, so opening one closes another, and
  /// when the closed one sits above the tapped row everything below it
  /// slides up under the finger. The row is measured before and after the
  /// frame and the scroll is corrected by the difference.
  Future<void> _toggleTopic(TopicId topicId) async {
    final before = _offsetOf(topicId);
    await ref.read(openTopicProvider.notifier).toggle(topicId);
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final after = _offsetOf(topicId);
      if (before == null || after == null || !_scrollController.hasClients) {
        return;
      }
      _syncPinnedBar();
      final drift = after - before;
      if (drift.abs() < 0.5) return;
      final target = (_scrollController.offset + drift).clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(target);
    });
  }

  double? _offsetOf(TopicId topicId) {
    final context = _topicKeys[topicId]?.currentContext;
    final box = context?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.localToGlobal(Offset.zero).dy;
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
              body: 'This exam has no lessons on your device yet. Check back '
                  'after the next content update.',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_searching)
                SearchFieldBar(
                  onCancel: () {
                    setState(() => _searching = false);
                  },
                )
              else
                TabHeader(
                  title: 'Study',
                  trailing: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _searching = true),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: InkMagnifier(),
                    ),
                  ),
                ),
              if (_searching)
                const Expanded(
                  child: SearchResults(),
                )
              else ...[
                Expanded(
                  // The bar is stacked over the list, not placed above it.
                  // Inserting it changed the list's height the moment a topic
                  // opened, which is the snap.
                  child: Stack(
                    key: _listKey,
                    children: [
                      ListView(
                        controller: _scrollController,
                        children: [
                          StudyHeadBlock(map: map),
                          const BookmarksSection(),
                          for (final subject in map.subjects)
                            StudySubjectSection(
                              subject: subject,
                              onToggleTopic: (topicId) =>
                                  unawaited(_toggleTopic(topicId)),
                              keyForTopic: _keyFor,
                            ),
                        ],
                      ),
                      if (openTopic != null)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _openTopicOffScreen,
                            builder: (context, offScreen, child) =>
                                IgnorePointer(
                              ignoring: !offScreen,
                              child: AnimatedSlide(
                                offset: Offset(0, offScreen ? 0 : -1),
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                child: AnimatedOpacity(
                                  opacity: offScreen ? 1 : 0,
                                  duration: const Duration(milliseconds: 180),
                                  child: child,
                                ),
                              ),
                            ),
                            child: PinnedTopicBar(
                              topic: openTopic,
                              onScrollBack: () => _scrollBackTo(openTopic!.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
