import 'package:pantas/core/dev/scroll_exp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:pantas/app/bootstrap.dart';
import 'package:pantas/app/flavor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  readScrollExp();
  startScrollExp();
  if (kIsWeb) usePathUrlStrategy();
  bootstrap(Flavor.staging);
}
