/// Builds the public landing-page URL for a shared Wrapped card.
///
/// The card image and QR code bake this URL in before upload, so the hosted
/// image matches what is posted to social (landing-page spec §3.1).
class WrappedShareUrl {
  const WrappedShareUrl._();

  /// Base of every Wrapped share link.
  static const String base = 'https://pantas.study/wrapped';

  /// Returns `https://pantas.study/wrapped/<shareId>`.
  static String forShareId(String shareId) => '$base/$shareId';
}
