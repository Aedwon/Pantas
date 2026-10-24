import {HttpsError, onCall} from 'firebase-functions/v2/https';
import {allowAtMost} from './_limits.js';
import {priceCentavos, webProduct, webProductIds, type Prepaid} from './paymongoPolicy.js';
import {examCatalog, sittingFor, type CatalogExam} from './revenuecatPasses.js';

/** One web plan. The price is the one checkout charges, from products.json. */
export type WebPlan = {product: string; priceCentavos: number; priceString: string;
  prepaid: Prepaid; examId: string | null};

export type PlansDeps = {allow?: (uid: string) => Promise<boolean>; catalog?: CatalogExam[]; now?: () => number};

const LISTS_PER_WINDOW = 30;
const WINDOW_MS = 10 * 60_000;

/** Pesos with thousands separators and two decimals, for example 119900 is ₱1,199.00. */
export function formatPesos(centavos: number): string {
  const pesos = Math.trunc(centavos / 100).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  return `₱${pesos}.${String(centavos % 100).padStart(2, '0')}`;
}

/**
 * The web plans the client may show. Any signed-in account may ask, anonymous
 * included, so the Pro page can show prices before sign-up. A pass is left out when no
 * sitting is published, because checkout would refuse it.
 */
export async function listPlans(auth: {uid: string} | undefined, deps: PlansDeps = {}):
  Promise<{plans: WebPlan[]}> {
  if (!auth) throw new HttpsError('unauthenticated', 'Authentication is required.');
  const now = (deps.now ?? Date.now)();
  const allowed = await (deps.allow ?? (id => allowAtMost(id, 'webPlans', LISTS_PER_WINDOW, WINDOW_MS)))(auth.uid);
  if (!allowed) throw new HttpsError('resource-exhausted', 'Too many requests. Try again later.');
  const plans: WebPlan[] = [];
  for (const id of webProductIds()) {
    const product = webProduct(id)!;
    if (product.prepaid.unit === 'sitting' &&
        (!product.examId || !sittingFor(deps.catalog ?? examCatalog, product.examId, now))) continue;
    const cents = priceCentavos(product);
    plans.push({product: product.id, priceCentavos: cents, priceString: formatPesos(cents),
      prepaid: product.prepaid, examId: product.kind === 'pass' ? product.examId : null});
  }
  return {plans};
}

export const listWebPlans = onCall({region: 'asia-southeast1', enforceAppCheck: true},
  request => listPlans(request.auth));
