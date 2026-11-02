import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
  GuardianLinkOpen? _link;
  bool _agreed = false;
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
          _link = view;
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
          );
      if (!mounted) return;
      setState(() {
        _phase = switch (result) {
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

  String get _student => _link?.studentName ?? GuardianCopy.unnamedStudent;

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
        return GuardianScreen(
          title: GuardianCopy.confirmedTitle,
          detail: GuardianCopy.confirmedDetail(_student),
        );
      case _Phase.declined:
        return GuardianScreen(
          title: GuardianCopy.declinedTitle,
          detail: GuardianCopy.declinedDetail(_student),
        );
      case _Phase.form:
        return _form(context);
    }
  }

  Widget _form(BuildContext context) {
    final student = _student;
    final wide = context.wideWeb;
    final textStyle = wide
        ? context.webTokens.style(17, height: 1.5)
        : context.type.body.copyWith(height: 1.4);
    final accent = context.colors.accent;
    Widget link(String label, String path) => TextButton(
          onPressed: () => _open(path),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 44),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(label, style: textStyle.copyWith(color: accent)),
        );
    final card = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pantas keeps $student's answers and study progress to run the "
            "app. ${GuardianCopy.atSentenceStart(student)} can't buy Pro. "
            'Only you can, from your own payment method.',
            style: textStyle,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 20,
            children: [
              link('Terms', '/legal/terms'),
              link('Privacy Policy', '/legal/privacy'),
              link('Notice for teens', '/legal/teens'),
            ],
          ),
        ],
      ),
    );
    final agreement = CheckboxRow(
      title: "I'm $student's parent or guardian, and I agree to these terms.",
      selected: _agreed,
      gap: 14,
      standardDensity: true,
      onTap: _busy ? null : () => setState(() => _agreed = !_agreed),
      content: Text(
        "I'm $student's parent or guardian, and I agree to these terms.",
        style: textStyle,
      ),
    );
    Widget group(Widget child) => wide
        ? WebCard(radius: 16, child: child)
        : GroupedSection(children: [child]);
    return GuardianScreen(
      title: "Confirm $student's account",
      detail: "You're confirming as $student's parent or guardian.",
      actions: [
        if (_failed)
          saveFailureLine(() => unawaited(_answer(confirm: _lastConfirm))),
        PantasButton(
          label: 'Confirm',
          busy: _busy,
          onPressed: _busy || !_agreed ? null : () => _answer(confirm: true),
        ),
        TextButton(
          onPressed: _busy ? null : () => _answer(confirm: false),
          style: TextButton.styleFrom(
            foregroundColor: context.colors.destructive,
            minimumSize: const Size(0, 48),
          ),
          child: Text(
            "I Don't Agree",
            style: textStyle.copyWith(
              color: context.colors.destructive,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      children: [
        group(card),
        const SizedBox(height: 12),
        group(agreement),
      ],
    );
  }
}
