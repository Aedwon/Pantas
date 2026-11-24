import 'package:pantas/features/legal/domain/legal_document.dart';

/// Which wording the web checkout shows beside Pay. The server decides: a
/// guardian wording only for an account with a confirmed guardian.
enum DeclarationKind { adult, guardian }

/// Wording ids sent with the declaration and stored on the order, so the text
/// a buyer saw can be found later. A new wording gets a new id, in the same
/// release. Keep equal to `CHECKOUT_DECLARATION_WORDING` in
/// `functions/src/paymongoCheckout.ts`; a test compares them.
const checkoutDeclarationWording = <String, String>{
  'adult': 'checkout-adult-2026-11-23',
  'guardian': 'checkout-guardian-2026-11-23',
};

/// The words before the Terms link, from the legal lane's Nov 23 pass.
String declarationLead(DeclarationKind kind) => switch (kind) {
      DeclarationKind.adult =>
        "I'm 18+, authorized to use the payment method, and accept the ",
      DeclarationKind.guardian =>
        "I'm 18+ and buying for this student as their parent or legal "
            "guardian. I'm authorized to use the payment method and accept "
            'the ',
    };

const declarationLink = 'Terms and refund policy';
const declarationTail = '.';

String declarationLabel(DeclarationKind kind) =>
    '${declarationLead(kind)}$declarationLink$declarationTail';

/// What the buyer ticked. Sent with the checkout request.
class CheckoutDeclaration {
  const CheckoutDeclaration(this.kind);
  final DeclarationKind kind;

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'wordingVersion': checkoutDeclarationWording[kind.name],
        'termsVersion': guardianDocumentVersions['terms'],
      };
}
