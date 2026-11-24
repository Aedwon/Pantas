import {CHECKOUT_DECLARATION_WORDING} from '../lib/paymongoCheckout.js';
import {GUARDIAN_DOCUMENT_VERSIONS} from '../lib/guardianConsent.js';

/** The declaration the client sends for a given kind, built from the server's own current versions. */
export const declarationOf = (kind = 'adult') => ({
  kind, wordingVersion: CHECKOUT_DECLARATION_WORDING[kind], termsVersion: GUARDIAN_DOCUMENT_VERSIONS.terms});
export const adult = declarationOf('adult');
export const guardian = declarationOf('guardian');
