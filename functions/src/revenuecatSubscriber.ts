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
  if (typeof value !== 'string') throw new Error('Invalid RevenueCat identifier');
  return value;
}

/** V2 customer-information permission only. No SDK cache or event expiry grants. */
export async function readRevenueCatCustomer(
  projectId: string, uid: string, secret: string, fetcher: Fetch = fetch,
): Promise<RevenueCatAccessSource[]> {
  const base = `https://api.revenuecat.com/v2/projects/${encodeURIComponent(projectId)}/`;
  async function list(value: unknown, seen = new Set<string>()): Promise<Json[]> {
    let page: Json;
    if (typeof value === 'string') {
      const url = new URL(value, 'https://api.revenuecat.com').href;
      if (!url.startsWith(base) || seen.has(url)) throw new Error('Invalid RevenueCat pagination');
      seen.add(url);
      const response = await fetcher(url, {headers: {Authorization: `Bearer ${secret}`}});
      if (!response.ok) throw new Error(`RevenueCat read failed: ${response.status}`);
      page = object(await response.json());
    } else page = object(value);
    if (!Array.isArray(page.items)) throw new Error('Invalid RevenueCat list');
    const items = page.items.map(object);
    return page.next_page ? [...items, ...await list(page.next_page, seen)] : items;
  }
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
