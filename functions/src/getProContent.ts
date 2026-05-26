import { HttpsError, onCall } from 'firebase-functions/v2/https';

export const getProContent = onCall(
  {
    region: 'asia-southeast1',
    enforceAppCheck: true,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in is required.');
    }
    if (request.auth.token.pro !== true) {
      throw new HttpsError('permission-denied', 'Pro is required.');
    }
    if (request.auth.token.pro === true) {
      const doctype = String(request.data?.doctype ?? '');
      return {
        query: buildProContentQuery(doctype),
        projectId: process.env.SANITY_PROJECT_ID ?? null,
        dataset: process.env.SANITY_DATASET ?? null,
        hasToken: Boolean(process.env.SANITY_READ_TOKEN),
      };
    }
    throw new HttpsError('permission-denied', 'Pro is required.');
  },
);

export function buildProContentQuery(doctype: string): string {
  return `*[_type == "${doctype}" && pro == true]`;
}
