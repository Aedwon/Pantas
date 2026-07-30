import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/wrapped/domain/wrapped_share_url.dart';

void main() {
  test('base is the canonical wrapped path', () {
    expect(WrappedShareUrl.base, 'https://pantas.app/wrapped');
  });

  test('forShareId appends the token', () {
    expect(
      WrappedShareUrl.forShareId('abc123'),
      'https://pantas.app/wrapped/abc123',
    );
  });
}
