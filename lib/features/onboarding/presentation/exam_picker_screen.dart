import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum ExamPickerMode { onboarding, settings }

final examPickerCatalogProvider = StreamProvider<List<ExamCatalogEntry>>(
  (ref) => ExamCatalogRepository(ref.watch(contentDatabaseProvider)).watchAll(),
);

const _groups = <(String, String, String)>[
  ('College entrance', 'College', 'College entrance tests'),
  ('High school', 'High school', 'High school'),
  ('Scholarships', 'Scholarships', 'Scholarships'),
  ('Civil service', 'Civil service', 'Civil service'),
  ('Uniformed services', 'Academies', 'Academies'),
  ('Licensure', 'Licensure', 'Licensure'),
];

// Organization lines copied from O_Picker and ST_ExamPick. New catalog entries
// use their supplied name until they have an approved organization line.
const _organizations = <String, String>{
  'exam_upcat': 'University of the Philippines',
  'exam_acet': 'Ateneo de Manila University',
  'exam_dlsucet': 'De La Salle University',
  'exam_ustet': 'University of Santo Tomas',
  'exam_pupcet': 'Polytechnic University of the Philippines',
  'exam_pshs_nce': 'Philippine Science High School',
  'exam_dost_sei': 'DOST-SEI Undergraduate Scholarship',
  'exam_sm_foundation': 'SM Foundation College Scholarship',
  'exam_cse_pro': 'Civil Service Commission',
  'exam_cse_sub': 'Civil Service Commission',
  'exam_napolcom': 'National Police Commission',
  'exam_afpsat': 'Armed Forces of the Philippines',
  'exam_pma': 'Philippine Military Academy',
  'exam_pnpa': 'Philippine National Police Academy',
  'exam_pmma': 'Philippine Merchant Marine Academy',
  'exam_maap': 'Maritime Academy of Asia and the Pacific',
  'exam_let': 'Licensure Examination for Teachers',
  'exam_pnle': 'Nurse Licensure Examination',
};

class ExamPickerScreen extends ConsumerStatefulWidget {
  const ExamPickerScreen({
    required this.mode,
    required this.onPicked,
    this.onBack,
    this.onCustom,
    this.cseOnly = kIsWeb,
    super.key,
  });
  final ExamPickerMode mode;
  final FutureOr<void> Function(String) onPicked;
  final VoidCallback? onBack;
  final VoidCallback? onCustom;
  final bool cseOnly;
  bool selectable(ExamCatalogEntry entry) =>
      entry.isSelectable &&
      (!cseOnly || entry.id == 'exam_cse_pro' || entry.id == 'exam_cse_sub');
  @override
  ConsumerState<ExamPickerScreen> createState() => _ExamPickerScreenState();
}

class _ExamPickerScreenState extends ConsumerState<ExamPickerScreen> {
  String? _selectedId;
  String? _group;
  String _query = '';
  bool _saving = false;
  bool _failed = false;
  bool get _settings => widget.mode == ExamPickerMode.settings;

  void _back() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _custom() {
    if (widget.onCustom != null) {
      widget.onCustom!();
    } else {
      context.push('/onboarding/custom/name');
    }
  }

  Future<void> _save() async {
    final id = _selectedId;
    if (id == null || _saving) return;
    final telemetry = ref.read(telemetryProvider);
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      if (!_settings) {
        final prefs = ref.read(appPreferencesRepositoryProvider);
        await prefs.setCompletedOnboarding(value: false);
        await prefs.setSelectedExamId(id);
        ref.invalidate(appPreferencesRepositoryProvider);
      }
      await widget.onPicked(id);
      if (_settings && mounted) setState(() => _selectedId = null);
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _pick(ExamCatalogEntry entry, String? active) {
    if (_saving ||
        !widget.selectable(entry) ||
        (_settings && active == entry.id)) {
      return;
    }
    setState(() => _selectedId = entry.id);
    if (_settings) unawaited(_save());
  }

  Widget _section(
    BuildContext context,
    String header,
    List<ExamCatalogEntry> entries,
    String? selected,
    String? active,
  ) =>
      GroupedSection(
        header: header,
        headerStyle: context.type.sectionHeader.copyWith(
          fontWeight: _settings ? FontWeight.w600 : FontWeight.w500,
        ),
        children: [
          for (final (index, entry) in entries.indexed) ...[
            ListRow.exam(
              key: ValueKey('exam-${entry.id}'),
              title: entry.shortName,
              subtitle: _organizations[entry.id] ?? entry.name,
              selected: selected == entry.id,
              comingSoon: !widget.selectable(entry),
              settingsMode: _settings,
              divider: index + 1 < entries.length,
              onTap: () => _pick(entry, active),
            ),
            if (_failed && _settings && _selectedId == entry.id)
              saveFailureLine(_save),
          ],
        ],
      );

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(examPickerCatalogProvider);
    final active = _settings
        ? ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id
        : null;
    final selected = _selectedId ?? active;
    final custom = GroupedSection(
      children: [
        ListRow(
          title: "My exam isn't listed",
          titleColor: context.colors.accent,
          subtitle:
              _settings ? null : 'Set up your own and pick what it covers',
          onTap: _saving ? null : _custom,
        ),
      ],
    );
    final children = <Widget>[
      SearchField(
        hint: 'Search exams',
        onChanged: (value) =>
            setState(() => _query = value.trim().toLowerCase()),
      ),
      SizedBox(height: _settings ? 22 : 12),
      if (!_settings) ...[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              PantasButton.filterChip(
                label: 'All',
                selected: _group == null,
                onPressed: () => setState(() => _group = null),
              ),
              for (final group in _groups) ...[
                const SizedBox(width: 8),
                PantasButton.filterChip(
                  label: group.$2,
                  selected: _group == group.$1,
                  onPressed: () => setState(() => _group = group.$1),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
      custom,
      const SizedBox(height: 24),
      catalog.when(
        loading: () => loadingFor(catalog),
        error: (error, _) => errorFor(
          'exams',
          () => ref.invalidate(examPickerCatalogProvider),
          error: error,
        ),
        data: (all) {
          if (all.isEmpty) {
            return StateView(
              message: 'No exams available right now.',
              detail: 'Check back soon, or set up your own exam.',
              actionLabel: 'Set Up My Own Exam',
              primaryAction: true,
              onRetry: _custom,
            );
          }
          final visible = all
              .where(
                (entry) =>
                    (_group == null || entry.group == _group) &&
                    '${entry.name} ${entry.shortName} '
                            '${_organizations[entry.id] ?? ''}'
                        .toLowerCase()
                        .contains(_query),
              )
              .toList();
          return Semantics(
            liveRegion: true,
            value: '${visible.length} exams',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final group in _groups)
                  if (visible.any((entry) => entry.group == group.$1)) ...[
                    _section(
                      context,
                      group.$3,
                      visible
                          .where((entry) => entry.group == group.$1)
                          .toList(),
                      selected,
                      active,
                    ),
                    const SizedBox(height: 24),
                  ],
              ],
            ),
          );
        },
      ),
    ];
    final page = _settings
        ? PantasPage.settingsPicker(onBack: _back, children: children)
        : PantasPage.onboarding(
            title: 'Which exam are you taking?',
            detail: 'You can change this later in Settings.',
            progress: 3,
            bodyGap: 24,
            detailLineHeight: 1.35,
            onBack: _back,
            bottom: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_failed) saveFailureLine(_save),
                PantasButton(
                  label: 'Continue',
                  busy: _saving,
                  onPressed: _selectedId == null || _saving ? null : _save,
                ),
              ],
            ),
            children: children,
          );
    return PopScope<void>(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && widget.onBack != null) _back();
      },
      child: page,
    );
  }
}
