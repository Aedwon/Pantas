import type { RevenueCatAccessSource } from './revenuecatPolicy.js';

type Json = Record<string, unknown>;
type Fetch = (url: string, options: {headers: Record<string, string>}) => Promise<{
  ok: boolean; status?: number; json(): Promise<unknown>;
}>;

function object(value: unknown): Json {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('Invalid RevenueCat object');
  }
  return value as Json;
}
function string(value: unknown): string {
  if (typeof value !== 'string' || value.length === 0) throw new Error('Invalid RevenueCat identifier');
  return value;
}

function api(projectId: string, secret: string, fetcher: Fetch) {
  const base = `https://api.revenuecat.com/v2/projects/${encodeURIComponent(projectId)}/`;
  async function get(value: string): Promise<Json> {
    const url = new URL(value, 'https://api.revenuecat.com').href;
    if (!url.startsWith(base)) throw new Error('Invalid RevenueCat resource');
    const response = await fetcher(url, {headers: {Authorization: `Bearer ${secret}`}});
    if (!response.ok) throw new Error(`RevenueCat read failed: ${response.status}`);
    return object(await response.json());
  }
  async function list(value: unknown, seen = new Set<string>()): Promise<Json[]> {
    let page: Json;
    if (typeof value === 'string') {
      const url = new URL(value, 'https://api.revenuecat.com').href;
      if (!url.startsWith(base) || seen.has(url)) throw new Error('Invalid RevenueCat pagination');
      seen.add(url);
      page = await get(url);
    } else page = object(value);
    if (!Array.isArray(page.items)) throw new Error('Invalid RevenueCat list');
    const items = page.items.map(object);
    return page.next_page ? [...items, ...await list(page.next_page, seen)] : items;
  }
  return {base, get, list};
}

/** No SDK cache or event expiry grants. */
export async function readRevenueCatCustomer(
  projectId: string, uid: string, secret: string, fetcher: Fetch = fetch,
): Promise<RevenueCatAccessSource[]> {
  const {base, list} = api(projectId, secret, fetcher);
  const subscriptions = await list(`${base}customers/${encodeURIComponent(uid)}/subscriptions?limit=100`);
  const sources: RevenueCatAccessSource[] = [];
  for (const subscription of subscriptions) {
    if (typeof subscription.gives_access !== 'boolean') throw new Error('Invalid RevenueCat access');
    const entitlements = await list(subscription.entitlements);
    const entitlementIds = entitlements.map(e => string(e.lookup_key));
    const end = subscription.ends_at ?? subscription.current_period_ends_at;
    if (subscription.gives_access && (typeof end !== 'number' || !Number.isSafeInteger(end))) {
      throw new Error('Missing RevenueCat expiry');
    }
    const endsAt = typeof end === 'number' ? end : 0;
    const environment = string(subscription.environment);
    const store = string(subscription.store);
    if (store === 'promotional') {
      sources.push({productId:null,appId:null,entitlementIds,store,
        environment,endsAt,active:subscription.gives_access});
      continue;
    }
    let product: Json | undefined;
    for (const entitlement of entitlements) {
      if (entitlement.products) {
        product ??= (await list(entitlement.products)).find(p => p.id === subscription.product_id);
      }
    }
    if (subscription.gives_access && !product) throw new Error('Missing RevenueCat store-product mapping');
    sources.push({productId:product ? string(product.store_identifier) : null,
      appId:product ? string(product.app_id) : null, entitlementIds,environment,store,
      endsAt,active:subscription.gives_access});
  }
  return sources;
}

export interface RevenueCatPurchase {
  transactionId: string; customerId: string; productId: string | null; purchasedAt: number;
  status: 'owned' | 'refunded'; appId: string | null; environment: string; store: string;
}

export async function readRevenueCatPurchases(projectId: string, uid: string,
  secret: string, fetcher: Fetch = fetch): Promise<RevenueCatPurchase[]> {
  const {base, get, list} = api(projectId, secret, fetcher);
  const customer = await get(`${base}customers/${encodeURIComponent(uid)}`);
  const canonicalId = string(customer.id);
  const purchases = await list(`${base}customers/${encodeURIComponent(uid)}/purchases?limit=100`);
  const result: RevenueCatPurchase[] = [];
  for (const purchase of purchases) {
    const productId = string(purchase.product_id);
    let product: Json | undefined;
    const entitlements = await list(purchase.entitlements);
    for (const entitlement of entitlements) {
      if (entitlement.products) {
        product ??= (await list(entitlement.products)).find(p => p.id === productId);
      }
    }
    // Refunded records can lose their entitlement association. No granting
    // source is emitted; existing ledger records become revoked in the full
    // current-state reconciliation. P1 never needs a broader product API key.
    if (purchase.status === 'owned' && !product) throw new Error('Missing RevenueCat purchase mapping');
    if (purchase.status !== 'owned' && purchase.status !== 'refunded') {
      throw new Error('Invalid RevenueCat purchase status');
    }
    if (typeof purchase.purchased_at !== 'number' || !Number.isSafeInteger(purchase.purchased_at)) {
      throw new Error('Invalid RevenueCat purchase time');
    }
    const transactionId = purchase.store_purchase_identifier;
    if (typeof transactionId !== 'string' && typeof transactionId !== 'number') {
      throw new Error('Missing RevenueCat store transaction');
    }
    const owner = string(purchase.customer_id);
    result.push({transactionId:String(transactionId), customerId:owner === canonicalId ? uid : owner,
      productId:product ? string(product.store_identifier) : null, purchasedAt:purchase.purchased_at,
      status:purchase.status, appId:product ? string(product.app_id) : null,
      environment:string(purchase.environment), store:string(purchase.store)});
  }
  return result;
}
