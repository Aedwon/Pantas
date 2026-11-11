import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:pantas_lints/src/ds_board_value_reason.dart';
import 'package:pantas_lints/src/ds_marker_reason.dart';
import 'package:pantas_lints/src/ds_no_design_literal.dart';

final plugin = PantasLintsPlugin();

class PantasLintsPlugin extends Plugin {
  @override
  String get name => 'Pantas design system lints';

  @override
  void register(PluginRegistry registry) {
    registry
      ..registerWarningRule(DsNoDesignLiteral())
      ..registerWarningRule(DsBoardValueReason())
      ..registerWarningRule(DsMarkerReason());
  }
}
