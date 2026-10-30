// lib/features/home/presentation/home_tab.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/home/domain/home_today_view.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_date_sheet.dart';
import 'package:pantas/features/home/presentation/widgets/home_install_slot.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';
import 'package:pantas/features/home/presentation/widgets/home_notice_strip.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_section.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFocus = ref.watch(activeExamFocusProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncFocus.when(
          loading: () => loadingFor(asyncFocus),
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
    final now = DateTime.now();
    Widget todayScreen() => HomeTodayScreen(
          key: ValueKey('today-$examId-${settings?.examDate?.storageValue}'),
          examId: examId,
          onSetDate: () => _openDate(HomeNoticeKind.noDate),
          pageBuilder: (today, data) =>
              _list(context, now: now, today: today, data: data),
        );
    Widget nativeHome() {
      final result = ref.watch(assessmentResultProvider(examId));
      return result.when(
        loading: () => loadingFor(result),
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
      child: HomeExamDateSheet(
        today: now,
        initial:
            _dateSheet == HomeNoticeKind.monthOnly ? settings?.examDate : null,
        requireDay: _dateSheet == HomeNoticeKind.monthOnly,
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
            : data == null
                ? const HomeWebLoading(performance: true)
                : null,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
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
        const SizedBox(height: 22),
        today,
        if (showPerformance) ...[
          const SizedBox(height: 22),
          const HomePerformanceSection(),
          const SizedBox(height: 24),
          GroupedSection(
            header: 'More about you',
            children: [
              ListRow(
                title: 'Your record',
                divider: true,
                onTap: () => unawaited(context.push<void>('/record')),
              ),
              ListRow(
                title: 'Your tendencies',
                onTap: () => unawaited(context.push<void>('/tendencies')),
              ),
            ],
          ),
        ],
        const HomeInstallSlot(),
      ],
    );
  }
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
