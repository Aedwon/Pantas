import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/features/child_setup/domain/guardian_gate.dart';
import 'package:pantas/features/child_setup/presentation/parents_frame.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';

/// Draws the For parents page and the code gate on wide web the way the other
/// Settings pages are drawn: in the Settings pane, under the list. The child
/// setup feature cannot import Settings screens, so the app hands this in.
Widget parentsSettingsFrame(ParentsFrame frame) => SettingsPanePage(
      section: ParentsCopy.settingsRow,
      title: frame.title,
      description: frame.lead,
      backLabel: frame.backLabel,
      onBack: frame.onBack,
      children: [
        ...frame.children,
        if (frame.bottom != null) ...[
          const SizedBox(height: PantasSpace.s24),
          Align(alignment: Alignment.centerRight, child: frame.bottom),
        ],
      ],
    );
