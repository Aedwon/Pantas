# Level 4 setup steps for Aedwon

Date: October 6, 2026. Author: lead. Sources: `docs/pricing.md`, tier pricing spec
(`specs/2026-10-06-tier-pricing-design.md`), L3-W3 prerequisites P1 and P2.
Do these in order. Product IDs are permanent: type them exactly. If a screen does not match a
step, stop and tell the lead what you see; do not guess.

## Part 1. Google Play Console: Civil Service subscriptions (W3 P2)

App: Pantas (`com.aedwon.pantas`).

1. Open Play Console, pick Pantas, then **Monetize with Play › Products › Subscriptions**.
2. Select **Create subscription**.
   - Product ID: `pantas_cs_weekly`
   - Name: `Pantas Pro Civil Service Weekly`
   - Select **Create**.
3. On the new subscription, select **Add base plan**.
   - Base plan ID: `weekly-autorenewing`
   - Type: **Auto-renewing**. Billing period: **Weekly**.
   - Grace period and account hold: leave the defaults.
   - Select **Set prices**, find **Philippines**, enter **₱49**. If Play shows a nearby price
     instead of ₱49, stop and tell the lead (the price is not available).
   - Leave other countries as Play converts them, or remove them if Pantas sells only in the
     Philippines.
   - Select **Save**, then **Activate**.
4. Repeat steps 2 and 3 for Monthly:
   - Product ID `pantas_cs_monthly`, name `Pantas Pro Civil Service Monthly`.
   - Base plan ID `monthly-autorenewing`, billing period **Monthly**, price **₱149**.
5. Add the free trial to Civil Service Monthly:
   - In `pantas_cs_monthly`, on the `monthly-autorenewing` base plan, select **Add offer**.
   - Offer ID: `free-trial`.
   - Eligibility: **New customer acquisition**, then **Never had any subscription** (in this app).
   - Phase: **Free trial**, **7 days**.
   - Select **Save**, then **Activate**.
6. Repeat steps 2 and 3 for Yearly:
   - Product ID `pantas_cs_yearly`, name `Pantas Pro Civil Service Yearly`.
   - Base plan ID `yearly-autorenewing`, billing period **Yearly**, price **₱1,199**. No offer.

## Part 2. Google Play Console: the Civil Service Season Pass

1. **Monetize with Play › Products › One-time products** (Play may call them "In-app products").
2. Select **Create one-time product**.
   - Product ID: `pantas_pass_civil_service`
   - Name: `Civil Service Season Pass`
   - Description: `Pro for your Civil Service exam, until the exam date. One payment; it never renews.`
   - Price: Philippines **₱499**.
   - If Play asks for a purchase option, choose **Buy**, and allow buying it more than once if
     asked (the app treats it as consumable).
3. Select **Save**, then **Activate**.

## Part 3. Google Play Console: move the Student trial to Monthly

1. Open `pantas_pro_yearly`. If its base plan has a free-trial offer, open the offer and select
   **Deactivate**. (Yearly has no trial since October 4.)
2. Open `pantas_pro_monthly`. If its base plan has no free-trial offer, add one exactly as in
   Part 1 step 5 (Offer ID `free-trial`, New customer acquisition, Never had any subscription,
   7-day free trial). Activate it.
3. Write down what you found (trial on Yearly: yes or no; trial on Monthly: added or already
   there) and tell the lead.

## Part 4. RevenueCat: add the new products

1. Open the RevenueCat dashboard, project Pantas, then **Product catalog › Products**.
2. Select **+ New** (or **Import products** from Google Play if offered) and add, for the Pantas
   Google Play app: `pantas_cs_weekly`, `pantas_cs_monthly`, `pantas_cs_yearly`,
   `pantas_pass_civil_service`. Subscriptions may show with their base plan, for example
   `pantas_cs_monthly:monthly-autorenewing`. That is expected.
3. **Product catalog › Entitlements › pro**: select **Attach**, and attach all four new products.
   Do not create a new entitlement; the app reads `pro` and works out the tier from the product.
4. **Product catalog › Offerings**: open the offering marked **Current**. Add four packages:
   - Identifier `cs_weekly`, product `pantas_cs_weekly`
   - Identifier `cs_monthly`, product `pantas_cs_monthly`
   - Identifier `cs_yearly`, product `pantas_cs_yearly`
   - Identifier `cs_pass`, product `pantas_pass_civil_service`
   Keep the existing Student packages as they are.
5. Tell the lead when done. The lead checks the products on a test purchase in level 4.

## Part 5. RevenueCat secret key for the cancellation fix (W3 P1)

What it is: a private key that lets the Pantas server ask RevenueCat "is this student's plan still
paid up?". The cancellation fix needs it: today Pro can disappear the moment a student cancels,
instead of at the end of the period they paid for. The key stays in Google's secret storage. Never
paste it into chat, a file, or an email. The lead never sees it.

1. RevenueCat dashboard, project Pantas, **Project settings › API keys**.
2. Select **+ New secret API key**.
   - Name: `pantas-functions-cancellation`
   - Version: **V2** if asked.
   - Permissions: read-only access to customer information (for example **Customer information:
     Read only**); **No access** for everything else. If the choices look different, pick the
     smallest read-only option for customers and subscriptions and tell the lead what you picked.
   - Select **Generate**. Copy the key. RevenueCat may show it only once.
3. In Terminal, in the Pantas folder, run (it asks you to paste the key; the key is not shown):

   ```bash
   firebase functions:secrets:set REVENUECAT_SECRET_API_KEY --project pantas-staging
   ```

4. Run it again for production and paste the same key:

   ```bash
   firebase functions:secrets:set REVENUECAT_SECRET_API_KEY --project pantas-prod
   ```

5. Also give the lead your RevenueCat **project ID** (Project settings, shown at the top; it is not
   secret). Tell the lead when both secrets are set.

Nothing is deployed by these steps. Deploying the functions that use the key is a separate
approval when W3 is ready.
