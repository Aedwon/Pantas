import 'package:pantas/core/auth/email_link_auth.dart';

/// An email-link store that remembers the address a sign-out cleared, so a
/// sign-out that is then refused can put it back. Sign-out clears the pending
/// email-link address before it asks anything; a refused sign-out must leave
/// that sign-in as it was.
class RestorableEmailLinkStore implements EmailLinkStore {
  RestorableEmailLinkStore(this._inner);

  final EmailLinkStore _inner;
  String? _cleared;

  @override
  String? get email => _inner.email;

  @override
  set email(String? value) {
    if (value == null) {
      _cleared = _inner.email ?? _cleared;
    } else {
      // A new link started: an older cleared address is not wanted back.
      _cleared = null;
    }
    _inner.email = value;
  }

  /// Forgets the cleared address once the sign-out or switch that cleared it
  /// went through, so a later refused transition under another account can
  /// never put this account's address back.
  void forget() => _cleared = null;

  /// Puts back the address the last clear removed, unless a newer one was
  /// stored since.
  void restore() {
    final cleared = _cleared;
    if (cleared != null && _inner.email == null) _inner.email = cleared;
    _cleared = null;
  }
}
