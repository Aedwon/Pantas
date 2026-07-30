import 'package:url_launcher/url_launcher.dart';

/// Injected in tests. `launchUrl` itself is the default.
typedef LinkOpener = Future<bool> Function(Uri url, {LaunchMode mode});

/// Opens the community group where feedback is discussed.
///
/// Nothing about the student travels with it: no build number, no device
/// model, no prefill. That is the point of a URL rather than a mail
/// composer, and it is why the row needs no privacy disclosure.
Future<void> openCommunityGroup(
  String groupUrl, {
  LinkOpener open = launchUrl,
}) async {
  await open(Uri.parse(groupUrl), mode: LaunchMode.externalApplication);
}

/// Opens the student's mail app addressed to the data protection officer.
///
/// A privacy request is one to one, so this one is mail and not the group.
/// The message is empty. We do not put words in a student's mouth about
/// their own data.
Future<void> openDpoMail(
  String email, {
  LinkOpener open = launchUrl,
}) async {
  await open(
    Uri(scheme: 'mailto', path: email),
    mode: LaunchMode.externalApplication,
  );
}
