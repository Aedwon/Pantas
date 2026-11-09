import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/domain/guardian_copy.dart';
import 'package:pantas/features/guardian/presentation/guardian_screen.dart';

/// The page a parent or guardian reaches from the emailed link. It works
/// signed out. Opening it only reads; nothing is confirmed until they tick the
/// box and press Confirm.
class GuardianConfirmPage extends ConsumerStatefulWidget {
  const GuardianConfirmPage({
    required this.token,
    this.onOpenDocument,
    super.key,
  });
  final String? token;

  /// Defaults to pushing the legal route.
  final void Function(String path)? onOpenDocument;

  @override
  ConsumerState<GuardianConfirmPage> createState() =>
      _GuardianConfirmPageState();
}

enum _Phase { loading, loadFailed, form, closed, confirmed, declined }

class _GuardianConfirmPageState extends ConsumerState<GuardianConfirmPage> {
  _Phase _phase = _Phase.loading;
  bool _agreed = false;
  bool _allowSharing = false;

  /// Kept for the Manage Permission button that follows in a later task.
  // ignore: unused_field
  String? _manageToken;
  bool _busy = false;
  bool _failed = false;
  bool _lastConfirm = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final token = widget.token;
    if (token == null || token.isEmpty) {
      setState(() => _phase = _Phase.closed);
      return;
    }
    setState(() => _phase = _Phase.loading);
    try {
      final view = await ref.read(guardianGatewayProvider).readLink(token);
      if (!mounted) return;
      setState(() {
        if (view is GuardianLinkOpen) {
          _phase = _Phase.form;
        } else {
          _phase = _Phase.closed;
        }
      });
    } on Object catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
      if (mounted) setState(() => _phase = _Phase.loadFailed);
    }
  }

  Future<void> _answer({required bool confirm}) async {
    final token = widget.token;
    if (_busy || token == null || (confirm && !_agreed)) return;
    _lastConfirm = confirm;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final result = await ref.read(guardianGatewayProvider).answer(
            token: token,
            confirm: confirm,
            agreed: _agreed,
            allowSharing: _allowSharing,
          );
      if (!mounted) return;
      setState(() {
        _manageToken = result.manageToken;
        _phase = switch (result.answer) {
          GuardianAnswer.confirmed => _Phase.confirmed,
          GuardianAnswer.declined => _Phase.declined,
          _ => _Phase.closed,
        };
      });
    } on Object catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _open(String path) {
    final custom = widget.onOpenDocument;
    if (custom != null) return custom(path);
    unawaited(context.push(path));
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
          detail: GuardianCopy.closedDetail,
        );
      case _Phase.confirmed:
        return const GuardianScreen(
          title: GuardianCopy.confirmedTitle,
          detail: GuardianCopy.confirmedDetail,
        );
      case _Phase.declined:
        return const GuardianScreen(
          title: GuardianCopy.declinedTitle,
          detail: GuardianCopy.declinedDetail,
        );
      case _Phase.form:
        return _form(context);
    }
  }

  Widget _form(BuildContext context) {
    final wide = context.wideWeb;
    final textStyle = wide
        ? PantasType.webLead.copyWith(color: context.colors.textPrimary)
        : context.type.body;
    Widget link(String label, String path) => WebTextLink(
          label: label,
          arrow: false,
          onPressed: () => _open(path),
        );
    final card = Padding(
      padding: const EdgeInsets.all(PantasSpace.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(GuardianCopy.explanation, style: textStyle),
          const SizedBox(height: PantasSpace.s8),
          Wrap(
            spacing: PantasSpace.s20,
            children: [
              link('Terms of Service', '/legal/terms'),
              link('Privacy Policy', '/legal/privacy'),
              if (teenNoticeReady) link('Notice for teens', '/legal/teens'),
            ],
          ),
        ],
      ),
    );
    final agreement = CheckboxRow(
      title: "I'm their parent or guardian, and I agree to these terms.",
      selected: _agreed,
      gap: PantasSpace.s14,
      standardDensity: true,
      squareEdges: wide,
      onTap: _busy ? null : () => setState(() => _agreed = !_agreed),
      content: Text(
        "I'm their parent or guardian, and I agree to these terms.",
        style: textStyle,
      ),
    );
    final sharing = CheckboxRow(
      title: GuardianCopy.sharingLabel,
      selected: _allowSharing,
      gap: PantasSpace.s14,
      standardDensity: true,
      squareEdges: wide,
      onTap:
          _busy ? null : () => setState(() => _allowSharing = !_allowSharing),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(GuardianCopy.sharingLabel, style: textStyle),
          Text(
            GuardianCopy.sharingHelp,
            style: wide
                ? context.webTokens.sm
                : context.type.footnote
                    .copyWith(color: context.colors.secondaryLabel),
          ),
        ],
      ),
    );
    Widget group(Widget child) =>
        wide ? WebCard(child: child) : GroupedSection(children: [child]);
    return GuardianScreen(
      title: "Confirm your child's account",
      detail: "You're confirming as their parent or guardian.",
      actions: [
        if (_failed)
          saveFailureLine(() => unawaited(_answer(confirm: _lastConfirm))),
        PantasButton(
          label: 'Confirm',
          busy: _busy,
          onPressed: _busy || !_agreed ? null : () => _answer(confirm: true),
        ),
        PantasButton(
          label: "I Don't Agree",
          kind: PantasButtonKind.tertiary,
          tone: PantasButtonTone.critical,
          onPressed: _busy ? null : () => _answer(confirm: false),
        ),
      ],
      children: [
        group(card),
        const SizedBox(height: PantasSpace.s12),
        group(agreement),
        const SizedBox(height: PantasSpace.s12),
        group(sharing),
      ],
    );
  }
}
