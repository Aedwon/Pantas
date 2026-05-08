import 'package:cse_cet_reviewer/app/bootstrap.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:flutter/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  bootstrap(Flavor.staging);
}
