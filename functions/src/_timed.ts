import {logger} from 'firebase-functions';
import {HttpsError, type CallableRequest} from 'firebase-functions/v2/https';

// Also matches an HttpsError from another copy of the package, which `instanceof` misses.
function httpsErrorCode(error: unknown): string | undefined {
  if (error instanceof HttpsError) return error.code;
  const code = (error as {code?: unknown} | null)?.code;
  return error instanceof Error && 'httpErrorCode' in error && typeof code === 'string' ? code : undefined;
}

/**
 * Wraps a callable's handler so every call writes one `fn_timing` log line: which function,
 * how long, whether it was the first call on this instance (a cold start), and the outcome.
 * The line holds no uid, email, token or request data. Errors are rethrown unchanged.
 */
export function timed<T = any, R = unknown>(
  fn: string,
  handler: (request: CallableRequest<T>) => R | Promise<R>,
  deps: {log?: (message: string, fields: Record<string, unknown>) => void; now?: () => number} = {},
): (request: CallableRequest<T>) => Promise<R> {
  const log = deps.log ?? ((message, fields) => logger.info(message, fields));
  const now = deps.now ?? (() => performance.now());
  let cold = true;
  return async request => {
    const isCold = cold;
    cold = false;
    const start = now();
    let outcome: 'ok' | 'error' = 'ok';
    let code: string | undefined;
    try {
      return await handler(request);
    } catch (error) {
      outcome = 'error';
      code = httpsErrorCode(error);
      throw error;
    } finally {
      try {
        log('fn_timing', {
          kind: 'fn_timing', fn, ms: Math.round(now() - start), cold: isCold, outcome, ...(code ? {code} : {}),
        });
      } catch {
        // Timing must never change what the caller receives.
      }
    }
  };
}
