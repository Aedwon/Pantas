import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../golden_harness.dart';

/// The bottom of the sidebar: the account row, cropped under the nav items.
/// The wide sidebar (1440) is 244 px; the compact one (1024) is 220 px.
Widget _account(String plan, {String name = 'adz'}) => SizedBox(
      height: 190,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          minHeight: 520,
          maxHeight: 520,
          child: WebSidebar(
            activeIndex: 3,
            person: name,
            plan: plan,
            onAccount: () {},
            onNavigate: (_) {},
            onSearch: () {},
          ),
        ),
      ),
    );

/// Search, four nav items, then the account row.
const _tabsToAccount = 6;

List<GoldenState> _states(String tier, double width, String plan) {
  Widget build(BuildContext _) => _account(plan);
  return [
    GoldenState('$tier $plan rest', build, width: width),
    GoldenState(
      '$tier $plan hover',
      build,
      action: GoldenAction.hover,
      target: () => find.text('adz'),
      width: width,
    ),
    GoldenState(
      '$tier $plan focus',
      build,
      action: GoldenAction.focus,
      tabs: _tabsToAccount,
      width: width,
    ),
  ];
}

void main() {
  goldenSheet(
    'sidebar_account',
    [
      for (final plan in ['Free', 'Pro']) ...[
        ..._states('1440', 244, plan),
        ..._states('1024', 220, plan),
      ],
      GoldenState(
        '1024 Pro long name',
        (_) => _account('Pro', name: 'Maria Cristina Santos de la Fuente'),
        width: 220,
      ),
      GoldenState(
        '1024 plan unknown',
        (_) => _account(''),
        width: 220,
      ),
    ],
    cellWidth: 260,
    web: true,
  );
}
