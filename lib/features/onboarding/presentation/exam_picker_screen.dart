import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/content/remote/content_limit.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/search_field.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/motion/view_swap.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_skeletons.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_web_page.dart';

enum ExamPickerMode { onboarding, settings }

/// Custom exams do not run on web yet, so the picker hides "My exam isn't
/// listed" and "Set Up My Own Exam" there until they ship (Aedwon, Nov 4,
/// for the beta). Set this to true and every one of those places returns.
const kCustomExamsOnWeb = false;

/// Whether the picker offers a student's own exam on this platform.
const kCustomExamsOffered = !kIsWeb || kCustomExamsOnWeb;

final examPickerCatalogProvider = StreamProvider<List<ExamCatalogEntry>>(
  (ref) => ExamCatalogRepository(ref.watch(contentDatabaseProvider)).watchAll(),
);

/// One of the student's own exams in "Your exams".
@immutable
class _YourExam {
  const _YourExam({required this.examId, required this.name, this.server});
  final String examId;
  final String name;

  /// Set for an exam this device does not hold yet, which the server listed.
  /// Picking it brings it here first.
  final CustomTrackRow? server;
}

/// The own exams this device holds, newest first.
final _localCustomTracksProvider =
    FutureProvider.autoDispose<List<_YourExam>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.select(db.customTrackMetaLocal).get();
  return [
    for (final row in rows.reversed)
      _YourExam(examId: row.examId, name: row.name),
  ];
});

/// The own exams the server holds for this account. Read only on the web,
/// where another browser or a phone may have made them. A read that fails
/// leaves the local list alone and is recorded without any exam name.
final _serverCustomTracksProvider =
    FutureProvider.autoDispose<List<CustomTrackRow>>((ref) async {
  if (!ref.read(studyUsesServerProvider)) return const [];
  final telemetry = ref.read(telemetryProvider);
  try {
    final auth = await ref.watch(authStateProvider.future);
    final uid = switch (auth) {
      SignedInAuthState(:final user) => user.uid,
      AnonymousAuthState(:final uid) => uid,
      _ => null,
    };
    if (uid == null) return const [];
    final reply = await ref
        .read(studyApiProvider)
        .requestAccount('getCustomTracks', expectedUid: uid);
    final tracks = reply['tracks'];
    if (tracks is! List) throw const FormatException('Bad tracks');
    return [for (final track in tracks) CustomTrackRow.fromJson(track)];
  } on Object catch (error, stack) {
    unawaited(telemetry.recordError(error, stack));
    return const [];
  }
});

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
    this.customExams = kCustomExamsOffered,
    super.key,
  });
  final ExamPickerMode mode;
  final FutureOr<void> Function(String) onPicked;
  final VoidCallback? onBack;
  final VoidCallback? onCustom;
  final bool cseOnly;

  /// Whether to offer "My exam isn't listed" and "Set Up My Own Exam".
  final bool customExams;
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
  String _typed = '';
  bool _saving = false;
  bool _failed = false;

  /// The server's copy of the own exam picked last, when this device does not
  /// hold it yet. Saving brings it here first.
  CustomTrackRow? _restoring;
  bool get _settings => widget.mode == ExamPickerMode.settings;

  @override
  void initState() {
    super.initState();
    if (!_settings) unawaited(_restorePick());
  }

  /// Back from the date step returns here. The pick was saved when the student
  /// moved on, so show it chosen again instead of an empty list (4P-15). A
  /// saved id that is not a selectable catalog exam is not shown as picked,
  /// unless it is one of the student's own exams, which show under "Your
  /// exams".
  Future<void> _restorePick() async {
    try {
      final saved =
          await ref.read(appPreferencesRepositoryProvider).selectedExamId();
      if (saved == null) return;
      final entries = await ref.read(examPickerCatalogProvider.future);
      if (!mounted || _selectedId != null) return;
      if (entries.any((e) => e.id == saved && widget.selectable(e))) {
        setState(() => _selectedId = saved);
        return;
      }
      if (!widget.customExams || !isCustomExamId(saved)) return;
      final mine = await ref.read(_localCustomTracksProvider.future);
      if (mounted &&
          _selectedId == null &&
          mine.any((e) => e.examId == saved)) {
        setState(() => _selectedId = saved);
      }
    } on Object catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
    }
  }

  /// With no exam content on the device, the daily limit is why every exam
  /// reads "Coming soon", so say that instead.
  bool _limitBlocks(List<ExamCatalogEntry> entries) =>
      ref.watch(contentLimitReachedProvider) &&
      !entries.any((entry) => entry.hasContent);

  void _search(String value) => setState(() {
        _typed = value.trim();
        _query = _typed.toLowerCase();
      });

  /// What a search that finds no exam says, worded as the Study search is.
  Widget _noMatch(BuildContext context) {
    final wide = context.wideWeb;
    final t = context.webTokens;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
        child: Column(
          children: [
            Text(
              'Nothing matched “$_typed”',
              textAlign: TextAlign.center,
              style: wide
                  ? t.style(17, weight: FontWeight.w600, height: 22 / 17)
                  : context.type.emphasized,
            ),
            const SizedBox(height: 12),
            Text(
              'Try a shorter word, or part of one.',
              textAlign: TextAlign.center,
              style: wide
                  ? t.sub
                  : context.type.subhead
                      .copyWith(color: context.colors.secondaryLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _back() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  /// "My exam isn't listed". Onboarding makes the exam in its own steps. From
  /// Settings the student has finished onboarding, which they cannot reopen,
  /// so the steps are Settings pages. They come back with the new exam's id,
  /// and it is saved as any pick is.
  Future<void> _custom() async {
    if (widget.onCustom != null) {
      widget.onCustom!();
    } else if (!_settings) {
      unawaited(context.push('/onboarding/custom/name'));
    } else {
      final made = await context.push<String>('/settings/exam/custom/name');
      if (made == null || !mounted) return;
      ref.invalidate(_localCustomTracksProvider);
      setState(() => _selectedId = made);
      await _save();
    }
  }

  /// Brings an own exam this device does not hold yet from the server, and
  /// lets everything that listed exams know it exists.
  Future<void> _restoreTrack(CustomTrackRow row) async {
    await ref.read(customTrackRepositoryProvider).restoreFromServer(row);
    ref
      ..invalidate(_localCustomTracksProvider)
      ..invalidate(examListProvider)
      ..invalidate(activeExamFocusProvider)
      ..invalidate(scopedTopicsProvider)
      ..invalidate(scopedSubjectsProvider);
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
      final restore = _restoring;
      if (restore != null && restore.examId == id) {
        await _restoreTrack(restore);
        _restoring = null;
      }
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

  /// "Your own exam", the small line under each own exam.
  static const _ownExam = 'Your own exam';

  /// "Your exams" on a phone, in both modes. The add row is the last row of
  /// the group, and is the one place to make an exam of one's own.
  Widget _phoneYours(
    BuildContext context,
    List<_YourExam> yours,
    String? selected,
    String? active,
  ) =>
      GroupedSection(
        header: 'Your exams',
        headerStyle: context.type.sectionHeader.copyWith(
          fontWeight: _settings ? FontWeight.w600 : FontWeight.w500,
        ),
        children: [
          for (final (index, exam) in yours.indexed) ...[
            ListRow.exam(
              key: ValueKey('exam-${exam.examId}'),
              title: exam.name,
              subtitle: _ownExam,
              selected: selected == exam.examId,
              settingsMode: _settings,
              // In Settings the add row draws the line above itself, inset.
              divider: !_settings || index < yours.length - 1,
              onTap: () => _pickCustom(exam, active),
            ),
            if (_failed && _settings && _selectedId == exam.examId)
              saveFailureLine(_save),
          ],
          // Phone Settings (SettingsPh, kind pick, v B): no plus, a chevron at
          // the right, the name in the accent color. Onboarding keeps the plus.
          if (_settings && yours.isNotEmpty)
            Divider(
              key: const ValueKey('custom-exam-add-divider'),
              height: .5,
              thickness: .5,
              indent: 16,
              color: context.colors.separator,
            ),
          ListRow(
            key: const ValueKey('custom-exam-add'),
            title: "My exam isn't listed",
            titleColor: context.colors.accent,
            variant:
                _settings ? ListRowVariant.navigation : ListRowVariant.value,
            leading: _settings
                ? null
                : _AddExamIcon(color: context.colors.accent, size: 24),
            contentPadding: _settings
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                : null,
            onTap: _saving ? null : _custom,
          ),
        ],
      );

  /// "Your exams" over the wide Settings dialog: two columns, like the lists
  /// below it.
  Widget _settingsYours(
    WebTokens t,
    List<_YourExam> yours,
    String? selected,
    String? active,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Text('YOUR EXAMS', style: t.eb),
            ),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 8,
                children: [
                  for (final exam in yours)
                    SizedBox(
                      width: (constraints.maxWidth - 8) / 2,
                      child: _settingsRow(
                        t,
                        key: ValueKey('exam-${exam.examId}'),
                        title: exam.name,
                        subtitle: _ownExam,
                        enabled: true,
                        chosen: selected == exam.examId,
                        onTap: _saving ? null : () => _pickCustom(exam, active),
                      ),
                    ),
                  SizedBox(
                    width: (constraints.maxWidth - 8) / 2,
                    child: _settingsRow(
                      t,
                      key: const ValueKey('custom-exam-add'),
                      title: "My exam isn't listed",
                      subtitle: null,
                      enabled: true,
                      chosen: false,
                      accentTitle: true,
                      leading: _AddExamIcon(color: t.colors.accent, size: 20),
                      onTap: _saving ? null : _custom,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  /// The add row of "Your exams" on the wide onboarding picker.
  Widget _webAddRow(WebTokens t) => PressScale(
        enabled: !_saving,
        child: WebCard(
          radius: 14,
          minHeight: 64,
          child: WebRow(
            key: const ValueKey('custom-exam-add'),
            title: "My exam isn't listed",
            titleStyle: t.style(
              16,
              weight: FontWeight.w600,
              color: t.colors.accent,
            ),
            horizontalPadding: 16,
            verticalPadding: 11,
            leadingGap: 10,
            leading: _AddExamIcon(color: t.colors.accent, size: 20),
            onPressed: _saving ? null : _custom,
            divider: false,
          ),
        ),
      );

  void _pickCustom(_YourExam exam, String? active) {
    if (_saving || (_settings && active == exam.examId)) return;
    setState(() {
      _selectedId = exam.examId;
      _restoring = exam.server;
    });
    if (_settings) unawaited(_save());
  }

  /// Own exams to show: this device's, then the server's that it lacks. The
  /// server lists one with no name, which cannot be shown, so that one is
  /// left out. Typing in the search narrows them as it does the listed exams.
  /// Null while the device's own list is still being read.
  List<_YourExam>? _yourExams() {
    if (!widget.customExams) return null;
    final local = ref.watch(_localCustomTracksProvider);
    if (local.isLoading && !local.hasValue) return null;
    final mine = local.valueOrNull ?? const <_YourExam>[];
    final held = {for (final row in mine) row.examId};
    final server = ref.watch(_serverCustomTracksProvider).valueOrNull ??
        const <CustomTrackRow>[];
    return [
      ...mine,
      for (final row in server)
        if (!held.contains(row.examId) &&
            (row.name?.trim().isNotEmpty ?? false))
          _YourExam(examId: row.examId, name: row.name!.trim(), server: row),
    ].where((row) => row.name.toLowerCase().contains(_query)).toList();
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

  /// One exam row of the board's Settings picker (`.row.c`): 55 px, title over
  /// the organization, a tint and a check when chosen, a pill when not out yet.
  Widget _settingsExamRow(
    WebTokens t,
    ExamCatalogEntry entry, {
    required bool chosen,
    required VoidCallback? onTap,
  }) =>
      _settingsRow(
        t,
        key: ValueKey('exam-${entry.id}'),
        title: entry.shortName,
        subtitle: _organizations[entry.id] ?? entry.name,
        enabled: widget.selectable(entry),
        chosen: chosen,
        onTap: onTap,
      );

  /// The row itself. An own exam's row has its own small line, and the add row
  /// has none, a plus in front and its label in the accent color.
  Widget _settingsRow(
    WebTokens t, {
    required Key key,
    required String title,
    required String? subtitle,
    required bool enabled,
    required bool chosen,
    required VoidCallback? onTap,
    Widget? leading,
    bool accentTitle = false,
  }) {
    return Opacity(
      opacity: enabled ? 1 : .45,
      child: Semantics(
        inMutuallyExclusiveGroup: leading == null,
        selected: chosen,
        // The chosen tint fades 160 ms on the ease (item 17, demo 4) and the
        // label keeps one weight. It is a layer behind: Material does not
        // animate a button's own fill.
        child: FadingColor(
          color: chosen
              ? t.colors.accentTint
              : t.colors.accentTint.withValues(alpha: 0),
          builder: (context, fill, child) => DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
          child: TextButton(
            key: key,
            onPressed: onTap,
            style: ButtonStyle(
              minimumSize:
                  const WidgetStatePropertyAll(Size(double.infinity, 55)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.standard,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              backgroundColor: WidgetStateProperty.resolveWith(
                (s) => !chosen && s.contains(WidgetState.hovered) && enabled
                    ? t.rowHover
                    : Colors.transparent,
              ),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading, const SizedBox(width: 8)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: accentTitle
                            ? t.style(
                                16,
                                weight: FontWeight.w600,
                                height: 1.3,
                                color: t.colors.accent,
                              )
                            : t.style(16, height: 1.3),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: t.style(
                            14,
                            height: 1.3,
                            color: t.colors.secondaryLabel,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!enabled)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.disabledBackground,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      child: Text(
                        'Coming soon',
                        style: t.style(
                          12,
                          weight: FontWeight.w600,
                          color: t.colors.secondaryLabel,
                        ),
                      ),
                    ),
                  )
                else if (chosen)
                  Icon(PantasIcons.check, size: 16, color: t.colors.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// One exam row of the onboarding picker: the shared selection row in a
  /// card that shows the picked state. Long names wrap instead of clipping.
  Widget _webExamRow(
    WebTokens t,
    ExamCatalogEntry entry,
    bool chosen,
    String? active,
  ) =>
      _webRow(
        t,
        key: ValueKey('exam-${entry.id}'),
        title: entry.shortName,
        subtitle: _organizations[entry.id] ?? entry.name,
        enabled: widget.selectable(entry),
        chosen: chosen,
        onTap: () => _pick(entry, active),
      );

  /// The card itself. An own exam's card is picked the same way, and shows the
  /// board's check disc when it is.
  Widget _webRow(
    WebTokens t, {
    required Key key,
    required String title,
    required String subtitle,
    required bool enabled,
    required bool chosen,
    required VoidCallback onTap,
    bool disc = false,
  }) {
    return PressScale(
      enabled: !_saving && enabled,
      child: WebCard(
        radius: 14,
        minHeight: 64,
        selected: chosen,
        child: RadioRow(
          key: key,
          title: title,
          showMark: false,
          selected: chosen,
          onTap: _saving || !enabled ? null : onTap,
          padding: const EdgeInsets.fromLTRB(16, 11, 14, 11),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.style(16, weight: FontWeight.w600),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.sm,
              ),
            ],
          ),
          trailing: disc
              ? chosen
                  ? const Padding(
                      padding: EdgeInsets.only(right: 14),
                      child: _PickedDisc(),
                    )
                  : null
              : enabled
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: t.disabledBackground,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          child: Text(
                            'Coming soon',
                            style: t.style(
                              11,
                              weight: FontWeight.w600,
                              color: t.colors.secondaryLabel,
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(examPickerCatalogProvider);
    firstScreenReady(context, ref, ready: !catalog.isLoading);
    final active = _settings
        ? ref.watch(activeExamFocusProvider).valueOrNull?.exam?.id
        : null;
    final selected = _selectedId ?? active;
    final yours = _yourExams();
    if (!_settings && context.wideWeb) {
      final t = context.webTokens;
      final emptyCatalog = catalog.hasValue && catalog.requireValue.isEmpty;
      // Aedwon overrode board OB_Picker on Nov 2, 2026: the picker keeps the
      // same 580 column as every other step. Exams are one column of rows and
      // Continue sits inline, right aligned, like the other steps.
      return OnboardingWebPage(
        title: 'Which exam are you taking?',
        detail: 'You can change this later in Settings.',
        progress: 3,
        gap: 24,
        onBack: _back,
        bottom: emptyCatalog
            ? null
            : OnboardingActions(
                children: [
                  if (_failed) saveFailureLine(_save),
                  OnboardingButton(
                    label: 'Continue',
                    busy: _saving,
                    onPressed: _selectedId == null || _saving ? null : _save,
                  ),
                ],
              ),
        children: [
          catalog.when(
            loading: () =>
                ExamPickerWebSkeleton(customCard: widget.customExams),
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
                    onPressed: () => ref.invalidate(examPickerCatalogProvider),
                  ),
                ],
              ),
            ),
            data: (catalogEntries) {
              if (_limitBlocks(catalogEntries)) {
                return const StateView(message: contentLimitMessage);
              }
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
                        widget.customExams
                            ? 'Check back soon, or set up your own exam.'
                            : 'Check back soon.',
                        style: t.sub,
                      ),
                      if (widget.customExams) ...[
                        const SizedBox(height: 20),
                        WebButton(
                          label: 'Set Up My Own Exam',
                          onPressed: _saving ? null : _custom,
                        ),
                      ],
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
                    onChanged: _search,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final group in [
                        (null, 'All'),
                        ..._orderedGroups(all).map((g) => (g.$1, g.$2)),
                      ])
                        _WideGroupChip(
                          label: group.$2,
                          selected: _group == group.$1,
                          onPressed: () => setState(() => _group = group.$1),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (yours != null) ...[
                    Text('YOUR EXAMS', style: t.eb),
                    const SizedBox(height: 8),
                    for (final exam in yours) ...[
                      _webRow(
                        t,
                        key: ValueKey('exam-${exam.examId}'),
                        title: exam.name,
                        subtitle: _ownExam,
                        enabled: true,
                        chosen: selected == exam.examId,
                        disc: true,
                        onTap: () => _pickCustom(exam, active),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _webAddRow(t),
                    const SizedBox(height: 24),
                  ],
                  // Picking a chip swaps the list with the approved view
                  // swap. Typing in the search changes the same view.
                  ViewSwap(
                    index: _groups.indexWhere((g) => g.$1 == _group) + 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (visible.isEmpty &&
                            _query.isNotEmpty &&
                            (yours?.isEmpty ?? true))
                          _noMatch(context),
                        for (final group in _orderedGroups(visible))
                          if (visible
                              .any((entry) => entry.group == group.$1)) ...[
                            Text(group.$3.toUpperCase(), style: t.eb),
                            const SizedBox(height: 8),
                            for (final (index, entry) in visible
                                .where((entry) => entry.group == group.$1)
                                .indexed) ...[
                              if (index > 0) const SizedBox(height: 10),
                              _webExamRow(
                                t,
                                entry,
                                selected == entry.id,
                                active,
                              ),
                            ],
                            const SizedBox(height: 24),
                          ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      );
    }
    if (_settings && context.wideWeb) {
      final t = context.webTokens;
      return OnboardingShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): _back,
        },
        child: KeyFocusKeeper(
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
                        color: t.colors.secondaryLabel,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: SearchField(
                    outlined: true,
                    hint: 'Search exams',
                    onChanged: _search,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (yours != null)
                          _settingsYours(t, yours, selected, active),
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
                            if (_limitBlocks(catalogEntries)) {
                              return const StateView(
                                message: contentLimitMessage,
                              );
                            }
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
                              return widget.customExams
                                  ? StateView(
                                      message: 'No exams available right now.',
                                      detail: 'Check back soon, or set up '
                                          'your own exam.',
                                      actionLabel: 'Set Up My Own Exam',
                                      onRetry: _custom,
                                    )
                                  : const StateView(
                                      message: 'No exams available right now.',
                                      detail: 'Check back soon.',
                                    );
                            }
                            if (visible.isEmpty &&
                                _query.isNotEmpty &&
                                (yours?.isEmpty ?? true)) {
                              return _noMatch(context);
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
                                              padding:
                                                  const EdgeInsets.fromLTRB(
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
                                              (entry) =>
                                                  entry.group == group.$1,
                                            ))
                                              _settingsExamRow(
                                                t,
                                                entry,
                                                chosen: selected == entry.id,
                                                onTap: _saving ||
                                                        !widget
                                                            .selectable(entry)
                                                    ? null
                                                    : () =>
                                                        _pick(entry, active),
                                              ),
                                          ],
                                        ),
                                      ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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
                    alignment: WrapAlignment.end,
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
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
    final children = <Widget>[
      SearchField(
        hint: 'Search exams',
        onChanged: _search,
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
              for (final group
                  in _orderedGroups(catalog.valueOrNull ?? const [])) ...[
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
      if (yours != null) ...[
        _phoneYours(context, yours, selected, active),
        const SizedBox(height: 24),
      ],
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
          if (_limitBlocks(catalogEntries)) {
            return const StateView(message: contentLimitMessage);
          }
          final all = _orderedEntries(catalogEntries);
          if (all.isEmpty) {
            return widget.customExams
                ? StateView(
                    message: 'No exams available right now.',
                    detail: 'Check back soon, or set up your own exam.',
                    actionLabel: 'Set Up My Own Exam',
                    primaryAction: true,
                    onRetry: _custom,
                  )
                : const StateView(
                    message: 'No exams available right now.',
                    detail: 'Check back soon.',
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
                if (visible.isEmpty &&
                    _query.isNotEmpty &&
                    (yours?.isEmpty ?? true))
                  _noMatch(context),
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
            pinBottom: true,
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

/// The plus of the add row, drawn in the accent color.
class _AddExamIcon extends StatelessWidget {
  const _AddExamIcon({required this.color, required this.size});
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SvgPicture.string(
          '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" '
          'stroke-width="1.8" stroke-linecap="round"> '
          '<circle cx="12" cy="12" r="9.5"/> '
          '<path d="M12 8v8M8 12h8"/></svg>',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );
}

/// The board's check disc on a picked own exam of the wide onboarding picker.
class _PickedDisc extends StatelessWidget {
  const _PickedDisc();
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.accentFill,
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(
          dimension: 22,
          child: Icon(PantasIcons.check, size: 13, color: t.colors.onAccent),
        ),
      ),
    );
  }
}

/// A filter chip label that always takes the width of its heaviest (selected)
/// weight, so no chip moves or wraps when another is picked.
/// A group chip on the wide picker. It keeps its wide look and takes the
/// phone chip's motion (item 17, demo 5): the fill and label fade over 160 ms
/// on the ease, and a press shrinks it to 96%.
class _WideGroupChip extends StatelessWidget {
  const _WideGroupChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final fill = selected ? t.colors.label : t.colors.surface;
    final ink = selected ? t.colors.surface : t.colors.label;
    // Material does not animate a button's own fill, so the chip paints it
    // behind a transparent button.
    return PressScale(
      scale: .96,
      child: FadingColor(
        color: fill,
        builder: (context, fill, child) => DecoratedBox(
          key: const ValueKey('wide-chip-fill'),
          decoration: ShapeDecoration(
            color: fill,
            shape: const StadiumBorder(),
          ),
          child: child,
        ),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: ink,
            textStyle: t.style(
              14,
              weight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
            shape: const StadiumBorder(),
            minimumSize: const Size(0, 34),
            // The fill is painted around the button, so no hit padding.
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: FadingColor(
            color: ink,
            builder: (context, color, child) => DefaultTextStyle.merge(
              style: TextStyle(color: color),
              child: child!,
            ),
            child: _ChipLabel(
              label: label,
              style: t.style(14, weight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.label, required this.style});
  final String label;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width.ceilToDouble();
    painter.dispose();
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
