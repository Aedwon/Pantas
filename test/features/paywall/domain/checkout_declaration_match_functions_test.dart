import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/paywall/domain/checkout_declaration.dart';

void main() {
  test('app and functions use the same checkout wording ids', () {
    final source = File('functions/src/paymongoCheckout.ts').readAsStringSync();
    final block = RegExp(
      r'CHECKOUT_DECLARATION_WORDING\s*=\s*\{([^}]*)\}',
    ).firstMatch(source);
    expect(block, isNotNull);
    final functionsIds = {
      for (final m
          in RegExp(r"(\w+):\s*'([^']+)'").allMatches(block!.group(1)!))
        m.group(1)!: m.group(2)!,
    };
    expect(functionsIds, checkoutDeclarationWording);
    expect(checkoutDeclarationWording.length, 2);
  });

  test('the wording is the legal lane text of the Nov 23 pass', () {
    expect(
      declarationLabel(DeclarationKind.adult),
      "I'm 18+, authorized to use the payment method, and accept the "
      'Terms and refund policy.',
    );
    expect(
      declarationLabel(DeclarationKind.guardian),
      "I'm 18+ and buying for this student as their parent or legal "
      "guardian. I'm authorized to use the payment method and accept the "
      'Terms and refund policy.',
    );
  });
}
