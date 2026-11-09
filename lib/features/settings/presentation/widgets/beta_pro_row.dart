import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/row_tap_target.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/application/beta_pro_provider.dart';

class BetaProRow extends ConsumerStatefulWidget {
  const BetaProRow({super.key});
  @override
  ConsumerState<BetaProRow> createState() => _BetaProRowState();
}

class _BetaProRowState extends ConsumerState<BetaProRow> {
  bool _pending = false;
  bool _turningOn = false;

  Future<void> _change(bool enabled) async {
    if (_pending) return;
    setState(() {
      _pending = true;
      _turningOn = enabled;
    });
    try {
      await ref.read(setBetaProProvider)(enabled: enabled);
    } on Exception {
      if (mounted) {
        showPantasToast(context, 'Could not change Pro features. Try again.');
      }
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final beta = ref.watch(betaProProvider).valueOrNull;
    if (beta == null) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned(
          left: context.wideWeb ? 50 : 56,
          right: PantasSpace.s16,
          top: 0,
          child: Container(
            height: PantasBorder.hairline,
            color: context.colors.separator,
          ),
        ),
        RowTapTarget(
          onTap: _pending ? null : () => _change(!beta.enabled),
          child: ListRow(
            title: 'Beta: Pro Features',
            leading: SizedBox(width: context.wideWeb ? 22 : 30),
            contentPadding: context.wideWeb
                ? null
                : const EdgeInsets.fromLTRB(
                    PantasSpace.s14,
                    PantasSpace.s10,
                    PantasSpace.s16,
                    PantasSpace.s10,
                  ),
            minimumHeight: 66,
            verticalPadding: context.wideWeb ? 13 : 11,
            titleWidget: Text(
              'Beta: Pro Features',
              style: (context.wideWeb
                      ? PantasType.webRowTitleSettings
                      : PantasType.phoneBody)
                  .copyWith(color: context.colors.textPrimary),
            ),
            subtitle: _pending && _turningOn ? 'Turning On…' : null,
            trailingWidget: Semantics(
              enabled: !_pending,
              child: ExcludeFocus(
                excluding: _pending,
                child: IgnorePointer(
                  ignoring: _pending,
                  child: Opacity(
                    opacity: _pending ? .5 : 1,
                    child: PantasSwitch(
                      value: beta.enabled,
                      label: 'Beta: Pro Features',
                      onChanged: _change,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BetaProNote extends ConsumerWidget {
  const BetaProNote({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(betaProProvider).valueOrNull?.enabled != true) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PantasSpace.s16,
        PantasSpace.s6,
        PantasSpace.s16,
        PantasSpace.s0,
      ),
      child: Text(
        'Pro features are on for the beta, until Nov 16.',
        style: PantasType.phoneFootnote
            .copyWith(color: context.colors.textSecondary),
      ),
    );
  }
}
