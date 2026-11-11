/// False outside the web: a native build has no page to report on.
const supported = false;

String buildVersion() => 'unknown';

String visitKind() => 'return';

String userAgent() => '';

int viewportWidth() => 0;

void onPageHidden(void Function() action) {}
