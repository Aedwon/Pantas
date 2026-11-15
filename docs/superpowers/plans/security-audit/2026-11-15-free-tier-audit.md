# Free-tier audit (rule 7), Nov 15, 2026

Owner: security fixes and billing cap lead. Read-only. Rule 7 (`docs/workflow/process-improvement.md`):
only real users may cost money; every fixed or housekeeping item stays inside the free tiers, counted per
billing account across pantas-prod and pantas-staging together.

Sources: live reads on Nov 15 (gcloud, Cloud Monitoring, Cloud Billing catalog), the Nov 1 to 14
per-service probe (launch log, Nov 14 cost review). "Now" is the monthly rate at today's state; "after"
is after tonight's scheduler steps 3 and 4 (prod `LEGACY_SCHEDULES=off`, `--force` deploy with the pinned
CLI). Prices from the Cloud Billing catalog unless marked.

| # | Item | Today's count | Free limit (per billing account unless noted) | Now, per month | After steps 3 and 4 |
|---|---|---|---|---|---|
| 1 | Cloud Scheduler jobs | prod 12 (3 combined enabled, 9 legacy paused; paused still bill); staging 0 | 3 jobs | about $0.90 | 3 jobs: $0 |
| 2 | Secret Manager active versions | 18 (prod 9, incl. 2 of GUARDIAN_MAIL_API_KEY; staging 9, incl. 2 of PAYMONGO_WEBHOOK_SECRET); none disabled | 6 versions; 10,000 access ops | about $0.72 projected (12 x $0.06); none billed yet in the Nov 1 to 14 probe | same |
| 3 | Cloud Run minimum instances | 0 on every service | n/a | $0 | $0 |
| 3b | Warm-up (`WARMUP_ENABLED=true` on prod; now in `jobsFrequent`, every 5 minutes) | about 8,640 runs a month | Cloud Run: 180,000 vCPU-s, 360,000 GiB-s, 2M requests | inside: both projects' Cloud Run was about $0.66 before credits Nov 1 to 14, all covered | same |
| 4 | Artifact Registry images | 651 MiB (prod 227, staging 424; Firebase's policy deletes images older than 1 day) | 0.5 GB-month | $0 so far (probe); spikes over 0.5 GB after same-day deploys to both projects | same |
| 5 | Cloud Build | about 70 builds in November | 2,500 build-minutes | $0 | $0 |
| 6a | Firebase Hosting storage | about 1 GiB; 10 versions kept per site (set Nov 14) | 10 GiB per project | $0 | $0 |
| 6b | Firebase Hosting egress (not user-driven now) | last 24 h: prod 457 MiB, staging 658 MiB | 360 MB a day per project | over on both: about $0.02 a day; staging billed $0.04 Nov 1 to 14 | same until fixed |
| 7 | Firestore backups and PITR | PITR off; daily backups kept 7 days; data 12 MiB prod, 20 MiB staging | no free tier for backups | well under $0.01 (not exact: backup size not reported) | same |
| 8 | Cloud Storage | asia-southeast1 only: function sources about 0.06 GiB per project, upload staging (1-day lifecycle), app buckets near 0 | 5 GB-month only in us-east1, us-west1, us-central1 | about $0.003 | same |
| 9a | Cloud Logging | 0.04 GiB per project in November; default 30-day retention | 50 GiB per project; 30 days retention | $0 | $0 |
| 9b | Cloud Monitoring alarms and uptime checks | 16 metric alarms (8 per project), 1 log alarm (prod), 0 uptime checks | no alerting SKU in the catalog today | $0 | $0; Google documents a future $0.35 per metric reference a month (about $5.60) with no date |
| 10 | Pub/Sub (budget and cutoff topics) | a few messages an hour | 10 GiB | $0 | $0 |
| 11 | App Engine $0.01 (staging) and $0.01 unattributed | no App Engine app on either project | n/a | about $0.02 in Nov 1 to 14 | unknown until SKU detail exists |
| 12 | Enabled APIs with paid SKUs, unused | BigQuery family, Dataform, Dataplex, Analytics Hub, Gemini for Cloud, Deployment Manager, Container Registry, Source, SQL component, and others | bill only on use | $0 | $0 |
| 13 | reCAPTCHA assessments | 440 in Nov 1 to 15 (prod 327, staging 113); caps 300 a day per project | 10,000 a month | $0, but the caps allow 18,000 a month, which would bill $8 | same |
| 14 | Cloudflare (Workers, DNS, website) | Free plan; static assets free; 100,000 Worker-script requests a day (only `/__/*`) | free plan | $0; cannot bill without a paid plan | $0 |
| 15 | Budgets, Billing APIs, the cutoff functions | 3 budgets with Pub/Sub, 2 cutoff functions | free / Cloud Run free tier | $0 | $0 |

Hosting egress detail (6b): the security fixes lead's mirror and comparison runs downloaded the full app
from Firebase (about 50 MB each) several times on Nov 14 (prod about 150 MB at 10 to 11 and 18 UTC);
the staging Worker publish step mirrors from Firebase after each staging deploy (50 MB each); prod also
served unexplained 64 MB bursts at 02, 07 and 08 UTC on Nov 15, after app.pantas.study moved to
Cloudflare (someone loading `pantas-prod.web.app` or `.firebaseapp.com` directly, or a lane's check).

Expected monthly cost with zero users, after steps 3 and 4 and before further fixes: about $0.72
(Secret Manager, once billed) + up to about $0.60 (Hosting egress from tooling at the current rate) +
under $0.02 (backups, Storage) + the unexplained $0.02. Rulings and fixes: see the launch log.
