/// Who sells Pantas Pro on the web (Internet Transactions Act and Consumer
/// Act duties; ruling D3). The facts are build inputs, passed with
/// `--dart-define=SELLER_TRADING_NAME=...`, `SELLER_PLACE_OF_BUSINESS=...` and
/// `SELLER_PHONE=...`. They belong to Aedwon. A missing fact shows as a visible
/// bracket, and a public release build refuses to start while one remains.
const sellerProprietor = 'Aerol Dwayne Daños Balayon';
const sellerEmail = 'support@pantas.study';

const _placeholderTradingName = '[registered business name]';
const _placeholderPlace = '[full place of business]';
const _placeholderPhone = '[business phone]';

class SellerFacts {
  const SellerFacts({
    required this.tradingName,
    required this.placeOfBusiness,
    required this.phone,
  });

  final String tradingName;
  final String placeOfBusiness;
  final String phone;

  /// The line beside Pay, in the legal lane's Nov 23 wording.
  String get line => 'Sold by $sellerProprietor, trading as $tradingName'
      ' · $placeOfBusiness · $phone · $sellerEmail';

  /// The words in front of the email address, for the mail link.
  String get lineBeforeEmail =>
      line.substring(0, line.length - sellerEmail.length);

  /// Names of the facts still missing or still a bracket.
  List<String> get missing => [
        if (_missing(tradingName)) 'SELLER_TRADING_NAME',
        if (_missing(placeOfBusiness)) 'SELLER_PLACE_OF_BUSINESS',
        if (_missing(phone)) 'SELLER_PHONE',
      ];

  /// A bracket or an angle-bracket placeholder (the deploy guide's `<...>`)
  /// is not a fact.
  bool _missing(String value) =>
      value.trim().isEmpty ||
      value.contains('[') ||
      RegExp('<[^>]*>').hasMatch(value);
}

/// The facts this build was made with. A missing one stays a bracket.
SellerFacts sellerFactsFromEnvironment({
  String tradingName = const String.fromEnvironment('SELLER_TRADING_NAME'),
  String place = const String.fromEnvironment('SELLER_PLACE_OF_BUSINESS'),
  String phone = const String.fromEnvironment('SELLER_PHONE'),
}) =>
    SellerFacts(
      tradingName: tradingName.trim().isEmpty
          ? _placeholderTradingName
          : tradingName.trim(),
      placeOfBusiness: place.trim().isEmpty ? _placeholderPlace : place.trim(),
      phone: phone.trim().isEmpty ? _placeholderPhone : phone.trim(),
    );

final sellerFacts = sellerFactsFromEnvironment();

/// Thrown when a public production web release build has a seller fact that is
/// still a placeholder. The seller line is a legal duty at checkout, so such a
/// build cannot be used. Failing at startup names the cause.
class SellerFactsMissingException implements Exception {
  const SellerFactsMissingException(this.missing);
  final List<String> missing;

  String get message => 'This public web build has no seller facts: '
      '${missing.join(', ')}. Rebuild with --dart-define=NAME=<value> '
      'for each.';

  @override
  String toString() => 'SellerFactsMissingException: $message';
}

/// Refuses a public build that would show a placeholder beside Pay. Public
/// means the prod web build made without BETA_GATE. A beta, debug, profile,
/// native or non-prod build passes: the seller line is a web-checkout duty.
void assertSellerFactsReady(
  SellerFacts facts, {
  required bool web,
  required bool releaseMode,
  required bool betaGate,
  required bool prod,
}) {
  if (!web || !releaseMode || betaGate || !prod) return;
  final missing = facts.missing;
  if (missing.isNotEmpty) throw SellerFactsMissingException(missing);
}
