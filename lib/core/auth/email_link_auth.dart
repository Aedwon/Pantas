import 'package:pantas/core/auth/email_link_storage_stub.dart'
    if (dart.library.js_interop) 'package:pantas/core/auth/email_link_storage_web.dart'
    as storage;

abstract interface class EmailLinkAuthGateway {
  bool isSignInLink(String link);
  Future<void> sendLink(String email, String continueUrl);
  Future<void> link(String email, String link);
  Future<void> signIn(String email, String link);
}

abstract interface class EmailLinkStore {
  String? get email;
  set email(String? value);
}

class BrowserEmailLinkStore implements EmailLinkStore {
  const BrowserEmailLinkStore();
  @override
  String? get email => storage.readEmail();
  @override
  set email(String? value) => storage.writeEmail(value);
}

// Single-method interface keeps popup authentication injectable.
// ignore: one_member_abstracts
abstract interface class GooglePopupAuthGateway {
  Future<void> googlePopup({required bool link});
}
