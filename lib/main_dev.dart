import 'package:flutter/widgets.dart';
import 'app/bootstrap.dart';
import 'app/flavor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(Flavor.dev);
}
