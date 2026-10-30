import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_skeletons.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

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

  List<ExamCatalogEntry> _orderedEntries(List<ExamCatalogEntry> entries) => [
        ...entries.where(widget.selectable),
        ...entries.where((entry) => !widget.selectable(entry)),
      ];

  List<(String, String, String)> _orderedGroups(
    List<ExamCatalogEntry> entries,
  ) {
    bool available((String, String, String) group) => entries.any(
          (entry) => entry.group == group.$1 && widget.selectable(entry),
        );
    return [
      ..._groups.where(available),
      ..._groups.where((group) => !available(group)),
    ];
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
    firstScreenReady(context, ref, ready: !catalog.isLoading);
    final active = _settings
        ? ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id
        : null;
    final selected = _selectedId ?? active;
    if (!_settings && context.wideWeb) {
      final t = context.webTokens;
      return OnboardingShortcuts(
        bindings: {
          if (_selectedId != null && !_saving)
            const SingleActivator(LogicalKeyboardKey.enter): _save,
        },
        child: Stack(
          children: [
            OnboardingWebPage(
              title: 'Which exam are you taking?',
              detail: 'You can change this later in Settings.',
              progress: 3,
              width: 820,
              onBack: _back,
              children: [
                catalog.when(
                  loading: () => const ExamPickerWebSkeleton(),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Column(
                      children: [
                        Text(
                          'Could not load exams.',
                          style: t.style(17, color: t.colors.secondaryLabel),
                        ),
                        const SizedBox(height: 16),
                        WebButton(
                          label: 'Retry',
                          variant: WebButtonVariant.secondary,
                          onPressed: () =>
                              ref.invalidate(examPickerCatalogProvider),
                        ),
                      ],
                    ),
                  ),
                  data: (catalogEntries) {
                    final all = _orderedEntries(catalogEntries);
                    if (all.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          children: [
                            Text(
                              'No exams available right now.',
                              style: t.style(20, weight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Check back soon, or set up your own exam.',
                              style: t.sub,
                            ),
                            const SizedBox(height: 20),
                            WebButton(
                              label: 'Set Up My Own Exam',
                              onPressed: _saving ? null : _custom,
                            ),
                          ],
                        ),
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SearchField(
                          outlined: true,
                          hint: 'Search exams',
                          onChanged: (value) => setState(
                            () => _query = value.trim().toLowerCase(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final group in [
                              (null, 'All'),
                              ..._groups.map((g) => (g.$1, g.$2)),
                            ])
                              TextButton(
                                onPressed: () =>
                                    setState(() => _group = group.$1),
                                style: TextButton.styleFrom(
                                  backgroundColor: _group == group.$1
                                      ? t.colors.label
                                      : t.colors.surface,
                                  foregroundColor: _group == group.$1
                                      ? t.colors.surface
                                      : t.colors.label,
                                  textStyle: t.style(
                                    14,
                                    weight: _group == group.$1
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                  shape: const StadiumBorder(),
                                  minimumSize: const Size(0, 34),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                ),
                                child: Text(group.$2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        WebCard(
                          child: WebRow(
                            title: "My exam isn't listed",
                            subtitle: 'Set up your own and pick what it covers',
                            titleColor: t.colors.label,
                            leading: SvgPicture.string(
                              '<svg viewBox="0 0 24 24" fill="none" '
                              'stroke="currentColor" stroke-width="1.9" '
                              'stroke-linecap="round"> '
                              '<circle cx="12" cy="12" r="8.5"/> '
                              '<path d="M12 8.5v7M8.5 12h7"/></svg>',
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                t.colors.accent,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: _saving ? null : _custom,
                            trailing: const Icon(Icons.chevron_right),
                            divider: false,
                          ),
                        ),
                        const SizedBox(height: 24),
                        for (final group in _orderedGroups(visible))
                          if (visible
                              .any((entry) => entry.group == group.$1)) ...[
                            Text(group.$3.toUpperCase(), style: t.eb),
                            const SizedBox(height: 8),
                            LayoutBuilder(
                              builder: (context, constraints) => Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final entry in visible.where(
                                    (entry) => entry.group == group.$1,
                                  ))
                                    SizedBox(
                                      width: (constraints.maxWidth - 20) / 3,
                                      child: WebCard(
                                        radius: 14,
                                        child: RadioRow(
                                          key: ValueKey('exam-${entry.id}'),
                                          title: entry.shortName,
                                          selected: selected == entry.id,
                                          onTap: _saving ||
                                                  !widget.selectable(entry)
                                              ? null
                                              : () => _pick(entry, active),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          content: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.shortName,
                                                style: t.style(
                                                  16,
                                                  weight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                _organizations[entry.id] ??
                                                    entry.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: t.sm,
                                              ),
                                            ],
                                          ),
                                          trailing: !widget.selectable(entry)
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 14,
                                                  ),
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          t.disabledBackground,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        99,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 7,
                                                        vertical: 2,
                                                      ),
                                                      child: Text(
                                                        'Coming soon',
                                                        style: t.style(
                                                          11,
                                                          weight:
                                                              FontWeight.w600,
                                                          color: t.colors
                                                              .secondaryLabel,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                      ],
                    );
                  },
                ),
                if (_failed) saveFailureLine(_save),
                const SizedBox(height: 100),
              ],
            ),
            if (!(catalog.hasValue && catalog.requireValue.isEmpty))
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 84,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: t.colors.surface,
                    border: Border(
                      top: BorderSide(color: t.colors.separator, width: .5),
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 1084,
                      child: Row(
                        children: [
                          if (selected != null)
                            Expanded(
                              child: Text(
                                (catalog.valueOrNull ?? [])
                                    .where((e) => e.id == selected)
                                    .map(
                                      (e) => '${e.shortName} · '
                                          '${_organizations[e.id] ?? e.name}',
                                    )
                                    .join(),
                                style: t.sub,
                              ),
                            )
                          else
                            const Spacer(),
                          OnboardingButton(
                            label: 'Continue',
                            busy: _saving,
                            onPressed:
                                _selectedId == null || _saving ? null : _save,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
    if (_settings && context.wideWeb) {
      final t = context.webTokens;
      return OnboardingShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _back,
        },
        child: Focus(
          autofocus: true,
          child: Material(
            color: t.colors.surface,
            borderRadius: BorderRadius.circular(22),
            clipBehavior: Clip.antiAlias,
            child: Column(
              key: const ValueKey('settings-picker-content'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  child: Row(
                    children: [
                      Expanded(child: Text('Exam', style: t.h3)),
                      const WebKeyHint('Esc'),
                      IconButton(
                        onPressed: _saving ? null : _back,
                        tooltip: 'Close',
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: SearchField(
                    hint: 'Search exams',
                    onChanged: (value) =>
                        setState(() => _query = value.trim().toLowerCase()),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: catalog.when(
                      loading: () => const SkeletonGroups(
                        rowHeight: 66,
                        headerWidth: 110,
                      ),
                      error: (error, _) => errorFor(
                        'exams',
                        () => ref.invalidate(examPickerCatalogProvider),
                        error: error,
                      ),
                      data: (catalogEntries) {
                        final all = _orderedEntries(catalogEntries);
                        final visible = all
                            .where(
                              (entry) => '${entry.name} ${entry.shortName} '
                                      '${_organizations[entry.id] ?? ''}'
                                  .toLowerCase()
                                  .contains(_query),
                            )
                            .toList();
                        if (all.isEmpty) {
                          return StateView(
                            message: 'No exams available right now.',
                            detail: 'Check back soon, or set up your own exam.',
                            actionLabel: 'Set Up My Own Exam',
                            onRetry: _custom,
                          );
                        }
                        return LayoutBuilder(
                          builder: (context, constraints) => Wrap(
                            spacing: 8,
                            runSpacing: 14,
                            children: [
                              for (final group in _orderedGroups(visible))
                                if (visible.any(
                                  (entry) => entry.group == group.$1,
                                ))
                                  SizedBox(
                                    width: (constraints.maxWidth - 8) / 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            12,
                                            0,
                                            12,
                                            4,
                                          ),
                                          child: Text(
                                            group.$3.toUpperCase(),
                                            style: t.eb,
                                          ),
                                        ),
                                        for (final entry in visible.where(
                                          (entry) => entry.group == group.$1,
                                        ))
                                          RadioRow(
                                            key: ValueKey('exam-${entry.id}'),
                                            title: entry.shortName,
                                            selected: selected == entry.id,
                                            onTap: _saving ||
                                                    !widget.selectable(entry)
                                                ? null
                                                : () => _pick(entry, active),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            content: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  entry.shortName,
                                                  style: t.style(
                                                    16,
                                                    weight: selected == entry.id
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  _organizations[entry.id] ??
                                                      entry.name,
                                                  style: t.sm,
                                                ),
                                              ],
                                            ),
                                            trailing: !widget.selectable(entry)
                                                ? Text(
                                                    'Coming soon',
                                                    style: t.sm,
                                                  )
                                                : null,
                                          ),
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_saving)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: WebButton(label: 'Rebuilding your plan', busy: true),
                  ),
                if (_failed) saveFailureLine(_save),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      WebButton(
                        label: "My exam isn't listed",
                        variant: WebButtonVariant.tertiary,
                        onPressed: _saving ? null : _custom,
                      ),
                      SizedBox(
                        width: 380,
                        child: Text(
                          "Exams not out yet are gray and can't be picked.",
                          textAlign: TextAlign.right,
                          style: t.sm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
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
        loading: () => const SkeletonGroups(
          rowHeight: 66,
          headerWidth: 110,
        ),
        error: (error, _) => errorFor(
          'exams',
          () => ref.invalidate(examPickerCatalogProvider),
          error: error,
        ),
        data: (catalogEntries) {
          final all = _orderedEntries(catalogEntries);
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
                for (final group in _orderedGroups(visible))
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
