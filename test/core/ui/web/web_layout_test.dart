import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

void main() {
  test('wide layout requires web and at least 1024 logical pixels', () {
    expect(isWideWebLayout(width: 1440, web: true), isTrue);
    expect(isWideWebLayout(width: 1024, web: true), isTrue);
    expect(isWideWebLayout(width: 1023, web: true), isFalse);
    expect(isWideWebLayout(width: 1440, web: false), isFalse);
    expect(isWideWebLayout(width: 390, web: false), isFalse);
  });
}
