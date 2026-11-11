import 'package:pantas/core/ui/ds.dart';
// ds-raw: toast host with no shared system toast host here
import 'package:pantas/core/ui/raw_controls.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The app's toast over a Settings page: `toast-bg`, `toast-text`,
/// `radius-lg`, one at a time. Same drawing as the other features' toasts.
void showSettingsToast(BuildContext context, String message) {
  final colors = context.colors;
  ScaffoldMessenger.maybeOf(context) // ds-raw: toast host lookup
    ?..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        backgroundColor: colors.toastBg, // ds-raw: no shared toast host
        content: Text(
          message,
          style: (context.wideWeb
                  ? PantasType.webRowValue
                  : PantasType.phoneSubhead)
              .copyWith(color: colors.toastText),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PantasRadius.lg),
        ),
      ),
    );
}
