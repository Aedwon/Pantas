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
