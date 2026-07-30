import 'package:flutter/widgets.dart';
import 'package:pantas/app/bootstrap.dart';
import 'package:pantas/app/flavor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(Flavor.staging);
}
