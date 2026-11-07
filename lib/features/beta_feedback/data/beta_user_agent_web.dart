// The browser API package is already locked through Flutter's web plugins.
// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

/// The browser's own description of itself, sent with each report.
String betaUserAgent() => web.window.navigator.userAgent;
