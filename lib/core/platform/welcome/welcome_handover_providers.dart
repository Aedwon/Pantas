import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/platform/welcome/welcome_handover.dart';
import 'package:pantas/core/platform/welcome/welcome_handover_stub.dart'
    if (dart.library.js_interop) 'package:pantas/core/platform/welcome/welcome_handover_web.dart'
    as impl;

final welcomeHandoverProvider =
    Provider<WelcomeHandover>((ref) => impl.createWelcomeHandover());
