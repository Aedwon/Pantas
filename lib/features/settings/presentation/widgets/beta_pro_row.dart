import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not change Pro features. Try again.'),
          ),
        );
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
          left: context.wideWeb ? 50 : 52,
          right: 16,
          top: 0,
          child: Container(height: .5, color: context.colors.separator),
        ),
        ListRow(
          title: 'Beta: Pro Features',
          leading: const SizedBox(width: 22),
          leadingGap: context.wideWeb ? 12 : 14,
          minimumHeight: 66,
          verticalPadding: context.wideWeb ? 13 : 11,
          titleWidget: Text(
            'Beta: Pro Features',
            style: context.type.body.copyWith(
              fontSize: context.wideWeb ? 16 : 17,
            ),
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
      padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
      child: Text(
        'Pro features are on for the beta, until Nov 16.',
        style: context.type.footnote.copyWith(fontSize: 13, height: 1.4),
      ),
    );
  }
}
