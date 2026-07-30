import 'package:pantas/app/bootstrap.dart';
import 'package:pantas/app/flavor.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(Flavor.prod);
}
