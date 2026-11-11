import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/domain/guardian_copy.dart';
import 'package:pantas/features/guardian/presentation/guardian_screen.dart';

/// The page a parent or guardian reaches from the manage link, after they
/// confirmed. It works signed out. Opening it only reads. A sharing change
/// applies at once; Withdraw asks once first.
class GuardianManagePage extends ConsumerStatefulWidget {
  const GuardianManagePage({required this.token, super.key});
  final String? token;

  @override
  ConsumerState<GuardianManagePage> createState() => _GuardianManagePageState();
}

enum _Phase { loading, loadFailed, active, closed, notConfirmed, withdrawn }

/// What the change notice's Try Again repeats.
enum _Failed { sharing, withdraw }

class _GuardianManagePageState extends ConsumerState<GuardianManagePage> {
  _Phase _phase = _Phase.loading;
  bool _sharing = false;
  _Failed? _failed;

  /// The value the failed sharing change tried to set.
  bool _failedSharing = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  void _record(Object error, StackTrace stack) =>
      unawaited(ref.read(telemetryProvider).recordError(error, stack));

  /// Moves to the page the server's answer calls for.
  void _show(GuardianManageView view) {
    switch (view) {
      case GuardianManageActive(:final sharingAllowed):
        _phase = _Phase.active;
        _sharing = sharingAllowed;
      case GuardianManageNotConfirmed():
        _phase = _Phase.notConfirmed;
      case GuardianManageClosed():
        _phase = _Phase.closed;
    }
  }

  Future<void> _load() async {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() => _phase = _Phase.closed);
      return;
    }
    setState(() => _phase = _Phase.loading);
    try {
      final view = await ref.read(guardianGatewayProvider).readManage(token);
      if (mounted) setState(() => _show(view));
    } on Object catch (error, stack) {
      _record(error, stack);
      if (mounted) setState(() => _phase = _Phase.loadFailed);
    }
  }

  /// Shows the new value at once, then asks the server. A failure puts the
  /// old value back and shows the notice.
  Future<void> _setSharing({required bool allowed}) async {
    final token = widget.token;
    if (_busy || token == null) return;
    final before = _sharing;
    setState(() {
      _busy = true;
      _failed = null;
      _sharing = allowed;
    });
    try {
      final view = await ref
          .read(guardianGatewayProvider)
          .setSharing(token: token, allowed: allowed);
      if (mounted) setState(() => _show(view));
    } on Object catch (error, stack) {
      _record(error, stack);
      if (mounted) {
        setState(() {
          _sharing = before;
          _failed = _Failed.sharing;
          _failedSharing = allowed;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _askWithdraw() async {
    if (_busy) return;
    setState(() => _failed = null);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: context.colors.scrim,
      builder: (dialogContext) => CenteredDialog(
        title: GuardianCopy.withdrawDialogTitle,
        message: GuardianCopy.withdrawDialogBody,
        primaryLabel: 'Withdraw',
        secondaryLabel: 'Cancel',
        destructive: true,
        onConfirm: () => Navigator.of(dialogContext).pop(true),
        onCancel: () => Navigator.of(dialogContext).pop(false),
      ),
    );
    if ((confirmed ?? false) && mounted) await _withdraw();
  }

  Future<void> _withdraw() async {
    final token = widget.token;
    if (_busy || token == null) return;
    setState(() => _busy = true);
    try {
      final result = await ref.read(guardianGatewayProvider).withdraw(token);
      if (!mounted) return;
      setState(() {
        _phase = switch (result) {
          GuardianWithdrawal.withdrawn => _Phase.withdrawn,
          GuardianWithdrawal.notConfirmed => _Phase.notConfirmed,
          GuardianWithdrawal.closed => _Phase.closed,
        };
      });
    } on Object catch (error, stack) {
      _record(error, stack);
      if (mounted) setState(() => _failed = _Failed.withdraw);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Repeats what failed. A failed withdrawal asks again first, so nothing is
  /// deleted by a tap on Try Again alone.
  void _retry() {
    switch (_failed) {
      case _Failed.sharing:
        unawaited(_setSharing(allowed: _failedSharing));
      case _Failed.withdraw:
        unawaited(_askWithdraw());
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.loading:
        return Scaffold(body: loadingFor(const AsyncLoading<void>()));
      case _Phase.loadFailed:
        return Scaffold(body: errorFor('request', _load));
      case _Phase.closed:
        return const GuardianScreen(
          title: GuardianCopy.closedTitle,
          detail: GuardianCopy.manageClosedDetail,
        );
      case _Phase.notConfirmed:
        return const GuardianScreen(
          title: GuardianCopy.notConfirmedTitle,
          detail: GuardianCopy.notConfirmedDetail,
        );
      case _Phase.withdrawn:
        return const GuardianScreen(
          title: GuardianCopy.withdrawnTitle,
          detail: GuardianCopy.withdrawnDetail,
        );
      case _Phase.active:
        return _active(context);
    }
  }

  Widget _active(BuildContext context) {
    final wide = context.wideWeb;
    final failure = _failed == null
        ? null
        // Board MS_States draws a Notice here; the system's Notice cannot be
        // drawn without its dismiss control, so this is the confirm page's
        // existing retry line until the lead rules on it.
        : saveFailureLine(
            _retry,
            message: GuardianCopy.changeFailedLine,
          );
    return GuardianScreen(
      title: GuardianCopy.manageTitle,
      detail: GuardianCopy.manageDetail,
      children: [
        if (wide) _wideCard(context) else ..._phoneGroups(),
        if (failure != null) ...[
          const SizedBox(height: PantasSpace.s12),
          failure,
        ],
      ],
    );
  }

  void _toggle() => unawaited(_setSharing(allowed: !_sharing));

  /// Phone: the switch in one group and Withdraw in its own group, 24 apart.
  List<Widget> _phoneGroups() => [
        GroupedSection(
          children: [
            ListRow(
              title: GuardianCopy.sharingLabel,
              subtitle: GuardianCopy.manageSharingHelp,
              variant: ListRowVariant.switchControl,
              selected: _sharing,
              onTap: _busy ? null : _toggle,
            ),
          ],
        ),
        const SizedBox(height: PantasSpace.s24),
        GroupedSection(
          children: [
            ListRow(
              title: GuardianCopy.withdrawLabel,
              variant: ListRowVariant.destructive,
              onTap: _busy ? null : () => unawaited(_askWithdraw()),
            ),
          ],
        ),
      ];

  /// Wide web: one card, the switch row and under it the Withdraw action.
  Widget _wideCard(BuildContext context) {
    final t = context.webTokens;
    return WebCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // One node for the row, so the on/off state sits with its label and
          // its tap action.
          MergeSemantics(
            child: Semantics(
              toggled: _sharing,
              child: WebRow(
                title: GuardianCopy.sharingLabel,
                subtitle: GuardianCopy.manageSharingHelp,
                subtitleStyle: t.sm,
                // The board's help line wraps. A web row cuts a one-line
                // subtitle unless it wraps.
                wrapTitle: true,
                titleStyle: PantasType.webRowTitleSettings
                    .copyWith(color: t.colors.textPrimary),
                horizontalPadding: PantasLayout.rowInsetSettings,
                divider: false,
                onPressed: _busy ? null : _toggle,
                trailing: ExcludeSemantics(
                  child: ExcludeFocus(
                    child: PantasSwitch(
                      value: _sharing,
                      label: GuardianCopy.sharingLabel,
                      onChanged: _busy ? null : (_) => _toggle(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PantasLayout.rowInsetSettings,
              vertical: PantasSpace.s8,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              // The label lines up with the row's text, as Settings does.
              child: Transform.translate(
                offset: const Offset(-PantasSpace.s18, 0),
                child: WebButton(
                  label: GuardianCopy.withdrawLabel,
                  variant: WebButtonVariant.tertiary,
                  redText: true,
                  height: PantasSize.btnSm,
                  radius: PantasRadius.md,
                  onPressed: _busy ? null : () => unawaited(_askWithdraw()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
