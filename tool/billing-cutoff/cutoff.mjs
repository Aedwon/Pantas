// Automatic billing cutoff. Removes the billing account from one project when its budget is
// exceeded or a usage alarm opens. Based on Google's sample:
// https://docs.cloud.google.com/billing/docs/how-to/disable-billing-with-notifications
//
// Approved by Aedwon on Nov 14, 2026 (launch log, "security fixes and billing cap"). Removing
// billing takes the whole project offline until someone relinks it by hand; see
// docs/deploy-prod.md, "Billing cutoff".
//
// Environment:
//   PROJECT_ID           the project to cut (also where the function runs)
//   BUDGET_ID            only this budget's messages count
//   ALERT_POLICY_PREFIX  only usage alarms whose policy name starts with this count
//   DRY_RUN              anything but exactly "false" means log only, never cut

const read = message => {
  try {
    return JSON.parse(Buffer.from(message?.data ?? '', 'base64').toString());
  } catch {
    return null;
  }
};

/** Whether one Pub/Sub message should cut billing, and why. Pure, so it is tested directly. */
export function decide(message, env) {
  const body = read(message);
  if (!body || typeof body !== 'object') return {act: false, why: 'unreadable message'};
  if (body.incident) {
    const policy = String(body.incident.policy_name ?? '');
    if (!env.ALERT_POLICY_PREFIX || !policy.startsWith(env.ALERT_POLICY_PREFIX)) return {act: false, why: `alarm from another policy: ${policy}`};
    if (body.incident.state !== 'open') return {act: false, why: `alarm ${body.incident.state}`};
    return {act: true, why: `usage alarm open: ${policy}`};
  }
  const budgetId = message.attributes?.budgetId;
  if (!env.BUDGET_ID || budgetId !== env.BUDGET_ID) return {act: false, why: `message from another budget: ${budgetId}`};
  const cost = Number(body.costAmount);
  const amount = Number(body.budgetAmount);
  if (!Number.isFinite(cost) || !Number.isFinite(amount)) return {act: false, why: 'budget message without amounts'};
  if (cost <= amount) return {act: false, why: `cost ${cost} within budget ${amount}`};
  return {act: true, why: `cost ${cost} over budget ${amount}`};
}

/** Handles one message. `billing` does the Cloud Billing calls, so tests can fake them. */
export async function handle(message, env, billing, log = console.log) {
  const {act, why} = decide(message, env);
  log(JSON.stringify({severity: act ? 'WARNING' : 'INFO', message: `billing cutoff: ${why}`}));
  if (!act) return 'no action';
  if (env.DRY_RUN !== 'false') {
    log(JSON.stringify({severity: 'WARNING', message: `billing cutoff DRY RUN: would disable billing on ${env.PROJECT_ID}`}));
    return 'dry run: would disable billing';
  }
  // A failed read must never stop the cut: removing billing twice is harmless.
  const info = await billing.getBillingInfo(env.PROJECT_ID).catch(error => {
    log(JSON.stringify({severity: 'WARNING', message: `billing cutoff: could not read billing state (${error.message}); cutting anyway`}));
    return {billingEnabled: true};
  });
  if (!info.billingEnabled) return 'billing already disabled';
  await billing.disableBilling(env.PROJECT_ID);
  log(JSON.stringify({severity: 'ERROR', message: `billing cutoff: billing DISABLED on ${env.PROJECT_ID}`}));
  return 'billing disabled';
}

/** Cloud Billing REST calls with the function's own service account token. */
export function cloudBilling(fetchImpl = fetch) {
  const token = async () => {
    const response = await fetchImpl('http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token',
      {headers: {'Metadata-Flavor': 'Google'}});
    return (await response.json()).access_token;
  };
  const call = async (project, init = {}) => {
    const response = await fetchImpl(`https://cloudbilling.googleapis.com/v1/projects/${project}/billingInfo`,
      {...init, headers: {Authorization: `Bearer ${await token()}`, 'Content-Type': 'application/json'}});
    if (!response.ok) throw new Error(`Cloud Billing ${response.status}: ${await response.text()}`);
    return response.json();
  };
  return {
    getBillingInfo: project => call(project),
    disableBilling: project => call(project, {method: 'PUT', body: JSON.stringify({billingAccountName: ''})}),
  };
}
