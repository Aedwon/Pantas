# Data at scale, and where the account boundary sits

**Brief, 11 August 2026.** Written because Aedwon is about to create the Firebase
projects and asked three things: whether the setup is current, what happens to
the data at scale, and whether "sync is for Pro, telemetry is for everyone" makes
sense.

**The short answer to the third is yes, and the cost structure is the reason.**
The two halves have opposite economics, and conflating them is the mistake this
brief exists to prevent.

---

## 1. The one thing to do before creating anything

**Every Firebase package in `pubspec.yaml` is a major version behind**, measured
11 August:

| Package | Current | Latest |
|---|---|---|
| `firebase_core` | 3.15.2 | **4.13.0** |
| `firebase_auth` | 5.7.0 | **6.5.7** |
| `cloud_firestore` | 5.6.12 | **6.8.0** |
| `firebase_analytics` | 11.6.0 | **12.4.6** |
| `firebase_crashlytics` | 4.3.10 | **5.2.7** |
| `firebase_app_check` | 0.3.2+10 | **0.4.6** |
| `firebase_remote_config` | 5.5.0 | **6.5.6** |
| `firebase_messaging` | 15.2.10 | **16.5.0** |
| `google_sign_in` | 6.3.0 | **7.2.0** |

**Upgrade before wiring, not after.** Right now the three adapter methods are
empty and nothing in the app calls a Firebase API that can break, so the upgrade
is a version bump and a test run. Once the wiring exists, the same upgrade is a
migration across every call site.

**`google_sign_in` 7 is not a version bump, it is a rewrite.** The singleton
replaced the constructor, `initialize` must be awaited before anything else,
authentication and authorization are now separate calls, and 7.1+ requires
`serverClientId` on Android when not relying on `google-services.json`.

**This project is unusually well placed for that.** Google sign-in already sits
behind a single gateway interface with an unconfigured implementation, so the
rewrite lands in one adapter rather than across the app. That was worth doing and
it is about to pay.

---

## 2. What the app will collect, and what each part costs

Three destinations, and they are not alike.

### Analytics and Crashlytics: free, unlimited, no account needed

**Free at any scale.** Unlimited event volume, up to 500 distinct event names per
project, up to 25 parameters per event. Crashlytics is free outright.

**So the product decisions Aedwon wants to make cost nothing**, at ten users or a
hundred thousand, and they do not need anyone to log in. This is the part of his
instinct that is simply correct.

**The limits that do bite** are shape, not volume: 500 distinct names is a ceiling
you hit by putting an id inside an event name, and a parameter is invisible in
reports until registered as a custom dimension.

### Firestore: the only per-user cost, and the only part needing an account

Free tier per day: **50,000 reads, 20,000 writes, 20,000 deletes, 1 GiB stored.**
Beyond it: **$0.06 per 100k reads, $0.18 per 100k writes, $0.02 per 100k deletes,
$0.26 per GB per month.**

**What that means in students.** A studying day plausibly writes 30 to 60 rows:
attempt items, review-state updates, lesson progress, flags. At 40 writes a day
the free tier covers roughly **500 syncing students**. The next 10,000 syncing
students cost single-digit dollars a month in writes, which is not the risk.

**The risk is reads, and it is a shape problem, not a volume one.** Firestore
bills per document read. A sync that pulls a student's whole history on every
launch instead of what changed since a cursor turns a trivial bill into a large
one, and the same code is what makes the app slow. **One unbounded query is how a
$12 month becomes a four-figure month**, and Blaze has no hard spending cap.

### Cloud Storage: only Wrapped sharing

One PNG per shared card. Negligible, and it needs Blaze on new projects.

---

## 3. The account boundary, which is the actual open question

**Narrower than it looks, because two thirds of it is already built.**

Today's code: a gateway that can sign in anonymously, and a cloud gateway that
**throws for anonymous users, `anonymous users do not sync`**. So a student who
has not signed in already does not sync, and already costs nothing in Firestore.

**That already reverses a decision from May.** The auth design's D3 assumed
anonymous users throughout, with self-service export and delete for everyone. The
code moved past it and the release guard now forbids the export row outright,
pointing export at a DPO email path instead. **The May spec was not amended**,
which is exactly the trap of trusting a spec over the code.

**So the one real question left:** a student who signs in but is **Free**. They
sync today. Aedwon wants sync to be Pro only.

| Option | What a Free student gets | Cost |
|---|---|---|
| **A. Sync is Pro only** | Local only, whether or not they sign in. Signing in gets them nothing until they pay | Free students cost nothing in Firestore ever. **A lost phone loses everything**, and that story travels further than a feature list |
| **B. Sync for anyone signed in** | Cross-device sync free | Every signed-in Free student is billable. Also spends the strongest Pro argument on people who are not paying |
| **C. Pro syncs; Free gets a one-file backup they own** | Local only, plus an export they can carry to a new phone | Same zero Firestore cost as A, and removes the lost-everything story. Costs one small feature, and **an in-app export contradicts the release guard as written** |

**Recommended: A now, C soon**, and C deliberately rather than by accident,
because it touches a guard that exists for a reason.

**Why A over B is not only about money.** "Your progress follows you to any
phone" is the clearest thing Pro sells to a student who does not yet believe
practice questions are worth paying for. Giving it away leaves Pro selling only
volume, which is the argument every free reviewer app on the Play Store also
makes.

**Why C matters more than it looks.** The students most likely to lose a phone
are the ones this app is for. A reviewer that loses three months of a student's
work earns a review that no amount of content quality answers. C buys that off
for a file.

**What A does not settle, and should be said out loud:** a Free student who signs
in and gets nothing will feel misled unless the sign-in screen says plainly what
signing in does and does not do. That is copy, and it is the kind of copy that
decides whether an app feels honest.

---

## 4. Collecting data on everyone: yes, with two conditions

**The instinct is right and the economics agree with it.** Deciding by measurement
rather than by whoever shouts loudest is what keeps a solo-built app honest, and
analytics is free for it.

**Condition one: consent is already gated and must stay gated.** Under RA 10173
consent is unanswered by default, and the app currently sends nothing until a
student agrees. **This is a floor, not a preference.** It also means the numbers
are a sample of the consenting, which has to be remembered when reading them.

**Condition two: telemetry answers questions, it is not a net.** The existing
event enum is grouped by the question each event answers rather than by feature,
which is what makes a useless event visible later. Events logged because they
might be handy are the ones that are never read and still cost a name against the
500.

**What is worth measuring that is not obvious.** Not just funnel and retention:
**which authored content never gets reached**, because that is the only signal
that tells him where authoring effort is wasted, and it is invisible in feedback.
Students do not report the lesson they never found.

---

## 5. Security, in the order it should be done

**The rules are the security model.** App Check and Play Integrity make abuse
expensive; only the rules make it impossible. The rules in `firebase-setup.md`
scope a student to their own subtree, which is correct, and the shares collection
is world-readable by design.

**Publish rules before the first real sign-in**, not after. A production-mode
database with default rules denies everything, which is safe; test mode opens it
to the world for 30 days, which is not.

**Order that avoids locking yourself out:**

1. **Firestore and Storage rules published first**, while there is no data to
   lose.
2. **App Check providers registered, enforcement OFF.** Watch verified requests
   arrive for a few days. Enforcing first locks out every existing install at
   once, and the debug provider is what dev builds need.
3. **SHA-256 fingerprints for both the upload key and the Play app signing key.**
   Registering only the upload key is the classic failure: sign-in works in debug
   and fails for every real user.
4. **Enforcement on**, once the metrics show real traffic.

**Things that are security and are not Firebase:**

- **The user database on the device is already encrypted**, which is why its
  contents cannot be read off the emulator even with developer access. That is
  the right default and it should stay.
- **Do not commit the generated Firebase options if this repo ever goes public.**
  They hold no secrets but they do hold project identifiers, and
  `google-services.json` in a public repo invites other people onto your quota.
- **Set a Blaze budget alert on day one.** It does not cap spending, because
  nothing does, but it is the difference between noticing in an hour and noticing
  in a month.
- **Deletion has to actually delete.** The May design routed account deletion
  through a Cloud Function; the function does not exist and the settings row is
  guarded off. Until it does, deletion is a manual promise, and that is a legal
  exposure rather than a missing feature.

---

## 6. What this brief does not decide

- **Whether Free students ever get a backup**, which is section 3's option C and
  reverses a guard.
- **Whether the May auth design is amended or superseded.** It is currently
  neither, and it disagrees with the code in at least two places.
- **Whether Cloud Functions stay in the manifest.** Nothing calls them, and both
  export and deletion assume them.

---

## 7. Option B costed properly, and a correction

**Asked directly: what if everyone who signs in can sync?** Here is the
arithmetic, and it changes the argument.

### What one student writes in a day

Measured from the sync registry rather than guessed. Nine collections, seven
active, and the shapes differ:

| What | Documents |
|---|---|
| An attempt | **One document per session.** The items are packed into one field, so a 20-question quiz is 1 write, not 20 |
| Review state | **One document per question answered.** This is the dominant term |
| A lesson read | One document |
| Flags, bookmarks, preferences | A handful, and only when touched |
| A finished mock | One document, and only when terminal |

So a light day is roughly 25 writes and a heavy one 70. **Take 40 writes per
active student per day.**

### The bill

Free tier is 20,000 writes a day, then **$0.18 per 100k writes** and **$0.26 per
GB per month** stored.

| Daily active syncing students | Writes per month | Monthly write cost | Storage after a year | Monthly total |
|---|---|---|---|---|
| 500 | 0.6M | **$0** (inside the free tier) | under 1 GB | **$0** |
| 5,000 | 6M | about **$10** | about 10 GB, $2.60 | **about $13** |
| 50,000 | 60M | about **$107** | about 100 GB, $26 | **about $133** |

**Storage is bounded better than it looks.** Review state is updated in place, one
document per question, so it stops growing at the size of the corpus rather than
with time. Attempts do append, at roughly 2 MB per student per year.

**Reads are near zero today**, because nothing downloads. If a restore is built it
costs the student's whole history once per new device, a few thousand reads, which
is cents. **The danger is only a restore that runs on every launch instead of once**,
and that is a code review question, not a pricing one.

### The correction

**I led with cost as the reason to keep sync for Pro. The arithmetic does not
support that.** At any scale this app is likely to reach, letting every signed-in
student sync costs tens of dollars a month, not hundreds. **Cost is not the
deciding factor and I should not have implied it was.**

### So what actually decides it

**For letting everyone sync:**

- **It is the humane answer.** The students most likely to lose a phone are the
  ones this app is for, and losing months of work is the worst thing the app can
  do to someone.
- **A signed-in Free student who gets nothing for signing in feels tricked**, and
  no copy fully fixes that.
- **It makes sign-in worth doing**, which is what gives you a stable identity to
  measure retention against rather than a device id.
- **It is cheap**, per above.

**Against:**

- **It spends the clearest thing Pro sells.** "Your progress follows you to any
  phone" is concrete to a student who does not yet believe question banks are
  worth paying for. Sold once, it cannot be sold again.
- **The downside is unbounded even though the expected cost is not.** Firebase has
  no spending cap. A bad query shipped to 50,000 students is a four-figure day,
  and the blast radius is proportional to how many people sync.
- **It is abuse surface.** Every syncing account is writable storage behind an
  account anyone can create. App Check and rules make that expensive rather than
  impossible.
- **Right now it buys nobody anything.** See below.

### The finding that outranks the pricing

**Sync is upload only. Nothing downloads it.** The engine flushes a pending queue
upward; the only cloud read anywhere is a yes-or-no check at sign-in for whether
an account already has data, used to detect a collision.

**So the phrase "your progress follows you to a new phone" is not true for anyone
today, Pro included.** Uploads accumulate and no code restores them.

**That reorders the question.** Deciding who may sync is deciding who may *back
up*, and until a restore exists, extending it to Free students would pay to
upload data that nobody, Free or Pro, can get back.

**Recommended, revised:**

1. **Build the restore first.** It is what makes sync mean anything, it is
   required before Pro can honestly advertise it, and it is the same work
   whichever way the boundary goes.
2. **Then let everyone signed in sync**, because the cost is small and the
   goodwill is not, and find a different concrete promise for Pro. The mock
   papers and the unlimited practice are that promise; cross-device backup is a
   thin moat to build a subscription on.
3. **Set the budget alert regardless.** The expected bill is trivial; the
   worst case is not bounded by anything except noticing.

---

## 8. Decided: backup is Pro only

**Aedwon, 11 August:** *"let's just stick with only Pro can backup. your Free
argument of them losing their phone is such a highly unlikely event, and even
then their biggest problem isn't even the app itself."*

**He is right and I over-weighted it.** I built an argument on a rare event and on
a student whose worse problem, if it happens, is not the reviewer app. Option A
stands: **a Free student is local only whether or not they sign in.**

**What survives from section 7 regardless of the boundary:**

- **The restore still has to be built**, because Pro cannot honestly be sold
  cross-device backup that no code performs.
- **Sign-in copy still has to be honest** about what signing in does for a Free
  student, which is now: nothing, until they subscribe.

---

## 9. Usage data: Firebase Analytics, and it needs no account

**Asked directly: does Firebase handle usage data, including for Free anonymous
users?** Yes, and this is entirely separate from sync.

**Analytics is device-scoped, not account-scoped.** It keys on an app-instance id
the SDK generates. **A student who never signs in is measured exactly as well as a
Pro subscriber.** Nothing about the Pro-only backup decision touches this.

### What is already built, not planned

**All eleven events exist and emit today.** They go nowhere only because no
Firebase project exists yet. Grouped by the question each answers:

| Question | Events |
|---|---|
| Do students finish onboarding? | `onboarding_step_reached`, `onboarding_completed` |
| Do they come back? | `session_started` |
| Does anyone reach the paywall? | `paywall_shown` |
| Does anyone buy? | `purchase_started`, `purchase_completed`, `purchase_failed` |
| Which surfaces are dead? | `tab_opened` |
| Does the mock work at all? | `mock_started`, `mock_completed`, `mock_abandoned` |

### The constraint that governs all of it

**Consent defaults to false.** Until a student turns on "Help improve the app",
the telemetry provider hands back the no-op implementation and **nothing is
sent**. Turning it off later also calls the Firebase SDKs' own disable, so
collection stops rather than being silently ignored.

**So every number will be a sample of the consenting, not of everyone.** That is a
floor under RA 10173, not a setting to reconsider, and it has a practical
consequence: **absolute counts are not the population**, so read rates and ratios
rather than totals.

### What the current set does NOT do, and what it would take

**Button-level tracking is not in it.** `tab_opened` records which of five tabs
was opened. Nothing records that a particular button was pressed.

**The plan forbids adding a twelfth event without a decision**, deliberately, and
the property rules are enforced in code rather than by convention: **a property
must be an int, a bool, or a short identifier from a closed set, and no event may
carry a question's text, a student's answer, a score, a name, an email or any free
text.** An attempt to log otherwise throws.

**So "how many times was this button pressed" is a spec change**, not a
configuration change. It is a reasonable one, and the cheap version is a single
`element_tapped` event with the element's identifier as a closed-set property,
rather than one event name per button, which would eat the 500-name budget.

### The thing to do on day one, because it cannot be undone later

**Link BigQuery export immediately.** Two reasons:

1. **The Firebase console cannot answer "at what time".** It gives you event
   counts and a handful of built-in breakdowns. Arbitrary questions, hour of day,
   sequences, cohorts, funnels of your own shape, all need the raw event tables.
2. **The export is not retroactive.** Data from before you link is never
   importable. **Every month you delay is a month you can never analyze**, and
   this is the single most expensive thing to get wrong here, because it costs
   nothing to get right.

**It is free**, in the BigQuery sandbox, for Analytics and Crashlytics both.

### Marketing use, and the one line to watch

Using this for marketing is fine and is what the consent copy already implies.
**The line is between measuring behaviour in aggregate and building a profile of a
person.** The property rules keep the app on the right side of it by construction:
no identifiers beyond a closed set, no free text, no answers. **Keep that
enforcement.** It is the difference between a defensible privacy promise and one
that depends on nobody adding a careless call site.
