import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:pantas/core/storage/data/web_build_files.dart';
// The browser API package is already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

export 'package:pantas/core/storage/data/web_build_files.dart';

/// The build folder the bootstrap wrote as `window.pantasBuildBase`, or null.
String? _buildBase() {
  final base = globalContext['pantasBuildBase'];
  return base.isA<JSString>() ? (base! as JSString).toDart : null;
}

/// The address of [name] in this build's folder, in the browser.
Uri webBuildFile(String name) =>
    buildFileUri(Uri.parse(web.document.baseURI), _buildBase(), name);

/// The address of [name], which every build serves from the same place.
Uri webRootFile(String name) =>
    rootFileUri(Uri.parse(web.document.baseURI), name);
