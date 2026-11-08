import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/steps_screen.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/settings.dart';

typedef DeleteAccountCallback = Future<void> Function();

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({
    required this.isAnonymous,
    required this.entitlement,
    required this.dpoEmail,
    required this.onDelete,
    super.key,
  });
  final bool isAnonymous;
  final SettingsEntitlementSnapshot entitlement;
  final String dpoEmail;
  final DeleteAccountCallback onDelete;
  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  bool _isDeleting = false;
  bool _isDeleted = false;
  bool _failed = false;

  // On wide web the dialog plays its exit before the route pops.
  final _exit = WebOverlayExit();

  void _leave() {
    if (mounted) Navigator.of(context).pop();
  }

  void _close() {
    if (Navigator.of(context).canPop()) _exit.close(_leave);
  }

  Future<void> _delete() async {
    if (_isDeleting || _isDeleted) return;
    setState(() {
      _isDeleting = true;
      _failed = false;
    });
    final telemetry = ref.read(telemetryProvider);
    try {
      await widget.onDelete();
      if (mounted) setState(() => _isDeleted = true);
    } catch (error, stack) {
      await telemetry.recordError(error, stack);
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  /// A board `.row.c` in the dialog: a 20 px red no-entry glyph, 16 px text.
  Widget _consequence(WebTokens t, String text, {bool divider = false}) =>
      WebRow(
        title: text,
        titleStyle: PantasType.webRowTitleSettings
            .copyWith(color: t.colors.textPrimary),
        compact: true,
        leading: CustomPaint(
          size: const Size.square(20),
          painter: _NoEntryPainter(t.colors.wrongText),
        ),
        divider: divider,
      );

  @override
  Widget build(BuildContext context) {
    final billing = widget.isAnonymous
        ? anonymousDeleteWarning(widget.entitlement)
        : ref.watch(paymentsOnWebProvider)
            ? widget.entitlement.isTrial
                ? 'Your free trial will end if you delete now.'
                : null
            : deleteAccountBillingLine(widget.entitlement);
    if (context.wideWeb) {
      final t = context.webTokens;
      if (_isDeleting || _isDeleted) {
        return StepsScreen(
          title: _isDeleted
              ? widget.isAnonymous
                  ? 'Your data is deleted.'
                  : 'Your account is deleted.'
              : widget.isAnonymous
                  ? 'Deleting your data'
                  : 'Deleting your account',
          subtitle: _isDeleted ? null : 'Keep Pantas open until this finishes.',
          steps: [
            if (!_isDeleted)
              WorkStep(
                label: widget.isAnonymous
                    ? 'From this browser'
                    : 'From this browser and the cloud',
                state: WorkStepState.active,
              ),
          ],
          buttonLabel: _isDeleted ? 'Close' : null,
          onContinue: () => Navigator.of(context).maybePop(),
        );
      }
      return WebRootModal(
        exit: _exit,
        onEscape: _close,
        // Opened by address, there is no page to go back to, so Back is left
        // to the browser.
        onBack: Navigator.of(context).canPop() ? _leave : null,
        child: const AccountPage(),
        modal: (context) => Dialog(
          insetPadding: const EdgeInsets.all(PantasSpace.s24),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: SizedBox(
            width: PantasLayout.modalWide,
            child: WebCard(
              radius: PantasRadius.r2xl,
              padding: const EdgeInsets.all(PantasSpace.s24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.isAnonymous
                          ? 'Delete your data?'
                          : 'Delete your account?',
                      style: t.h3,
                    ),
                    const SizedBox(height: PantasSpace.s4),
                    Text("This can't be undone.", style: t.sub),
                    const SizedBox(height: PantasSpace.s18),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: t.colors.background,
                        borderRadius: BorderRadius.circular(PantasRadius.xl),
                      ),
                      child: Column(
                        children: [
                          if (!widget.isAnonymous) ...[
                            _consequence(
                              t,
                              'Your account is removed.',
                              divider: true,
                            ),
                            _consequence(
                              t,
                              'Anything backed up to it is erased.',
                              divider: true,
                            ),
                          ],
                          _consequence(
                            t,
                            'Progress in this browser is erased too.',
                          ),
                        ],
                      ),
                    ),
                    if (billing != null) ...[
                      const SizedBox(height: PantasSpace.s18),
                      Text(billing, style: t.sub),
                    ],
                    if (_failed) ...[
                      const SizedBox(height: PantasSpace.s18),
                      Text(
                        'We could not complete deletion. '
                        'Try again or contact '
                        'our DPO at ${widget.dpoEmail}.',
                        style: t.sub,
                      ),
                    ],
                    const SizedBox(height: PantasSpace.s18),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: PantasSpace.s8,
                      runSpacing: PantasSpace.s8,
                      children: [
                        WebButton(
                          label:
                              widget.isAnonymous ? 'Cancel' : 'Keep My Account',
                          variant: WebButtonVariant.tertiary,
                          onPressed: _close,
                        ),
                        WebButton(
                          label: _failed ? 'Try Again' : 'Delete My Data',
                          variant: WebButtonVariant.danger,
                          onPressed: _delete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    // ST_DeleteAccount: 16 px inside the card, 13 px between the rows.
    Widget consequence(Widget icon, String text, {TextStyle? style}) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            const SizedBox(width: PantasSpace.s12),
            Expanded(
              child: Text(
                text,
                style: (style ?? PantasType.phoneCallout)
                    .copyWith(color: context.colors.textPrimary),
              ),
            ),
          ],
        );
    Widget card(List<Widget> rows) => SettingsSection(
          children: [
            Padding(
              padding: const EdgeInsets.all(PantasSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, row) in rows.indexed) ...[
                    if (index > 0) const SizedBox(height: PantasSpace.s12),
                    row,
                  ],
                ],
              ),
            ),
          ],
        );
    return SettingsPanePage(
      section: 'Account',
      title: context.wideWeb ? 'Delete account' : '',
      noHeading: true,
      backLabel: 'Account',
      onBack: _isDeleting ? null : () => Navigator.of(context).maybePop(),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s16,
            PantasSpace.s14,
            PantasSpace.s16,
            PantasSpace.s28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isDeleted) ...[
                PantasButton(
                  label: _failed ? 'Try Again' : 'Delete My Data',
                  variant: PantasButtonVariant.destructive,
                  busy: _isDeleting,
                  onPressed: _isDeleting ? null : _delete,
                ),
                const SizedBox(height: PantasSpace.s8),
                PantasButton(
                  label: widget.isAnonymous ? 'Cancel' : 'Keep My Account',
                  variant: PantasButtonVariant.tertiary,
                  onPressed: _isDeleting
                      ? null
                      : () => Navigator.of(context).maybePop(),
                ),
              ] else
                PantasButton(
                  label: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
            ],
          ),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PantasSpace.s4,
            PantasSpace.s6,
            PantasSpace.s4,
            PantasSpace.s0,
          ),
          child: Text(
            widget.isAnonymous ? 'Delete your data?' : 'Delete your account?',
            style: context.type.pageTitleCompact.copyWith(height: 1.2),
          ),
        ),
        const SizedBox(height: PantasSpace.s6),
        Padding(
          padding: const EdgeInsets.only(left: PantasSpace.s4),
          child: Text(
            widget.isAnonymous
                ? 'Your progress on this device will be permanently deleted. '
                    'Sign in first if you want to keep it.'
                : "This can't be undone.",
            style: PantasType.phoneCallout
                .copyWith(color: context.colors.textSecondary),
          ),
        ),
        const SizedBox(height: PantasSpace.s20),
        card([
          if (!widget.isAnonymous) ...[
            consequence(
              SizedBox.square(
                dimension: 22,
                child: CustomPaint(
                  foregroundPainter: _UserSlashPainter(
                    context.colors.surface,
                    context.colors.destructive,
                  ),
                  child: Icon(
                    PantasIcons.profile,
                    size: 22,
                    color: context.colors.destructive,
                  ),
                ),
              ),
              'Your account is removed.',
            ),
            consequence(
              Icon(
                PantasIcons.cloudSlash,
                size: 22,
                color: context.colors.destructive,
              ),
              'Anything backed up to it is erased.',
            ),
          ],
          consequence(
            Icon(
              PantasIcons.phoneSlash,
              size: 22,
              color: context.colors.destructive,
            ),
            context.webPlatform
                ? 'Progress in this browser is erased too.'
                : 'Progress on this phone is erased too.',
          ),
        ]),
        if (billing != null) ...[
          const SizedBox(height: PantasSpace.s20),
          card([
            consequence(
              Icon(
                PantasIcons.appError,
                size: 22,
                color: context.colors.destructive,
              ),
              billing,
              style: PantasType.phoneExplanation,
            ),
          ]),
        ],
        if (_isDeleting) ...[
          const SizedBox(height: PantasSpace.s20),
          Semantics(
            liveRegion: true,
            child: Text('Deleting...', style: context.type.body),
          ),
        ],
        if (_isDeleted) ...[
          const SizedBox(height: PantasSpace.s20),
          Semantics(
            liveRegion: true,
            child:
                Text('Deletion request completed.', style: context.type.body),
          ),
        ],
        if (_failed) ...[
          const SizedBox(height: PantasSpace.s20),
          Semantics(
            liveRegion: true,
            child: Text(
              'We could not complete deletion. Try again or contact our DPO '
              'at ${widget.dpoEmail}.',
              style: context.type.footnote
                  .copyWith(color: context.colors.destructive),
            ),
          ),
        ],
      ],
    );
  }
}

// The board masks a slash over the regular user glyph.
class _UserSlashPainter extends CustomPainter {
  const _UserSlashPainter(this.background, this.color);
  final Color background;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(size.width * 48 / 256, size.height * 40 / 256);
    final end = Offset(size.width * 208 / 256, size.height * 216 / 256);
    canvas
      ..drawLine(
        start,
        end,
        Paint()
          ..color = background
          ..strokeWidth = size.width * 44 / 256
          ..strokeCap = StrokeCap.round,
      )
      ..drawLine(
        start,
        end,
        Paint()
          ..color = color
          ..strokeWidth = size.width * 16 / 256
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  bool shouldRepaint(_UserSlashPainter oldDelegate) =>
      background != oldDelegate.background || color != oldDelegate.color;
}

/// The board's circle with a slash: radius 8.5 on a 24 unit box, stroke 1.8.
class _NoEntryPainter extends CustomPainter {
  const _NoEntryPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * unit
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawCircle(Offset(12 * unit, 12 * unit), 8.5 * unit, paint)
      ..drawLine(
        Offset(6 * unit, 6 * unit),
        Offset(18 * unit, 18 * unit),
        paint,
      );
  }

  @override
  bool shouldRepaint(_NoEntryPainter oldDelegate) => color != oldDelegate.color;
}
