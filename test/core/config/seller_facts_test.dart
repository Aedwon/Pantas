import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/config/seller_facts.dart';

const _ready = SellerFacts(
  tradingName: 'Pantas Review',
  placeOfBusiness: '1 Rizal St, Quezon City',
  phone: '0917 000 0000',
);

void assertPublic(SellerFacts facts) => assertSellerFactsReady(
      facts,
      web: true,
      releaseMode: true,
      betaGate: false,
      prod: true,
    );

void main() {
  test('no facts built in leave visible brackets in the legal line', () {
    final facts = sellerFactsFromEnvironment();
    expect(
      facts.line,
      'Sold by Aerol Dwayne Daños Balayon, trading as '
      '[registered business name] · [full place of business] · '
      '[business phone] · support@pantas.study',
    );
    expect(facts.missing, [
      'SELLER_TRADING_NAME',
      'SELLER_PLACE_OF_BUSINESS',
      'SELLER_PHONE',
    ]);
  });

  test('built-in facts fill the line with no bracket', () {
    expect(
      _ready.line,
      'Sold by Aerol Dwayne Daños Balayon, trading as Pantas Review · '
      '1 Rizal St, Quezon City · 0917 000 0000 · support@pantas.study',
    );
    expect(_ready.missing, isEmpty);
    expect(_ready.lineBeforeEmail.endsWith('· '), isTrue);
  });

  test('a public release web build with a placeholder refuses to start', () {
    expect(
      () => assertPublic(sellerFactsFromEnvironment()),
      throwsA(
        isA<SellerFactsMissingException>().having(
          (e) => e.toString(),
          'message',
          allOf(contains('SELLER_PHONE'), contains('SELLER_TRADING_NAME')),
        ),
      ),
    );
    expect(
      () => assertPublic(sellerFactsFromEnvironment(phone: '0917 000 0000')),
      throwsA(isA<SellerFactsMissingException>()),
      reason: 'one placeholder is enough',
    );
  });

  test('a public release web build with every fact starts', () {
    expect(() => assertPublic(_ready), returnsNormally);
  });

  test('beta, debug, native and non-prod builds start with placeholders', () {
    final bare = sellerFactsFromEnvironment();
    void run({
      bool web = true,
      bool release = true,
      bool beta = false,
      bool prod = true,
    }) =>
        assertSellerFactsReady(
          bare,
          web: web,
          releaseMode: release,
          betaGate: beta,
          prod: prod,
        );
    expect(() => run(beta: true), returnsNormally, reason: 'beta gate on');
    expect(() => run(release: false), returnsNormally, reason: 'debug');
    expect(() => run(web: false), returnsNormally, reason: 'native');
    expect(() => run(prod: false), returnsNormally, reason: 'staging, dev');
    expect(run, throwsA(isA<SellerFactsMissingException>()));
  });
}
