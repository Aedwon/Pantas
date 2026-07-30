# RevenueCat and Play Console setup for Pantas

**Everything that has to exist outside this repo before the paywall takes a single
peso**, and the order to do it in.

Written 11 August 2026. Companion to `docs/firebase-setup.md`, which covers
Firebase. **They are separate systems and are often confused: RevenueCat is not
Firebase and Firebase does not process payments.**

---

## Read this first

**You have a Google Developer account and no Apple one.** That decides the shape of
everything below: **Android only, one store, one set of credentials.** Nothing here
needs Apple, and the app's own code already reflects that, configuring RevenueCat
with an Android key alone.

**What is already built in the app.** The paywall, the entitlement stream, the
purchase flow and the mock cooldown all exist and are tested against an injected
gateway. **The live gateway's `configure` is real code**, not a stub: it calls
`Purchases.configure` with an Android API key read from the environment. So the
work here is credentials and products, not implementation.

**Answering the question directly: yes, one thing needs connecting.** RevenueCat
cannot see your Play subscriptions until you give it a **Google Cloud service
account** with access to your Play Console. That is Section 3, and it is the step
most likely to go wrong.

---

## 0. Do this before creating anything

**`purchases_flutter` is two major versions behind**: 8.11.0 installed, **10.8.0**
current. Upgrade first, for the same reason as the Firebase packages: the wiring is
one adapter today, and a major upgrade after the products exist is a migration
under pressure with real money attached.

**Decide the product IDs before you create them, because Play Console will not let
you change or reuse them.** See Section 2. Getting this wrong is permanent.

---

## 1. The entitlement and the plans, as already decided

**One entitlement, three plans, no lifetime.**

| Plan | Price | Note |
|---|---|---|
| Weekly | ₱29 | Deliberate: at ₱29 it is its own low-risk trial for a student who budgets weekly |
| Monthly | ₱99 | |
| Yearly | ₱799 | Lowered from ₱999 on 11 August. At ₱999 the crossover against Monthly was 10.1 months, longer than any real prep window |

**There is no lifetime product and there must not be one.** Aedwon removed it on
3 August: *"i want to remove the lifetime purchase, for reasons that the app has a
very long roadmap and that they will be paying less than what they're getting in
the long term."* It cost nothing to remove because no SKU existed. **Creating one
now would reverse a decision and could not be undone**, since a Play product ID
cannot be deleted once used.

**The entitlement is `pro`.** One entitlement, three products attached to it. The
app asks only whether Pro is active, never which plan bought it, except for
display.

---

## 2. Product IDs, which are permanent

**`docs/OPERATIONS.md` listed `cse_cet_pro_monthly` and friends, plus a lifetime.**
That list predates the rename and the lifetime decision. **Do not create products
from it.**

**Decide now.** Play product IDs cannot be renamed, cannot be deleted, and cannot be
reused after deletion. The app is called Pantas.

| Suggested | Why |
|---|---|
| `pantas_pro_weekly` | |
| `pantas_pro_monthly` | |
| `pantas_pro_yearly` | |

**Subscriptions in Play are a product with base plans**, not three separate
products, if you want them grouped. Either shape works with RevenueCat. **The
simpler one for a first release is one subscription per billing period**, because
the offering in RevenueCat then maps one to one and there is less to reason about
when something does not appear.

**Nothing in the app hardcodes a product ID.** Entitlement carries `productId` for
display only, so this naming is a store and RevenueCat concern rather than a code
change.

---

## 3. The connection you asked about: a Google Cloud service account

**This is the step that fails most often, and it fails quietly**: RevenueCat shows
"credentials need attention" and purchases appear to work in testing while renewals
and cancellations never arrive.

**Checked against RevenueCat's own documentation on 12 August 2026.** Three
details below were wrong when this was written the day before, and they are
marked.

**If there is no Google Cloud project yet, make one first.** Sign in to
`console.cloud.google.com` with **the same Google account that owns the Play
developer account**, and create a project. Any name.

**You do not have to link it to Play.** Google removed that requirement:
"You no longer need to link your developer account to a Google Cloud Project in
order to access the Google Play Developer API." The connection is made by
inviting the service account in Play Console, which is step 4 below. Older
guides that send you to Play Console's API access page to link a project are
out of date.

**Google may ask for a billing account when Pub/Sub is enabled.** The usage here
is a handful of messages a day and sits inside the free allowance. **Whether
Google forces a billing account on the project before it will enable the API is
not something this file can promise.** If it asks, that is normal and not a sign
you did something wrong.

**In Google Cloud, on that project:**

1. **Enable three APIs**, all of them, not just the first:
   - **Android Publisher API.** **Corrected:** this file called it the Google
     Play Android Developer API. Same API, but the console lists it under the
     new name and searching the old one finds nothing.
   - Google Play Developer Reporting API
   - Cloud Pub/Sub API
2. **Create a service account** under IAM & Admin, and **create a JSON key** for
   it. Download it once; it cannot be downloaded again.
3. **Grant it two roles**: **Pub/Sub Editor** and **Monitoring Viewer**.
   **Corrected:** this said Pub/Sub Admin. Editor is enough for almost everyone.
   Some accounts hit a permission error when the topic is created, and Admin is
   the fix for that, so start with Editor and only widen if it fails. Monitoring
   Viewer is what makes the queue's health visible when something stalls.

**In Play Console:**

4. **Users and permissions > Invite new user**, using the service account's email
   address. **Grant three permissions**, not two. **Corrected:** the first one
   was missing here.
   - View app information and download bulk reports (read-only)
   - View financial data, orders, and cancellation survey responses
   - Manage orders and subscriptions

   **A service account with a Cloud role but no Play Console invitation is the
   single most common cause of the credentials error.** Confirm the invitation
   shows as **Active** rather than pending.

**In RevenueCat:**

5. **Upload the JSON** under the Play app's service credentials.
6. **Take the Pub/Sub topic** RevenueCat offers, or let it create one.

**Back in Play Console:**

7. **Monetization setup > Real-time developer notifications**: paste the topic
   name, and set notification content to **subscriptions, voided purchases and all
   one-time products.**
8. **Press "Send test notification"** and confirm RevenueCat receives it. **Do this
   before you trust anything else.** It is the only proof the loop is closed, and
   without it you will not learn that renewals are missing until a subscriber's
   second month.

**Credentials can take up to 36 hours to become valid.** If step 8 fails
immediately after setup, wait before assuming it is misconfigured. Until they
are valid you will see "Invalid Play Store credentials" and no purchase will go
through.

**One thing that sometimes shortens the wait**, from RevenueCat's own docs: open
any product under Monetize in Play Console, change the description, and save it.
It is not guaranteed and it costs a minute.

**Sources for this section**, read 12 August 2026:
<https://www.revenuecat.com/docs/service-credentials/creating-play-service-credentials>

---

## 4. In RevenueCat itself

1. **Create the project**, and add the **Android app** with the package name
   **`com.aedwon.pantas`** for production. The dev and staging flavors are
   `com.aedwon.pantas.dev` and `com.aedwon.pantas.dev.staging`; a
   separate RevenueCat project per flavor is cleaner than mixing test and real
   revenue in one dashboard.
2. **Create the entitlement `pro`.**
3. **Create the three products**, matching the Play IDs exactly, and **attach all
   three to `pro`.**
4. **Create one offering**, containing the three packages. The app reads the
   current offering rather than named products, so a future price change or an
   experiment does not need an app release.
5. **Copy the Android public SDK key.** It is passed to the app at build time, not
   committed. **The public key is safe in a client; the secret key never goes near
   the app.**

---

## 5. Testing purchases without spending money

**License testers** in Play Console under Setup > License testing. Their purchases
are real flows against test cards and renew on an accelerated clock: a monthly
subscription renews every few minutes, which is how you verify renewal handling in
an afternoon rather than a month.

**The app must be published to a track**, internal testing is enough, before
purchases work at all. **Purchases fail with an unhelpful error for an app that has
never been uploaded**, which reads exactly like a credentials problem and is not.

**Test at least these, because each is a different code path:** a fresh purchase,
a renewal, a cancellation that stays active until period end, a refund, and a
purchase restored on a reinstall.

---

## 6. What the app expects from the environment

The Android key is read from the environment rather than committed. Pass it at
build time:

```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart \
  --dart-define=REVENUECAT_ANDROID_KEY=goog_xxxxxxxx \
  --dart-define=BUILD_NUMBER=42
```

**Both defines matter.** The build number is what the force-update gate compares
against, and it reports build 1 when the define is missing, which makes every
install look out of date the moment a minimum is set.

---

## 7. Pricing, and the one thing to watch

RevenueCat is free below a monthly tracked revenue threshold and takes a
percentage above it. **At this app's prices that threshold is a long way off**, and
it is not a reason to avoid RevenueCat: writing and maintaining your own receipt
validation and renewal handling is the alternative, and it is the part of billing
that quietly breaks.

**What to watch instead is Play's own cut and the tax handling**, which is between
you and Google and unaffected by RevenueCat.

---

## 8. The order I would do it in

1. **Upgrade `purchases_flutter`** while nothing depends on it.
2. **Decide the product IDs.** Permanent.
3. **Create the subscriptions in Play Console** and activate them.
4. **Upload the app to internal testing.** Nothing purchases before this.
5. **The service account, all three APIs, both roles, and the Play Console
   invitation.**
6. **RevenueCat project, entitlement, products, offering.**
7. **Real-time notifications, then the test notification**, and do not proceed
   until it arrives.
8. **License testers, then the five flows in Section 5.**

**Not RevenueCat, and often confused with it:** sign-in, sync and crash reporting
are Firebase, in `docs/firebase-setup.md`. **A student can subscribe without ever
signing in**, because entitlement comes from the store and the device, not from an
account. That is deliberate and it is why the paywall works before auth exists.

---

## Sources

- [Creating Play service credentials, RevenueCat](https://www.revenuecat.com/docs/service-credentials/creating-play-service-credentials)
- [Google Play checklists, RevenueCat](https://www.revenuecat.com/docs/service-credentials/creating-play-service-credentials/google-play-checklists)
- [Google real-time developer notifications, RevenueCat](https://www.revenuecat.com/docs/platform-resources/server-notifications/google-server-notifications)
- [Google Play billing setup guide 2026, RevenueCat codelabs](https://revenuecat.github.io/codelabs/google-play.html)
