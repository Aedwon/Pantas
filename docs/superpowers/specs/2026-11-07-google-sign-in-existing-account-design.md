# Google sign-in for an address that already has an account (Nov 7, 2026)

Status: go-ahead from Aedwon ("can you also do a fix for this", after the diagnosis and
Astra's cross-check). Workstream: `web/load-speed-r1`. Ships in the paused telemetry deploy.

## Part 1: plain language

- **Problem.** A tester who first signed in with the email code, then tries "Use Google
  Instead" with the same Gmail address, cannot sign in. Firebase allows one account per
  email; the code account has no Google link, so Firebase refuses, and the app drops back to
  the email screen. Seen on Aedwon's iPhone home-screen app and Brave on Mac.
- **Fix.** When Google returns a verified address that already belongs to a Pantas account,
  the server checks Google's proof (issued by Google, for Pantas, for a verified email, not
  expired) and signs the person into that existing account, the same way the email code does.
  It also links Google to the account, so the next Google sign-in works directly.
- **Security.** Equal to the email code: both prove control of the inbox. No new account is
  made on this path, a disabled or unverified account is refused, the call is rate limited and
  App Check protected with a single-use token.
- **What the student sees.** Success goes straight in, as a normal sign-in. A failure keeps
  today's message "We couldn't sign you in. Try again." No new screens or copy.
- **Not in scope.** The iPhone home-screen pop-up hand-off (Astra H1) is checked by Aedwon
  after this deploy; a redirect fallback would be a separate change.

## Part 2: agent detail

Server, `functions/src/googleSignIn.ts`, callable `exchangeGoogleSignIn`, region
`asia-southeast1`, `enforceAppCheck` and `consumeAppCheckToken` like `verifySignInCode`,
wrapped in `timed`. Input `{idToken: string}` (max 4096 chars, no other keys).

1. Caller must be authenticated (anonymous accepted), same `assertCaller` rule as the code
   flow. Rate limit with `allowAtMost(uid, 'googleExchange', 10, 10 * 60_000)`.
2. Verify the Google ID token by calling `https://oauth2.googleapis.com/tokeninfo?id_token=`
   (global `fetch`, 5 s timeout). Require: HTTP 200; `aud` equals the env param
   `GOOGLE_WEB_CLIENT_ID` (defineString; prod value
   `416041343210-48rd2t4jivmdt7s1jbkoleobuadq9olj.apps.googleusercontent.com`, the
   Firebase Google provider's client id); `iss` is `accounts.google.com` or
   `https://accounts.google.com`; `email_verified` is `"true"`; `exp` in the future; `sub`
   and `email` present. If the param is empty, refuse (`failed-precondition`).
3. Normalize the email (trim, lower case). `getUserByEmail`; not found means refuse
   (`permission-denied`): a new address never needs this path because Firebase signs it in
   directly. Refuse a disabled user or one whose email is not verified. Refuse when the
   account's email differs from the token email after normalization.
4. Link: if the account has no `google.com` provider, `updateUser(uid, {providerToLink:
   {providerId: 'google.com', uid: sub, email}})`. If that Google `sub` is already linked to a
   different uid, refuse (`permission-denied`). If already linked to this uid, continue.
5. Return `{token: createCustomToken(uid)}`. Write the same audit entry the code flow writes.
   Never log the ID token, email or uid in plain form beyond what the existing audit writes.

Client:

- `lib/core/platform/callable_options.dart`: add `exchangeGoogleSignIn` to the replay-protected
  set (and `REPLAY_PROTECTED` in `functions/test/app-check.test.mjs`).
- `FirebaseAuthGateway.googlePopup`: on `account-exists-with-different-credential` or
  `email-already-in-use`, read the Google ID token from the error's credential and surface it
  in a typed exception (code `google-account-exists`, carrying the token in memory only).
  Verify in the installed `firebase_auth_web` source that the token is exposed; if it is not,
  STOP and report with the evidence.
- `AuthRepository._signInWithGoogle`: on that exception, call the callable, then run the same
  `_switchAccount` path the email code uses with `signInWithCustomToken`, then record the
  sign-in event. No second Google pop-up. `credential-already-in-use` keeps today's pending
  credential path.

Tests first: server (each refusal: wrong aud, wrong iss, unverified, expired, missing fields,
no account, disabled, unverified account, sub linked elsewhere, empty param, extra keys, rate
limit; success links once and returns a token; tokeninfo is injected, never called in tests);
client (collision with an existing email account goes through the exchange and custom token,
no second pop-up; credential-already-in-use path unchanged; exchange failure returns failed
and leaves the anonymous session usable).

Prod config: add `GOOGLE_WEB_CLIENT_ID=416041343210-48rd2t4jivmdt7s1jbkoleobuadq9olj.apps.googleusercontent.com`
to `functions/.env.pantas-prod`. Staging and dev left empty (path refuses there).
