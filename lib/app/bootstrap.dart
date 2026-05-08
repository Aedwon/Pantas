import 'dart:async';

import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap(Flavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization wires in at Task 17.
  // Crashlytics zone wrapping wires in at Plan 2.

  runApp(
    ProviderScope(
      child: App(flavor: flavor),
    ),
  );
}
