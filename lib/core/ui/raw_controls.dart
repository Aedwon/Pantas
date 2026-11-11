/// The one escape for raw framework controls. Guardrails layer 1.
///
/// `ds.dart` hides these. A screen that cannot use a system component, because
/// it would change what a student sees, imports this file instead, and the
/// import carries a reason on its own line or the line above:
///
/// ```dart
/// // ds-raw: <why the system component does not fit>
/// import 'package:pantas/core/ui/raw_controls.dart';
/// ```
///
/// `tool/check_layering.dart` fails an import of this file with no reason.
/// Add a name here only after a system component for it has been ruled out.
library;

export 'package:flutter/material.dart'
    show
        InkWell,
        LinearProgressIndicator,
        PopupMenuButton,
        SnackBar,
        TextButton,
        TextField;
