// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

/// Drops `localStudent` from the page address without reloading, so a reload
/// does not load the student again.
void removeLocalStudentFromUrl() {
  final url = Uri.parse(web.window.location.href);
  final rest = {...url.queryParameters}..remove('localStudent');
  final next = url.replace(queryParameters: rest.isEmpty ? null : rest);
  web.window.history.replaceState(null, '', next.toString());
}
