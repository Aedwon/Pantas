import 'package:pantas/core/platform/install/install_platform.dart';

InstallPlatform createInstallPlatform() => const UnsupportedInstallPlatform();

InstallMemory createInstallMemory() => InMemoryInstallMemory();
