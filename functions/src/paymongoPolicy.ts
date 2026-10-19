import {createHmac, timingSafeEqual} from 'node:crypto';
import {readFileSync} from 'node:fs';
import {join} from 'node:path';
import type {PriceTier} from './revenuecatCoverage.js';

export type Prepaid = {unit: 'days' | 'months' | 'years'; count: number} | {unit: 'sitting'};
export interface WebProduct {id: string; tier: PriceTier; kind: 'subscription' | 'pass';
  examId: string | null; webPricePhp: number; prepaid: Prepaid}
type Row = Partial<WebProduct> & {id: string; kind: string; tier: PriceTier};
const rows = JSON.parse(readFileSync(join(__dirname, 'products.json'), 'utf8')) as Row[];

/** Only products with a web price and a prepaid length can be sold on the web. */
export function webProduct(id: unknown): WebProduct | undefined {
  const row = rows.find(r => r.id === id);
  if (!row || (row.kind !== 'subscription' && row.kind !== 'pass') ||
      !Number.isInteger(row.webPricePhp) || !row.webPricePhp || row.webPricePhp <= 0 || !row.prepaid) return undefined;
  return row as WebProduct;
}
export const webProductIds = (): string[] => rows.filter(r => webProduct(r.id)).map(r => r.id);
export const priceCentavos = (product: WebProduct): number => product.webPricePhp * 100;

const PH_OFFSET_MS = 8 * 60 * 60 * 1000;
const DAY_MS = 86_400_000;

/**
 * Adds a prepaid length in Philippine time (UTC+8, no daylight saving). Months and
 * years keep the same calendar date and time of day, clamped to the last day of the
 * target month (January 31 plus one month is February 28, or 29 in a leap year).
 */
export function addPrepaid(from: number, prepaid: Prepaid): number {
  if (prepaid.unit === 'sitting') throw new Error('A pass ends at its sitting, not after a length');
  if (!Number.isInteger(prepaid.count) || prepaid.count <= 0) throw new Error('Invalid prepaid length');
  if (prepaid.unit === 'days') return from + prepaid.count * DAY_MS;
  const local = new Date(from + PH_OFFSET_MS);
  const months = local.getUTCMonth() + (prepaid.unit === 'months' ? prepaid.count : prepaid.count * 12);
  const year = local.getUTCFullYear() + Math.floor(months / 12);
  const month = months % 12;
  const lastDay = new Date(Date.UTC(year, month + 1, 0)).getUTCDate();
  return Date.UTC(year, month, Math.min(local.getUTCDate(), lastDay), local.getUTCHours(),
    local.getUTCMinutes(), local.getUTCSeconds(), local.getUTCMilliseconds()) - PH_OFFSET_MS;
}

const HEX64 = /^[0-9a-f]{64}$/i;
export const PAYMONGO_SIGNATURE_TOLERANCE_MS = 300_000;

/**
 * Paymongo-Signature: `t=<unix seconds>,te=<hex>,li=<hex>`. HMAC-SHA256 over
 * `<t>.<raw body>` with the webhook secret. `te` signs test events and `li` live
 * events, and the other part is empty. The part for the expected mode must match.
 */
export function verifyPaymongoSignature(rawBody: Buffer, header: string, secret: string,
  livemode: boolean, now = Date.now()): boolean {
  if (!header || !secret || !Buffer.isBuffer(rawBody)) return false;
  const parts = new Map<string, string>();
  for (const piece of header.split(',')) {
    const at = piece.indexOf('=');
    if (at <= 0) return false;
    const key = piece.slice(0, at).trim();
    if (parts.has(key)) return false;
    parts.set(key, piece.slice(at + 1).trim());
  }
  const t = parts.get('t');
  if (!t || !/^\d+$/.test(t)) return false;
  const signedAt = Number(t) * 1000;
  if (!Number.isSafeInteger(signedAt) || Math.abs(now - signedAt) > PAYMONGO_SIGNATURE_TOLERANCE_MS) return false;
  const candidate = parts.get(livemode ? 'li' : 'te');
  if (!candidate || !HEX64.test(candidate)) return false;
  const expected = createHmac('sha256', secret).update(Buffer.from(`${t}.`)).update(rawBody).digest();
  const actual = Buffer.from(candidate, 'hex');
  return actual.length === expected.length && timingSafeEqual(expected, actual);
}

export interface PaymongoEvent {id: string; type: string; livemode: boolean; data: Record<string, unknown>}

const text = (v: unknown): string | null => typeof v === 'string' && v.trim() ? v.trim() : null;
const record = (v: unknown): Record<string, unknown> | null =>
  v !== null && typeof v === 'object' && !Array.isArray(v) ? v as Record<string, unknown> : null;

/** Envelope: data.id, data.attributes.type, .livemode and .data (the resource). */
export function normalizePaymongoEvent(body: unknown): PaymongoEvent | null {
  const event = record(record(body)?.data);
  const attributes = record(event?.attributes);
  if (!event || !attributes) return null;
  const id = text(event.id), type = text(attributes.type), data = record(attributes.data);
  if (!id || !type || !data || typeof attributes.livemode !== 'boolean') return null;
  if (id.includes('/') || id.length > 128) return null;
  return {id, type, livemode: attributes.livemode, data};
}
