/**
 * The guardian email: its words, its markup and the small interface that sends it.
 *
 * Sending goes through `GuardianMailer`, so the provider can change without
 * touching the consent rules. `resendMailer` is the production sender. The
 * emulator sender only prints the message, and `mailerFor` picks it solely when
 * the Firebase emulator flag is set, so a normal build never logs a link.
 */

export type GuardianMessage = {
  to: string;
  subject: string;
  text: string;
  html: string;
};

export interface GuardianMailer {
  send(message: GuardianMessage): Promise<void>;
}

const escapeHtml = (value: string): string =>
  value.replace(/[&<>"']/g, (c) => (
    {'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[c] as string));

/** "Nov 9, 2026", in Philippine time, the same way the app writes dates. */
export function expiryLabel(at: number): string {
  return new Intl.DateTimeFormat('en-US', {
    timeZone: 'Asia/Manila', month: 'short', day: 'numeric', year: 'numeric',
  }).format(at);
}

export type GuardianMailInput = {
  guardianName: string;
  guardianEmail: string;
  link: string;
  /** Opens the manage page. Only works once the guardian has confirmed. */
  manageLink?: string;
  expiresAt: number;
};

const ink = '#26221B';
const accent = '#1D5C50';
const muted = '#6E675C';
const font = "-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif";

/** The consent request email. Every dynamic value is escaped before it enters the markup. */
export function guardianMessage(input: GuardianMailInput): GuardianMessage {
  const subject = "Review your child's Pantas account";
  const heading = "Confirm your child's Pantas account.";
  const greeting = `Hi ${input.guardianName},`;
  const lead = `Your child wants to use Pantas, a study app for Philippine exams, and named you as their parent or guardian. ` +
    'We process their account ID and age group, your name and email for this request, and confirmation records and send counters.';
  const notice = 'Opening the link alone does not confirm.';
  const label = 'Review and Confirm';
  const expiry = `The link expires on ${expiryLabel(input.expiresAt)}. Not their parent or guardian? Ignore this email.`;
  const manageLabel = 'Manage permission (after you confirm): ';
  const text = [heading, greeting, lead, notice, `${label}: ${input.link}`,
    ...(input.manageLink ? [`${manageLabel}${input.manageLink}`] : []), expiry].join('\n\n');
  const p = (value: string): string =>
    `<p style="margin:0 0 16px;font-size:16px;line-height:1.6">${escapeHtml(value)}</p>`;
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8">` +
    `<meta name="viewport" content="width=device-width,initial-scale=1"></head>` +
    `<body style="margin:0;padding:24px 16px;background:#FBF9F4;color:${ink};font-family:${font}">` +
    `<div style="max-width:560px;margin:0 auto"><h1 style="margin:0 0 20px;font-size:24px;line-height:1.25">${escapeHtml(heading)}</h1>` +
    `${p(greeting)}${p(lead)}${p(notice)}` +
    `<p style="margin:8px 0 24px"><a href="${escapeHtml(input.link)}" style="display:inline-block;padding:12px 24px;border-radius:12px;background:${accent};color:#FFFFFF;font-size:16px;font-weight:600;text-decoration:none">${label}</a></p>` +
    (input.manageLink
      ? `<p style="margin:0 0 16px;font-size:14px;line-height:1.6">${manageLabel}` +
        `<a href="${escapeHtml(input.manageLink)}" style="color:${accent}">${escapeHtml(input.manageLink)}</a></p>` : '') +
    `<p style="margin:0;font-size:13px;line-height:1.6;color:${muted}">${escapeHtml(expiry)}</p></div></body></html>`;
  return {to: input.guardianEmail, subject, text, html};
}

export type InactivityWarningInput = {email: string; deleteOn: number; origin: string};

/** The warning sent 30 days before an unused account is deleted. */
export function inactivityWarningMessage(input: InactivityWarningInput): GuardianMessage {
  const date = expiryLabel(input.deleteOn);
  const link = input.origin.replace(/\/$/, '');
  const subject = `Your Pantas account will be deleted on ${date}`;
  const lead = 'You have not used Pantas for almost two years. We delete accounts after two years without use, ' +
    `so your account and study records will be deleted on ${date}.`;
  const action = 'To keep your account, open Pantas and sign in before then.';
  const label = 'Open Pantas';
  const footer = 'Questions? Reply to this email or write to support@pantas.study.';
  const text = [lead, action, `${label}: ${link}`, footer].join('\n\n');
  const p = (value: string): string =>
    `<p style="margin:0 0 16px;font-size:16px;line-height:1.6">${escapeHtml(value)}</p>`;
  const html = `<!doctype html><html lang="en"><head><meta charset="utf-8">` +
    `<meta name="viewport" content="width=device-width,initial-scale=1"></head>` +
    `<body style="margin:0;padding:24px 16px;background:#FBF9F4;color:${ink};font-family:${font}">` +
    `<div style="max-width:560px;margin:0 auto">${p(lead)}${p(action)}` +
    `<p style="margin:8px 0 24px"><a href="${escapeHtml(link)}" style="display:inline-block;padding:12px 24px;border-radius:12px;background:${accent};color:#FFFFFF;font-size:16px;font-weight:600;text-decoration:none">${label}</a></p>` +
    `<p style="margin:0;font-size:13px;line-height:1.6;color:${muted}">${escapeHtml(footer)}</p></div></body></html>`;
  return {to: input.email, subject, text, html};
}

/** `Name <addr>` is used as written. A bare address gets the default name `Pantas`. */
export function senderField(from: string): string {
  const value = from.trim();
  return value.includes('<') ? value : `Pantas <${value}>`;
}

/** Production sender. The caller supplies the key; this file never reads a secret. */
export function resendMailer(apiKey: string, from: string, fetchImpl: typeof fetch = fetch): GuardianMailer {
  return {
    async send(message) {
      const response = await fetchImpl('https://api.resend.com/emails', {
        method: 'POST',
        headers: {authorization: `Bearer ${apiKey}`, 'content-type': 'application/json'},
        body: JSON.stringify({from: senderField(from), to: [message.to], subject: message.subject,
          text: message.text, html: message.html}),
      });
      if (!response.ok) throw new Error(`Mail provider refused the message (${response.status}).`);
    },
  };
}

/** Local runs only: prints the message so the flow can be tested without a provider. */
export function emulatorMailer(log: (line: string) => void = console.log): GuardianMailer {
  return {
    async send(message) {
      log(`[guardian-mail] to=${message.to} subject=${message.subject}\n${message.text}`);
    },
  };
}

export function mailerFor(
  env: NodeJS.ProcessEnv,
  secrets: {apiKey: () => string; from: () => string},
): GuardianMailer {
  if (env.FUNCTIONS_EMULATOR === 'true') return emulatorMailer();
  const apiKey = secrets.apiKey();
  const from = secrets.from();
  if (!apiKey || !from) throw new Error('Guardian mail is not configured.');
  return resendMailer(apiKey, from);
}
