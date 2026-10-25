import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Adds the complete bundled font notices to Flutter's license collection.
void registerBundledFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final notice in {
      'Geist': 'assets/fonts/OFL-Geist.txt',
      'Phosphor': 'assets/fonts/phosphor/LICENSE',
    }.entries) {
      yield LicenseEntryWithLineBreaks(
        [notice.key],
        await rootBundle.loadString(notice.value),
      );
    }
  });
}
