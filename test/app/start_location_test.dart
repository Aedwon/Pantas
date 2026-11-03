import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/start_location.dart';

/// The router's first location for [address] opened in a browser.
String webStart(String address) => startLocationFor(
      Uri.parse('https://app.example.test$address'),
      isWeb: true,
    );

void main() {
  tearDown(forgetStartLocation);

  test('with nothing remembered the app starts at Home', () {
    expect(initialRouterLocation, '/home');
  });

  group('the address is honored', () {
    test('for pages that are safe to open or reload', () {
      for (final address in [
        '/home',
        '/study',
        '/quiz',
        '/settings',
        '/settings/practice',
        '/settings/exam/change',
        '/settings/account/name',
        '/settings/about',
        '/plan/day/2026-11-03',
        '/performance/topic/t1',
        '/lesson/lesson-1',
        '/lesson/lesson-1?from=study',
        '/quiz/today/cse',
        '/quiz/resume/cse',
        '/quiz/practice/cse',
        '/quiz/viewer/a1?index=2',
        '/quiz/mock/custom-setup',
        '/quiz/mock/resume/m1?examId=cse',
        '/mock/results/m1',
        '/mock/review/m1',
        '/assessment/cse/results',
        '/onboarding',
        '/guardian/waiting',
        '/update-required',
        '/legal/terms',
        '/legal/privacy',
      ]) {
        expect(webStart(address), address, reason: address);
      }
    });

    test('for the guardian link, with its token', () {
      expect(webStart('/guardian?token=abc'), '/guardian?token=abc');
    });

    test('for the payment return, with its whole query', () {
      const pro = '/pro?checkout=success&ref=pm_123';
      const settingsPro = '/settings/pro?checkout=cancelled&ref=pm_9';
      expect(webStart(pro), pro);
      expect(webStart(settingsPro), settingsPro);
    });

    test('with the query unchanged and the fragment dropped', () {
      expect(
        webStart('/study?topicId=t1&search=a%20b#top'),
        '/study?topicId=t1&search=a%20b',
      );
      expect(webStart('/settings#about'), '/settings');
    });

    test('for a trailing slash, keeping the address as typed', () {
      expect(webStart('/settings/'), '/settings/');
    });

    test('for an address that matches no route, so the router decides', () {
      expect(webStart('/guardianship'), '/guardianship');
      expect(webStart('/nowhere/at/all'), '/nowhere/at/all');
    });
  });

  group('the address starts at Home', () {
    test('for the root, an empty path and a doubled slash', () {
      expect(webStart('/'), '/home');
      expect(webStart(''), '/home');
      expect(webStart('//'), '/home');
      expect(webStart('//evil.example/home'), '/home');
      expect(webStart('//settings'), '/home');
    });

    test('for a wrapped reveal, which nothing links to', () {
      expect(webStart('/wrapped/w1'), '/home');
      expect(webStart('/wrapped/w1?x=1'), '/home');
    });

    test('for an assessment that is not the results page', () {
      expect(webStart('/assessment/cse'), '/home');
      expect(webStart('/assessment/cse/'), '/home');
    });
  });

  group('the address starts at its parent', () {
    final mapped = <String, String>{
      '/study/ending/t1': '/study',
      '/quiz/quick/cse': '/quiz',
      '/quiz/retake/cse': '/quiz',
      '/quiz/inline/cse/lesson-1': '/quiz',
      '/quiz/practice/cse/run': '/quiz/practice/cse',
      '/quiz/mock/start?examId=cse&blueprintId=b1&strict=1': '/quiz',
      '/quiz/mock/setup': '/quiz',
      '/quiz/mock/setup?examId=': '/quiz',
      '/quiz/mock/setup?other=1': '/quiz',
      '/settings/exam/upgrade?target=upcat': '/settings/exam/change',
      '/settings/account/delete': '/settings/account',
      '/settings/_debug': '/settings',
      '/settings/_gallery': '/settings',
      '/onboarding/custom/name': '/onboarding',
      '/onboarding/custom/subjects?name=x': '/onboarding',
      '/guardian/contact': '/guardian/waiting',
    };

    for (final entry in mapped.entries) {
      test(entry.key, () => expect(webStart(entry.key), entry.value));
    }

    test('the mock setup keeps its address when it names an exam', () {
      expect(
        webStart('/quiz/mock/setup?examId=cse'),
        '/quiz/mock/setup?examId=cse',
      );
    });

    test('the practice run keeps the exam id with its original case', () {
      expect(webStart('/quiz/practice/CSE-1/run'), '/quiz/practice/CSE-1');
    });
  });

  group('a bypass attempt does not reach a page that is not honored', () {
    test('by a trailing slash', () {
      expect(webStart('/quiz/retake/cse/'), '/quiz');
      expect(webStart('/settings/account/delete/'), '/settings/account');
      expect(webStart('/quiz/mock/start/'), '/quiz');
    });

    test('by letter case', () {
      expect(webStart('/QUIZ/Retake/cse'), '/quiz');
      expect(webStart('/Settings/Account/DELETE'), '/settings/account');
      expect(webStart('/Wrapped/w1'), '/home');
    });

    test('by percent-encoding', () {
      expect(webStart('/quiz/%72etake/cse'), '/quiz');
      expect(webStart('/%71uiz/quick/cse'), '/quiz');
      expect(webStart('/settings/account/%64elete'), '/settings/account');
      expect(webStart('/quiz/practice/cse/%72un'), '/quiz/practice/cse');
    });

    test('by an encoded slash', () {
      expect(webStart('/quiz%2Fretake%2Fcse'), '/quiz');
      expect(webStart('/settings%2Faccount%2Fdelete'), '/settings/account');
    });

    test('by empty segments', () {
      expect(webStart('/quiz//retake/cse'), '/quiz');
      expect(webStart('//quiz/retake/cse'), '/home');
      expect(webStart('/settings///account//delete'), '/settings/account');
    });

    test('by dot segments', () {
      expect(webStart('/settings/../quiz/retake/cse'), '/quiz');
      expect(webStart('/settings/%2e%2e/quiz/retake/cse'), '/quiz');
    });

    test('by a query or fragment on the same path', () {
      expect(webStart('/quiz/retake/cse?x=1#y'), '/quiz');
      expect(webStart('/quiz/mock/start?examId=a&blueprintId=b'), '/quiz');
    });
  });

  test('a malformed escape never throws', () {
    expect(webStart('/quiz/%zz'), '/quiz/%25zz');
    expect(
      webStart('/quiz/mock/setup?examId=%zz'),
      '/quiz/mock/setup?examId=%25zz',
    );
  });

  test('the remembered address is the one the router starts at', () {
    rememberStartLocation(
      Uri.parse('https://app.example.test/settings/about'),
      isWeb: true,
    );
    expect(initialRouterLocation, '/settings/about');
    rememberStartLocation(
      Uri.parse('https://app.example.test/quiz/retake/cse'),
      isWeb: true,
    );
    expect(initialRouterLocation, '/quiz');
  });

  test('a native build always starts at Home', () {
    for (final address in [
      '/guardian?token=abc',
      '/settings/about',
      '/quiz/retake/cse',
      '/legal/terms',
    ]) {
      final url = Uri.parse('https://app.example.test$address');
      expect(startLocationFor(url, isWeb: false), '/home', reason: address);
      rememberStartLocation(url, isWeb: false);
      expect(initialRouterLocation, '/home', reason: address);
    }
  });
}
