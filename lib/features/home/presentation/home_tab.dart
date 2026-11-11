// lib/features/home/presentation/home_tab.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/skeleton_fade.dart';
import 'package:pantas/core/ui/components/tab_bar_visibility.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/home/domain/home_today_view.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_date_sheet.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_day.dart';
import 'package:pantas/features/home/presentation/widgets/home_install_slot.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';
import 'package:pantas/features/home/presentation/widgets/home_notice_strip.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_section.dart';
import 'package:pantas/features/home/presentation/widgets/home_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFocus = ref.watch(activeExamFocusProvider);
    firstScreenReady(context, ref, ready: asyncFocus.hasError, path: '/home');

    return Scaffold(
      body: SafeArea(
        // The floating tab bar covers the bottom; the list scrolls under it.
        bottom: !FloatingTabBarScope.of(context),
        child: asyncFocus.when(
          loading: () => const HomePageSkeleton(),
          error: (_, __) => errorFor(
            'home',
            () => ref.invalidate(activeExamFocusProvider),
          ),
          data: (focus) {
            if (focus.needsSelection || focus.exam == null) {
              return chooseExamFallback(context);
            }
            return _SelectedExamHome(examId: focus.exam!.id);
          },
        ),
      ),
    );
  }
}

class _SelectedExamHome extends ConsumerStatefulWidget {
  const _SelectedExamHome({required this.examId});

  final ExamId examId;

  @override
  ConsumerState<_SelectedExamHome> createState() => _SelectedExamHomeState();
}

class _SelectedExamHomeState extends ConsumerState<_SelectedExamHome> {
  HomeNoticeKind? _dateSheet;
  bool _saving = false;
  bool _failed = false;

  void _openDate(HomeNoticeKind? kind) => setState(() {
        _dateSheet = kind ?? HomeNoticeKind.noDate;
        _failed = false;
      });

  void _closeDate() => setState(() {
        _dateSheet = null;
        _saving = false;
        _failed = false;
      });

  Future<void> _saveDate(ExamDate date) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      await ref
          .read(settingsActionsProvider)
          .saveExamDate(date, today: DateTime.now());
      if (mounted) _closeDate();
    } on Object catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) {
        setState(() {
          _saving = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final examId = widget.examId;
    final settings = ref.watch(userSettingsProvider).valueOrNull;
    final examName =
        ref.watch(activeExamFocusProvider).valueOrNull?.exam?.shortName;
    final now = DateTime.now();
    Widget todayScreen() => HomeTodayScreen(
          key: ValueKey('today-$examId-${settings?.examDate?.storageValue}'),
          examId: examId,
          releaseSplashAtFirstFrame: true,
          onSetDate: () => _openDate(HomeNoticeKind.noDate),
          pageBuilder: (today, data) =>
              _list(context, now: now, today: today, data: data),
        );
    Widget nativeHome() {
      final result = ref.watch(assessmentResultProvider(examId));
      return result.when(
        loading: () => const HomePageSkeleton(),
        error: (_, __) => errorFor(
          'home',
          () => ref.invalidate(assessmentResultProvider(examId)),
        ),
        data: (assessment) => assessment == null
            ? _list(
                context,
                now: now,
                today: _AssessmentCard(examId: examId),
                notices: false,
              )
            : todayScreen(),
      );
    }

    // A restored web account may have server assessment evidence without a
    // local result row. Its authoritative Today state owns this choice.
    final page =
        ref.watch(studyUsesServerProvider) ? todayScreen() : nativeHome();
    if (context.wideWeb) {
      return HomeWebOverlay(
        page: page,
        label: 'Exam date',
        dialogWidth: _dateSheet == HomeNoticeKind.monthOnly ? 440 : 560,
        open: _dateSheet != null,
        onDismiss: _closeDate,
        child: SingleChildScrollView(
          child: HomeExamDateSheet(
            today: now,
            initial: _dateSheet == HomeNoticeKind.monthOnly
                ? settings?.examDate
                : null,
            requireDay: _dateSheet == HomeNoticeKind.monthOnly,
            examName: examName,
            saving: _saving,
            failed: _failed,
            onCancel: _closeDate,
            onSave: (date) => unawaited(_saveDate(date)),
          ),
        ),
      );
    }
    return PantasSheet(
      page: page,
      label: 'Exam date',
      open: _dateSheet != null,
      onDismiss: _closeDate,
      closeLabel: 'Cancel',
      child: HomeExamDateSheet(
        today: now,
        initial:
            _dateSheet == HomeNoticeKind.monthOnly ? settings?.examDate : null,
        requireDay: _dateSheet == HomeNoticeKind.monthOnly,
        examName: examName,
        saving: _saving,
        failed: _failed,
        onSave: (date) => unawaited(_saveDate(date)),
      ),
    );
  }

  Widget _list(
    BuildContext context, {
    required DateTime now,
    required Widget today,
    HomeTodayData? data,
    bool notices = true,
  }) {
    final view = data == null
        ? null
        : homeTodayViewFor(
            state: data.today.snapshot.state,
            plan: data.today.snapshot.plan,
            originalDone: data.today.originalDone,
            canAdvance: data.canAdvance,
            examDate: data.today.snapshot.digest.examDate,
          );
    final showPerformance = view != null &&
        view.kind != HomeTodayKind.noContent &&
        view.kind != HomeTodayKind.assessment;
    if (context.wideWeb) {
      return HomeWebLayout(
        header: HomeMasthead(
          examId: widget.examId,
          now: now,
          dayNote: data == null ? null : homeDayNoteLabel(data),
          greeting: data?.extras.note == HomeDayNote.welcomeBack
              ? 'Welcome back'
              : null,
        ),
        today: today,
        intro: data != null && view?.kind == HomeTodayKind.examDay
            ? HomeExamDayIntro(
                examShortName: data.examShortName,
                reviewsTotal: data.questionCounts?.reviewsTotal ?? 0,
              )
            : null,
        notice: !notices ||
                view?.kind == HomeTodayKind.noContent ||
                view?.kind == HomeTodayKind.assessment
            ? null
            : HomeNoticeStrip(
                onDate: _openDate,
                onRoute: (route) => unawaited(context.push<void>(route)),
              ),
        performance: showPerformance
            ? const HomePerformanceSection()
            : today is HomeWebLoading
                ? const HomeWebLoading(performance: true)
                : null,
        // The plan fades in over the board shapes when it arrives.
        loadingFade: HomeWebLoadingFade(
          loading: today is HomeWebLoading,
          arrived: data != null,
        ),
        onRecord: showPerformance
            ? () => unawaited(context.push<void>('/record'))
            : null,
        onTendencies: showPerformance
            ? () => unawaited(context.push<void>('/tendencies'))
            : null,
        footer: const HomeInstallSlot(topGap: 28),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s16,
        PantasSpace.s16,
        PantasSpace.s16,
        PantasLayout.reserveTabbar,
      ),
      children: [
        HomeMasthead(
          examId: widget.examId,
          now: now,
          greeting: data?.extras.note == HomeDayNote.welcomeBack
              ? 'Welcome back'
              : null,
          notice: !notices ||
                  view?.kind == HomeTodayKind.noContent ||
                  view?.kind == HomeTodayKind.assessment
              ? null
              : HomeNoticeStrip(
                  onDate: _openDate,
                  onRoute: (route) => unawaited(context.push<void>(route)),
                ),
        ),
        // The plan fades in over the loading shapes when it arrives. Both
        // lists start at the same place, so nothing moves.
        SkeletonFade(
          loading: today is HomeTodaySkeleton,
          fade: data != null,
          skeleton: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: PantasSpace.s16),
              HomeTodaySkeleton(),
              SizedBox(height: PantasSpace.s24),
              HomePerformanceSkeleton(),
              SizedBox(height: PantasSpace.s24),
              SkeletonPulse(child: SkeletonGroup(rows: 2)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phone Home boards: the Today card starts 5 px higher. The
              // cards that stand alone (assessment, no content, exam day)
              // keep 21 px.
              SizedBox(
                height: view?.kind == HomeTodayKind.assessment ||
                        view?.kind == HomeTodayKind.noContent ||
                        view?.kind == HomeTodayKind.examDay ||
                        view?.kind == HomeTodayKind.passed
                    ? 21
                    : 17,
              ),
              today,
              if (showPerformance) ...[
                const SizedBox(height: PantasSpace.s24),
                const HomePerformanceSection(),
                const SizedBox(height: PantasSpace.s24),
                _moreAboutYou(context),
              ],
            ],
          ),
        ),
        const HomeInstallSlot(),
      ],
    );
  }

  /// The two rows under Your performance on phone.
  Widget _moreAboutYou(BuildContext context) => GroupedSection(
        header: 'More about you',
        children: [
          ListRow(
            title: 'Your record',
            divider: true,
            dividerInset: 58,
            leading: _MoreIcon(
              context.colors.accent,
              '<path d="M12 21c3.9 0 6.5-2.6 6.5-6.3 0-3.2-2.2-5.5-3.6-7.4 '
              '-.4 1.8-1.4 2.8-2.7 3.2.3-3-.7-5.7-3-7.5.4 3.6-3.7 6-3.7 '
              '11.7 0 3.7 2.6 6.3 6.5 6.3z"/>',
            ),
            onTap: () => unawaited(context.push<void>('/record')),
          ),
          ListRow(
            title: 'Your tendencies',
            leading: _MoreIcon(
              context.colors.accent,
              '<path d="M11 3.5 12.6 8.4 17.5 10 12.6 11.6 11 16.5 9.4 '
              '11.6 4.5 10l4.9-1.6z"/><path d="M18 15.5l.7 2 2 .7-2 .7-.7 '
              '2-.7-2-2-.7 2-.7z"/>',
            ),
            onTap: () => unawaited(context.push<void>('/tendencies')),
          ),
        ],
      );
}

/// Before the assessment Home shows only the week, the greeting and this card:
/// no Today, no performance, no quick quiz (D-64, HE_BeforeAssessment).
class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({required this.examId});

  final ExamId examId;

  @override
  Widget build(BuildContext context) => HomeStateCard(
        state: HomeState.assessment,
        examName: '',
        examShortName: '',
        onPrimary: () => unawaited(context.push<void>('/assessment/$examId')),
      );
}

/// Board (HP_Free, HP_Pro): a 22 px outline icon in a 30 px column.
class _MoreIcon extends StatelessWidget {
  const _MoreIcon(this.color, this.paths);
  final Color color;
  final String paths;

  @override
  Widget build(BuildContext context) {
    final hex = color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
    return ExcludeSemantics(
      child: SizedBox(
        width: PantasSpace.s28 + PantasSpace.s2,
        child: Center(
          child: SvgPicture.string(
            '<svg viewBox="0 0 24 24" fill="none" stroke="#$hex" '
            'stroke-width="2" stroke-linecap="round" '
            'stroke-linejoin="round">$paths</svg>',
            width: PantasSpace.s20 + PantasSpace.s2,
            height: PantasSpace.s20 + PantasSpace.s2,
          ),
        ),
      ),
    );
  }
}
