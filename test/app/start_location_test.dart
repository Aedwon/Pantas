import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/start_location.dart';

void main() {
  tearDown(forgetStartLocation);

  test('with nothing remembered the app starts at Home', () {
    expect(initialRouterLocation, '/home');
  });

  test('the guardian link opens where it points, with its token', () {
    rememberStartLocation(
      Uri.parse('https://app.example.test/guardian?token=abc'),
      isWeb: true,
    );
    expect(initialRouterLocation, '/guardian?token=abc');
  });

  test('every other address still starts at Home', () {
    for (final url in [
      'https://app.example.test/',
      'https://app.example.test/settings',
      'https://app.example.test/guardianship',
      'https://app.example.test/guardian/waiting',
      'https://app.example.test/legal/terms',
    ]) {
      rememberStartLocation(Uri.parse(url), isWeb: true);
      expect(initialRouterLocation, '/home', reason: url);
    }
  });

  test('a native build never remembers an address', () {
    rememberStartLocation(
      Uri.parse('https://app.example.test/guardian?token=abc'),
      isWeb: false,
    );
    expect(initialRouterLocation, '/home');
  });
}
