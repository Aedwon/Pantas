import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/steps_screen.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
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
                  : 'Your account is deleted. Nothing of yours is left.'
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
      return Stack(
        fit: StackFit.expand,
        children: [
          const AccountPage(),
          const ModalBarrier(color: Color(0x521D1D1F), dismissible: false),
          Center(
            child: Dialog(
              insetPadding: const EdgeInsets.all(24),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: SizedBox(
                width: 560,
                child: WebCard(
                  radius: 22,
                  padding: const EdgeInsets.all(26),
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
                        const SizedBox(height: 4),
                        Text("This can't be undone.", style: t.sub),
                        const SizedBox(height: 18),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: t.colors.background,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              if (!widget.isAnonymous) ...[
                                SettingsRow(
                                  title: 'Your account is removed.',
                                  leading: Icon(
                                    PantasIcons.profile,
                                    color: t.colors.wrongText,
                                    size: 22,
                                  ),
                                  variant: ListRowVariant.value,
                                  divider: true,
                                ),
                                SettingsRow(
                                  title: 'Anything backed up to it is erased.',
                                  leading: Icon(
                                    PantasIcons.cloudSlash,
                                    color: t.colors.wrongText,
                                    size: 22,
                                  ),
                                  variant: ListRowVariant.value,
                                  divider: true,
                                ),
                              ],
                              SettingsRow(
                                title:
                                    'Progress in this browser is erased too.',
                                leading: Icon(
                                  PantasIcons.phoneSlash,
                                  color: t.colors.wrongText,
                                  size: 22,
                                ),
                                variant: ListRowVariant.value,
                              ),
                            ],
                          ),
                        ),
                        if (billing != null) ...[
                          const SizedBox(height: 18),
                          Text(billing, style: t.sub),
                        ],
                        if (_failed) ...[
                          const SizedBox(height: 18),
                          Text(
                            'We could not complete deletion. '
                            'Try again or contact '
                            'our DPO at ${widget.dpoEmail}.',
                            style: t.sub,
                          ),
                        ],
                        const SizedBox(height: 18),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            WebButton(
                              label: widget.isAnonymous
                                  ? 'Cancel'
                                  : 'Keep My Account',
                              variant: WebButtonVariant.tertiary,
                              onPressed: () => Navigator.of(context).maybePop(),
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
          ),
        ],
      );
    }
    Widget consequence(Widget icon, String text) => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 12),
              Expanded(
                child:
                    Text(text, style: context.type.body.copyWith(fontSize: 16)),
              ),
            ],
          ),
        );
    return SettingsPanePage(
      section: 'Account',
      title: context.wideWeb ? 'Delete account' : '',
      backLabel: 'Account',
      onBack: _isDeleting ? null : () => Navigator.of(context).maybePop(),
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isDeleted) ...[
                PantasButton(
                  label: _failed ? 'Try again' : 'Delete My Data',
                  variant: PantasButtonVariant.destructive,
                  busy: _isDeleting,
                  onPressed: _isDeleting ? null : _delete,
                ),
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
        Text(
          widget.isAnonymous ? 'Delete your data?' : 'Delete your account?',
          style: context.type.pageTitle,
        ),
        const SizedBox(height: 6),
        Text(
          widget.isAnonymous
              ? 'Your progress on this device will be permanently deleted. '
                  'Sign in first if you want to keep it.'
              : 'This can’t be undone.',
          style: context.type.body
              .copyWith(color: context.colors.secondaryLabel, fontSize: 16),
        ),
        const SizedBox(height: 22),
        SettingsSection(
          children: [
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
              'Progress on this phone is erased too.',
            ),
          ],
        ),
        if (billing != null) ...[
          const SizedBox(height: 22),
          SettingsSection(
            children: [
              consequence(
                Icon(
                  PantasIcons.appError,
                  size: 22,
                  color: context.colors.destructive,
                ),
                billing,
              ),
            ],
          ),
        ],
        if (_isDeleting) ...[
          const SizedBox(height: 22),
          Semantics(
            liveRegion: true,
            child: Text('Deleting...', style: context.type.body),
          ),
        ],
        if (_isDeleted) ...[
          const SizedBox(height: 22),
          Semantics(
            liveRegion: true,
            child:
                Text('Deletion request completed.', style: context.type.body),
          ),
        ],
        if (_failed) ...[
          const SizedBox(height: 22),
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
