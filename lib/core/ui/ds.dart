/// The one import a screen uses for Flutter's widgets and Material, in place of
/// `package:flutter/material.dart`. Guardrails layer 1.
///
/// It hides Flutter's raw controls so a screen cannot draw the framework's
/// default look. Use the system component for the job (`lib/core/ui/components`).
/// If none fits, add one first. A control that must stay raw is imported from
/// `package:pantas/core/ui/raw_controls.dart`, and the import carries a
/// `// ds-raw: <reason>` comment. `tool/check_layering.dart` enforces both.
library;

export 'package:flutter/material.dart'
    hide
        ActionChip,
        AlertDialog,
        Checkbox,
        Chip,
        ChoiceChip,
        CircularProgressIndicator,
        DropdownButton,
        ElevatedButton,
        FilledButton,
        FilterChip,
        FloatingActionButton,
        IconButton,
        InkResponse,
        InkWell,
        InputChip,
        LinearProgressIndicator,
        ListTile,
        OutlinedButton,
        PopupMenuButton,
        Radio,
        RawChip,
        SimpleDialog,
        Slider,
        SnackBar,
        Switch,
        TextButton,
        TextField,
        TextFormField,
        Tooltip,
        showDialog,
        showModalBottomSheet;
export 'package:flutter/widgets.dart';
