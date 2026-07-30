import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/settings/presentation/feedback_intent.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  late List<Uri> opened;
  late List<LaunchMode> modes;

  Future<bool> record(Uri url, {LaunchMode mode = LaunchMode.platformDefault}) {
    opened.add(url);
    modes.add(mode);
    return Future.value(true);
  }

  setUp(() {
    opened = [];
    modes = [];
  });

  test('the group opens outside the app', () async {
    await openCommunityGroup(
      'https://www.facebook.com/groups/1760794271928040',
      open: record,
    );

    expect(
      opened.single,
      Uri.parse('https://www.facebook.com/groups/1760794271928040'),
    );
    expect(modes.single, LaunchMode.externalApplication);
  });

  test('nothing about the student travels with the group link', () async {
    await openCommunityGroup('https://www.facebook.com/groups/1', open: record);

    final url = opened.single;
    expect(url.queryParameters, isEmpty);
    expect(url.fragment, isEmpty);
    expect(url.userInfo, isEmpty);
  });

  test('the DPO link is mail to the address, with nothing filled in', () async {
    await openDpoMail('dpo@pantas.app', open: record);

    final url = opened.single;
    expect(url.scheme, 'mailto');
    expect(url.path, 'dpo@pantas.app');
    // No subject, no body. We do not put words in a student's mouth about
    // their own data.
    expect(url.queryParameters, isEmpty);
  });
}
