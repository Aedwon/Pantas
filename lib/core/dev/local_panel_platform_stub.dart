import 'package:pantas/core/dev/local_panel_types.dart';

/// Only a browser has a panel to talk to.
LocalPanelChannel? openLocalPanelChannel() => null;

/// Only a browser has a page.
LocalPanelPage? localPanelPage() => null;
