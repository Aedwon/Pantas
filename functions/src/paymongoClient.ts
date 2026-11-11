const API = 'https://api.paymongo.com';

export interface CheckoutSessionInput {
  uid: string; product: string; name: string; amountCentavos: number;
  successUrl: string; cancelUrl: string; paymentMethodTypes: string[]; referenceNumber: string;
}
export interface PaymongoPayment {id: string; amount: number; currency: string; status: string; paidAt?: number}
export interface PaymongoCheckoutSession {
  id: string; status?: string; metadata: Record<string, string>; payments: PaymongoPayment[];
}
export interface PaymongoRefund {id: string; amount: number; status: string; paymentId: string}
export interface PaymongoClient {
  getRefund(id: string): Promise<PaymongoRefund>;
  createCheckoutSession(input: CheckoutSessionInput): Promise<{id: string; checkoutUrl: string}>;
  getCheckoutSession(id: string): Promise<PaymongoCheckoutSession>;
}
type Fetch = (url: string, init: {method: string; headers: Record<string, string>; body?: string}) =>
  Promise<{ok: boolean; status: number; json(): Promise<unknown>}>;

const obj = (v: unknown): Record<string, unknown> =>
  v !== null && typeof v === 'object' && !Array.isArray(v) ? v as Record<string, unknown> : {};

/** Secret key as the Basic auth username with an empty password. */
export function httpPaymongoClient(secretKey: string, fetchImpl: Fetch = fetch as unknown as Fetch): PaymongoClient {
  const headers = {
    Authorization: `Basic ${Buffer.from(`${secretKey}:`).toString('base64')}`,
    'Content-Type': 'application/json',
  };
  return {
    async createCheckoutSession(input) {
      const response = await fetchImpl(`${API}/v2/checkout_sessions`, {method: 'POST', headers,
        body: JSON.stringify({data: {attributes: {
          line_items: [{name: input.name, amount: input.amountCentavos, currency: 'PHP', quantity: 1}],
          payment_method_types: input.paymentMethodTypes,
          success_url: input.successUrl, cancel_url: input.cancelUrl,
          reference_number: input.referenceNumber,
          metadata: {uid: input.uid, product: input.product, reference: input.referenceNumber},
        }}})});
      if (!response.ok) throw new Error(`PayMongo checkout create failed: ${response.status}`);
      const data = obj(obj(await response.json()).data);
      const url = obj(data.attributes).checkout_url;
      if (typeof data.id !== 'string' || typeof url !== 'string' || !url.startsWith('https://')) {
        throw new Error('PayMongo checkout create returned no checkout URL');
      }
      return {id: data.id, checkoutUrl: url};
    },
    async getRefund(id) {
      if (!/^[A-Za-z0-9_]+$/.test(id)) throw new Error('Invalid refund id');
      const response = await fetchImpl(`${API}/v1/refunds/${id}`, {method: 'GET', headers});
      if (!response.ok) throw new Error(`PayMongo refund read failed: ${response.status}`);
      const data = obj(obj(await response.json()).data);
      const a = obj(data.attributes);
      if (data.id !== id) throw new Error('PayMongo returned a different refund');
      return {id, amount: Number(a.amount), status: String(a.status ?? ''), paymentId: String(a.payment_id ?? '')};
    },
    async getCheckoutSession(id) {
      if (!/^[A-Za-z0-9_]+$/.test(id)) throw new Error('Invalid checkout session id');
      const response = await fetchImpl(`${API}/v1/checkout_sessions/${id}`, {method: 'GET', headers});
      if (!response.ok) throw new Error(`PayMongo checkout read failed: ${response.status}`);
      const data = obj(obj(await response.json()).data);
      if (data.id !== id) throw new Error('PayMongo returned a different checkout session');
      const attributes = obj(data.attributes);
      const metadata: Record<string, string> = {};
      for (const [k, v] of Object.entries(obj(attributes.metadata))) if (typeof v === 'string') metadata[k] = v;
      const top = Array.isArray(attributes.payments) ? attributes.payments : [];
      const nested = obj(obj(attributes.payment_intent).attributes).payments;
      const payments = (top.length > 0 ? top : Array.isArray(nested) ? nested : []).map(p => {
        const payment = obj(p), a = obj(payment.attributes);
        return {id: String(payment.id ?? ''), amount: Number(a.amount), currency: String(a.currency ?? ''),
          status: String(a.status ?? ''), ...(typeof a.paid_at === 'number' ? {paidAt: a.paid_at * 1000} : {})};
      });
      return {id, status: String(attributes.status ?? ''), metadata, payments};
    },
  };
}
