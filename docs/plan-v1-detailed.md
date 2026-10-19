# ZAD (زاد) — Project Plan

> Surplus-meal marketplace connecting restaurants with nearby users to reduce food waste, plus AI forecasting
> of future surplus. Brand: dark green, leaf motif. Market: Oman (Muscat first).
> This file is the single source of truth for scope and architecture. Update it when decisions change.

---

## 1. Assumptions & clarified requirements

### 1.1 Answers from the clarification round
| Question | Answer | Impact on plan |
|---|---|---|
| Project context | **University / graduation project** | Solo developer, demo + report (deadline not yet fixed). Legal/compliance work is documented, not lawyer-reviewed. Infra kept cheap. |
| Claim & payment | **Reserve with a hold, pay at pickup** | `reservations` table + pickup code. No payment gateway in MVP. |
| Forecast data sources | **Daily in-app log + CSV upload from POS + synthetic data** | Daily log + synthetic generator are Must tier. CSV import is Could tier. Live POS integration is out of scope. |
| Language | **English first, Arabic later** | All UI strings go through i18n keys and all layout uses start/end (never left/right) from day one, so Arabic + RTL is a translation task later, not a rewrite. |
| Team & time | **Solo developer, ~10 hours/week** | Everything is sized for one person. Effort is in **hours**, grouped into Must / Should / Could tiers (§11). Zero-ops infrastructure is preferred (no server to maintain in the core plan). |
| Deadline | **Not decided yet** | The roadmap is milestone-based, with a "≈ weeks at 10 h/week" projection per tier. Once the deadline is known, pick the tier that fits (§11.4). |
| Tech stack (changed 2026-10-18) | **Flutter · Django + DRF · Python (AI) · MongoDB Atlas** | Replaces Expo + Supabase. Auth, permissions and API are now Django code, plus one VPS to run. Must tier grows by ~20 h (§2, §11). |

### 1.2 Stated assumptions (change these if wrong)
1. **Team:** one developer at ~10 h/week (~40 h/month), using Claude Code to speed up implementation. Estimates are still conservative because permissions, push and maps need hands-on device testing.
2. **Launch area:** Muscat. Time zone `Asia/Muscat` (UTC+4). Weekend is Friday–Saturday.
3. **Currency:** OMR, stored as **integer baisa** (1 OMR = 1000 baisa) to avoid float errors. `price = 0` means free.
4. **Pickup only.** No delivery.
5. **One location per restaurant account.** Multi-branch support comes later.
6. **Login is required to browse** (keeps location data and abuse under control). Guest browsing is a later option.
7. **Restaurants need admin approval** before their offers become visible.
8. **Ratings: yes**, lightweight (1–5 stars plus optional tags). Only users with a *collected* reservation can rate. Could tier (§11.3).
9. **Demo platform:** Android physical devices are the primary target. iOS is supported by the code but optional for the demo (it needs a $99/yr Apple Developer account for push).
10. **"Meal type"** = a category enum (main dish, sandwich/wrap, bakery, dessert, mixed box, salad, drinks) plus dietary tags (vegetarian, vegan, contains nuts/dairy/gluten/seafood/egg).
11. **Forecast target:** total surplus meals per restaurant per day, for the next 7 days. Per-category forecasts are a later phase.
12. **Notifications** are based on the user's last foreground location or a saved "home area". No background location tracking in MVP.

### 1.3 Decisions on the open questions (section 5 of the brief)
| Decision | Recommendation | Why |
|---|---|---|
| Reservation vs first-come | **Reservation with a time-boxed hold + 6-digit pickup code** | Prevents wasted trips. The pickup code turns "collected" into a *verified* event, so "meals rescued" stats can be trusted. |
| Rating system | **Yes, reservation-gated, Could tier** (built after the core loop, AI and trust features) | Builds trust, cheap to build, impossible to fake without a verified pickup. |
| Payment | **Pay at pickup (cash/card at the counter)** in MVP. In-app payment later via an Omani gateway (e.g. Thawani Pay / bank card acquirer). | Avoids merchant onboarding, refunds and payouts. App stores allow external payment for physical goods, so no IAP is needed. |
| Notification radius & spam | Per-user radius (1/3/5/10 km, default 3), daily cap (default 3), 6 h per-restaurant cooldown, quiet hours, preference filters. Details in §6.4. | Keeps notifications relevant. Spam is the #1 reason users disable push. |
| Arabic/RTL | **Deferred to a post-MVP phase, but i18n-ready from day one** | Per your answer. Flagged as a risk because the target audience is Omani (see §12). |
| AI cold start | Tiered: onboarding questionnaire + cuisine prior → shrinkage blend → per-restaurant model → global ML model. CSV import skips cold start. Details in §7.6. | Every restaurant gets a (clearly labelled) estimate from day one. |

### 1.4 Over-scoped for a first version (explicitly cut)
- Live POS integrations (Foodics, etc.). CSV upload covers the need.
- In-app payments, refunds, payouts.
- Background location / OS-level geofencing (app-store scrutiny, battery, privacy).
- ML forecasting *before* a baseline exists. ML is only promoted if it beats the baseline in backtests.
- A separate web admin dashboard (kept in-app as required; the backend is designed so one can be added later).
- In-app chat between users and restaurants, delivery, multi-branch restaurants, a charity/NGO role.
- Real-time live-updating map. Pull-to-refresh plus realtime updates only on reservation status is enough.
- **Solo-specific cuts:** a separate forecast service (the forecast runs inside the Django worker as a nightly task), the LightGBM model, map marker clustering, notification quiet hours and preference filters (Should tier), and CSV import (Could tier, since the daily log + synthetic data are enough for the demo).

---

## 2. Tech stack

**Stack decision (2026-10-18, project owner): Flutter · Django · Python (AI) · MongoDB.** This replaces the earlier Expo + Supabase plan.

| Layer | Choice | Why | Alternatives |
|---|---|---|---|
| Mobile app | **Flutter (stable) + Dart**, `go_router`, **Riverpod** | One codebase for Android and iOS. Built-in RTL (`Directionality`) makes the later Arabic phase cheaper. Smooth maps and animations. | React Native/Expo (previous plan). |
| UI | Material 3 + a **`ZadColors` `ThemeExtension`** mirroring the Figma "ZAD tokens"; **`google_fonts`** (Bricolage Grotesque, Readex Pro, DM Mono); **`fl_chart`** for the forecast chart; `flutter_form_builder` for forms | Keeps Figma and code in sync; no hex values in widgets. | — |
| Networking & models | `dio` (JWT refresh interceptor), `freezed` + `json_serializable`; OpenAPI schema from `drf-spectacular` | Typed models matching the API. | — |
| i18n | `flutter_localizations` + `intl` ARB files (`flutter gen-l10n`); `EdgeInsetsDirectional` / `AlignmentDirectional` everywhere | English now, Arabic + RTL later as a translation task. | — |
| Maps & location | `google_maps_flutter`, `geolocator`, `geocoding`, `url_launcher` (directions) | Good Oman coverage; one map SDK on both platforms. | `flutter_map` + OSM tiles. |
| Push | **Firebase Cloud Messaging**: `firebase_messaging` (app) + `firebase-admin` (server) | Free; Android and iOS (via an APNs key) through one API. | OneSignal. |
| Backend | **Django 5 + Django REST Framework**, `djangorestframework-simplejwt`, `django-otp` (admin TOTP), `django-filter`, Argon2 hashing | Auth, permissions, throttling and an admin site out of the box; same language as the AI code. | FastAPI (lighter, but auth, admin and permissions are all hand-built). |
| Database | **MongoDB Atlas** via the official **`django-mongodb-backend`** (Django ORM on MongoDB). Raw aggregation (`raw_aggregate` or PyMongo) for `$geoNear` and stats pipelines | Owner's choice. Geo queries (`2dsphere`, `$geoNear`) are first-class. Atlas gives a replica set (needed for transactions), backups and a free M0 tier. | PostgreSQL + PostGIS (stronger relational constraints). MongoEngine (mature, but no Django auth/admin). |
| Background jobs | **django-q2** with its **MongoDB broker**: scheduled and async tasks, no Redis | Fewest moving parts for one developer. | Celery + Redis. |
| AI forecasting | **Python 3.12 package `zad_forecast`** (pandas, statsmodels, scikit-learn; LightGBM later), run as a **nightly django-q2 task** in the worker container | Same language and deployment as the backend; no separate service to host. | Separate FastAPI service (no longer needed). |
| Media | Offer photos and logos on a Docker volume served by nginx at `/media/`; validated and re-encoded with Pillow | Free and simple. | Cloudinary / S3 later. |
| Hosting | **One small VPS** (~$6/mo) running **Docker Compose**: nginx (Let's Encrypt TLS) + Django/gunicorn + django-q2 worker. **MongoDB Atlas** (M0 free for dev/demo, in the closest region the tier allows, e.g. Bahrain, UAE, Mumbai or Frankfurt; measure latency) | Matches your Docker + nginx skills. | Render / Railway (less ops, higher cost). |
| CI | GitHub Actions: `flutter analyze` + `flutter test`; `ruff` + `pytest` (backend + forecast) against a MongoDB service container | — | — |
| Testing | `flutter_test` + `integration_test`; **pytest-django** (permissions per role, reservation concurrency); pytest for forecasting; **Maestro** for E2E | — | — |

**What changes compared with the Supabase plan**
- **More backend code:** auth, permissions and every endpoint are now Django code (Supabase gave these for free). The Must tier grows by about 20 h (§11).
- **Security moves from the database to the API:** DRF permission classes + querysets scoped to the signed-in user, proven by pytest for every endpoint × role.
- **A server to run:** one VPS with Docker Compose. Backups, TLS renewal and updates are now your job (§12).
- **MongoDB has no foreign keys or CHECK constraints:** use model validation, `$jsonSchema` validators, unique/partial indexes, and multi-document transactions for reservations.
- **Gains:** Flutter's RTL support makes Arabic cheaper; the Django admin site helps during development; the AI code sits next to the backend.
- **`django-mongodb-backend` is young:** pin versions, and in week 1 spike the two risky pieces (a `$geoNear` query and a reservation transaction). Fall back to PyMongo for anything the ORM layer doesn't support.

---

## 3. System architecture

```
┌──────────────── Flutter app (single binary, Android first) ────────────────┐
│ route groups: auth · user · restaurant · admin (go_router)                  │
│ Riverpod · dio · google_maps_flutter · geolocator · firebase_messaging      │
└───────────────┬─────────────────────────────────────────────▲──────────────┘
                │ HTTPS REST /api/v1 (JWT)                    │ push (FCM → APNs/Android)
                ▼                                             │
┌──────────── VPS · Docker Compose ───────────────────────────┼──────────────┐
│ nginx — TLS, /media, rate limits                            │              │
│ web — Django + DRF (gunicorn)                               │              │
│ worker — django-q2 cluster                                  │              │
│   on offer posted: notify_nearby ───── firebase-admin ──────┘              │
│   every 1 min: expire holds/offers, count no-shows                         │
│   nightly 02:00 Asia/Muscat: run_forecast (zad_forecast)                    │
│ volume — media (photos, logos)                                              │
└───────────────┬────────────────────────────────────────────────────────────┘
                │ TLS (PyMongo / django-mongodb-backend)
                ▼
┌──────── MongoDB Atlas (replica set) ────────┐
│ collections · 2dsphere + unique indexes     │
│ django-q2 broker collection · backups       │
└─────────────────────────────────────────────┘
```

**Key data flows**
1. **Post surplus:** the restaurant calls `POST /offers` → service validates (approved restaurant, safety attested, times) → saves → queues `notify_nearby(offer_id)` → worker finds users with `$geoNear` + anti-spam filters → FCM → rows in `notifications`.
2. **Browse:** the app gets its location → `GET /offers/nearby` → `$geoNear` on `offers` → map pins and cards.
3. **Reserve:** `POST /offers/{id}/reserve` → one transaction: conditional decrement of `quantity_available` + new reservation with a pickup code (§5.3). The restaurant gets an FCM data message, and Restaurant home also refreshes every 15 s while open (no realtime channel in MVP).
4. **Collect:** the user shows the code → the restaurant calls `POST /pickups/confirm` → reservation `collected` → stats.
5. **Expire:** a worker task every minute expires holds (returns quantity), closes offers past `expires_at`, and counts no-shows.
6. **Forecast:** the nightly task reads `daily_logs` + offer history + calendar → writes `forecasts` and `forecast_runs` → the restaurant app reads `GET /forecasts`.

**Environments:** **local** = Docker Compose with Django, the worker and MongoDB as a **single-node replica set** (transactions need it); the Android emulator reaches the API at `http://10.0.2.2:8000`. **prod** = the VPS + MongoDB Atlas.

**Repo layout (monorepo)**
```
zad/
  app/                    Flutter app
    lib/core/             theme (ZadColors), l10n, api client, routing
    lib/features/         auth, user, restaurant, admin
  backend/
    zad/                  Django project (settings, urls)
    apps/                 accounts, restaurants, offers, reservations, notifications,
                          reports, forecasting, adminpanel   (each: models, serializers,
                          services.py, views, permissions, tasks)
    tests/                pytest-django
  forecast/               Python package zad_forecast (features, models, backtest,
                          synthetic, run) + pytest; installed into the backend image
  infra/                  docker-compose.dev.yml, docker-compose.prod.yml, nginx.conf, Dockerfiles
  .github/workflows/      ci.yml
  docs/                   report material, devlog
  CLAUDE.md
```

---

## 4. Data model

**MongoDB collections** (models via `django-mongodb-backend`). Every document has an `_id` (ObjectId), UTC `created_at` / `updated_at`; references are ObjectIds. "Table" below means collection. Enums are model `choices`; checks are model validation plus `$jsonSchema` validators on `offers` and `reservations`.

### 4.1 Entities
| Table | Key fields | Notes |
|---|---|---|
| `users` (custom Django user model) | `_id`, `email` (unique), `password` (Argon2 hash), `role` enum(`user`,`restaurant`,`admin`), `full_name`, `phone?`, `locale` (default `en`), `status` enum(`active`,`suspended`), `no_show_count_30d`, `reservation_blocked_until?` | `role` is set at signup to `user` or `restaurant` only. `admin` can only be set by a management command or an admin endpoint. `role` and `status` are read-only in serializers. |
| `user_settings` | `user_id` PK, `notify_enabled`, `notify_radius_km` (1/3/5/10), `home_location` (GeoJSON Point)?, `last_location` (GeoJSON Point, 2dsphere index)?, `last_location_at`, `daily_notify_cap` (default 3), `quiet_start`/`quiet_end` (time), `pref_cuisine_ids array`, `pref_free_only bool` | Locations are rounded to ~100 m (3 decimal places) before storing. Only the latest value is kept, with no history. |
| `push_tokens` | `_id`, `user_id`, `fcm_token` unique, `platform`, `last_seen_at` | Deleted when FCM reports the token as `UNREGISTERED`. |
| `cuisines` | `id` serial, `name_en`, `name_ar`, `icon` | Seeded (Omani, Arabic, Indian, Pakistani, Turkish, Lebanese, Italian, Asian, Fast food, Bakery & sweets, Café, Healthy). |
| `restaurants` | `id`, `owner_id`→profiles (unique: one per owner), `name`, `cuisine_id`, `description`, `phone`, `address_text`, `location` (GeoJSON Point `[lng, lat]`) + **2dsphere index**, `logo_url`, `cr_number?` (commercial registration), `verification_status` enum(`pending`,`approved`,`rejected`,`suspended`), `typical_daily_meals?`, `typical_surplus_pct?` (cold-start answers), `rating_avg`, `rating_count`, `safety_terms_accepted_at` | Offers are only visible when `approved`. |
| `offers` | `id`, `restaurant_id`, `title`, `description`, `category` enum, `dietary_tags array`, `allergens array`, `photo_url?`, `original_price_baisa?`, `price_baisa` (0 = free), `quantity_total`, `quantity_available`, `prepared_at`, `pickup_start`, `pickup_end`, `expires_at` (≤ `pickup_end`), `status` enum (see 4.3), `location` + `restaurant_name` + `cuisine_id` (copied from the restaurant so `$geoNear` runs directly on `offers`; 2dsphere index), `max_per_user` (default 3; 1 if free), `safety_attested bool` (must be true) | Validated (model + `$jsonSchema`): `0 ≤ quantity_available ≤ quantity_total ≤ 100`; `pickup_end > pickup_start`; `pickup_end - created_at ≤ 12h`. |
| `reservations` | `id`, `offer_id`, `user_id`, `quantity`, `pickup_code` (6 digits, unique among active ones per offer), `status` enum(`reserved`,`collected`,`cancelled`,`expired`), `hold_expires_at`, `collected_at?`, `cancelled_by?` | One active reservation per user per offer (partial unique index on `{offer_id, user_id}` where `status = 'reserved'`), and at most 2 active reservations per user overall. |
| `ratings` | `id`, `reservation_id` unique, `user_id`, `restaurant_id`, `stars` 1–5, `tags array`, `comment?` (≤ 300 chars) | Created only via `POST /ratings`. Only for a `collected` reservation, within 7 days. |
| `reports` | `id`, `reporter_id`, `target_type` enum(`offer`,`restaurant`,`user`,`rating`), `target_id`, `reason` enum(`food_safety`,`misleading`,`no_show`,`rude_or_abusive`,`inappropriate_content`,`other`), `details`, `status` enum(`open`,`in_review`,`resolved`,`dismissed`), `priority` (food_safety = high), `handled_by?`, `resolution_note?` | |
| `notifications` | `id`, `user_id`, `type` enum(`new_offer_nearby`,`reservation_reminder`,`hold_expiring`,`reservation_cancelled`,`restaurant_approved`, …), `offer_id?`, `title`, `body`, `sent_at`, `read_at?` | Also used to enforce the cap and cooldown. |
| `daily_logs` | `id`, `restaurant_id`, `log_date` date, `meals_prepared`, `meals_sold`, `meals_surplus`, `meals_discarded?`, `notes?`, `source` enum(`manual`,`csv`,`synthetic`), unique(`restaurant_id`,`log_date`) | **Training data.** Validated: `meals_surplus ≤ meals_prepared`. |
| `csv_imports` | `id`, `restaurant_id`, `storage_path`, `rows_total`, `rows_ok`, `rows_rejected`, `errors object`, `status` | Audit trail for uploads. |
| `forecasts` | `id`, `restaurant_id`, `target_date`, `predicted_surplus` (numeric), `lower_p10`, `upper_p90`, `confidence` enum(`low`,`medium`,`high`), `model_name`, `model_version`, `cold_start_tier` (0–3), `explanations object`, `run_id`, unique(`restaurant_id`,`target_date`,`run_id`) | Written only by the forecast task. |
| `forecast_runs` | `id`, `started_at`, `finished_at`, `status`, `model_name`, `model_version`, `n_restaurants`, `metrics object` (MAE, WAPE, bias, coverage, per model) | Shown on the admin data-quality screen. |
| `calendar_days` | `day` PK, `is_weekend`, `is_public_holiday`, `holiday_name?`, `is_ramadan`, `is_eid`, `is_school_holiday`, `is_payday_window` | Seeded for 2024–2027. Used as forecast features. |
| `admin_audit_log` | `id`, `admin_id`, `action`, `target_type`, `target_id`, `details object`, `created_at` | Append-only, written by admin endpoints. |

**Relationships** (ObjectId references): users 1–1 user_settings; users 1–0..1 restaurants (owner); restaurants 1–N offers, daily_logs, forecasts; offers 1–N reservations; reservations 1–0..1 ratings; users 1–N reservations, push_tokens, notifications, reports.

**Derived data:** aggregation pipelines (not stored) back the stats endpoints: restaurant stats (posted, reserved, collected, rescue rate, by week), admin overview, and data quality (§7.8). Offers carry denormalised restaurant fields, so the public offer view needs no join.

### 4.2 Reservation lifecycle
```
reserve_offer() ─► reserved ──confirm_pickup()──► collected   (meals rescued += quantity)
                     │ ├──user/restaurant cancels──► cancelled  (quantity returned to offer)
                     │ └──hold_expires_at passed───► expired    (quantity returned; no_show_count++ if inside pickup window)
```
`hold_expires_at = min(max(now, pickup_start) + 30 min, pickup_end)`. If the user reserves before the pickup window opens, the hold runs until 30 minutes after it opens.

### 4.3 Offer lifecycle
```
            create (restaurant approved, safety_attested)
                         │
                         ▼
   ┌──────────────── active ◄──────────────┐ (reservation cancelled/expired returns quantity)
   │                     │ quantity_available = 0
   │                     ▼
   │                  sold_out ────────────┘
   │                     │
   │  restaurant cancels │ now > expires_at (cron)
   ▼                     ▼
cancelled             closed  ── final stats: collected qty vs posted qty
   ▲                     (uncollected units counted as "not rescued")
   │ admin
removed (admin moderation, hidden + reason)
```
- `active` / `sold_out` are visible to users. Every other status is history only.
- Status changes happen only in backend service functions (action endpoints and scheduled tasks), never through client updates (`status` is read-only in every serializer).
- The brief's "collected / expired" maps to this: *collected* is per reservation (verified by code), and *expired* is the offer reaching `closed` with uncollected units.

---

## 5. API design (Django REST Framework)

**Principles**
- REST under `/api/v1/`, JSON, JWT bearer auth (`simplejwt`). OpenAPI schema via `drf-spectacular`.
- **Default deny:** `IsAuthenticated` globally plus an explicit role permission on every view. Querysets are always scoped to `request.user`; clients never send owner ids.
- **Every state change goes through a service function** (`reserve_offer`, `confirm_pickup`, `cancel_offer`, …) called from an action endpoint or a scheduled task. `status`, `role`, `verification_status`, counters and rating fields are **read-only in every serializer**.
- **Throttling:** DRF scoped throttles (e.g. reserve 10/min, confirm-pickup 10 wrong codes per offer per 10 min, reports 5/day) + nginx `limit_req` on `/auth/`.

### 5.1 Endpoints
| Method & path | Who | What |
|---|---|---|
| `POST /auth/register` | anyone | Email, password, name, `role` ∈ {user, restaurant}; sends a verification email |
| `POST /auth/login` · `/auth/refresh` · `/auth/logout` | anyone / signed in | JWT access (15 min) + rotating refresh (30 days); logout blacklists the refresh token |
| `POST /auth/password/forgot` · `/auth/password/reset` | anyone | Reset email with an app link (`zad://reset-password?uid=…&token=…`) |
| `POST /auth/mfa/setup` · `/auth/mfa/verify` | admin | TOTP (django-otp); a verified login issues tokens with an `mfa: true` claim |
| `GET/PATCH /me` · `DELETE /me` | signed in | Profile (role/status read-only); delete anonymises history and removes tokens + location |
| `PUT /me/location` · `PUT /me/settings` · `POST /me/push-tokens` | user | Location rounded to 3 decimals; notification prefs; FCM token |
| `GET /offers/nearby` | user | `lat, lng, radius_km=5, cuisine, max_price_baisa, free, pickup_before, category, sort, page` → `$geoNear` on `offers`, returns `distance_m` |
| `GET /restaurants/nearby` | user | Restaurants with active-offer counts (map pins) |
| `GET /offers/{id}` | user | Offer + restaurant summary, allergens, disclaimer |
| `POST /offers/{id}/reserve` | user | `{quantity}` → reservation + pickup code (§5.3) |
| `GET /reservations` · `POST /reservations/{id}/cancel` | user | Own reservations (upcoming / history) |
| `GET /notifications` · `POST /notifications/{id}/read` | user, restaurant | Own inbox |
| `POST /ratings` | user | Own `collected` reservation, within 7 days (Could) |
| `POST /reports` | user, restaurant | Max 5/day; food-safety auto-hide rule (§9.3) |
| `POST /restaurants` · `GET/PATCH /restaurants/me` | restaurant | Onboarding (pin-drop location, cuisine, cold-start answers); starts `pending` |
| `POST /offers` · `PATCH /offers/{id}` · `POST /offers/{id}/cancel` | approved restaurant (owner) | Validates times, quantity, `safety_attested`; quantity can only shrink to ≥ reserved units |
| `GET /restaurants/me/reservations` | restaurant | Waiting / collected for its offers (first name + code status only) |
| `POST /pickups/confirm` | restaurant | `{offer_id?, code}` → `collected`; wrong-code lockout |
| `GET /daily-logs` · `PUT /daily-logs/{date}` | restaurant | Date ≤ today and ≥ today − 60 days |
| `POST /daily-logs/import` | restaurant | CSV preview + import (Could) |
| `GET /forecasts` · `GET /restaurants/me/stats` | restaurant | 7-day forecast (range, confidence, explanations); stats aggregation |
| `GET /admin/overview` | admin + MFA | Users, restaurants by status, meals posted vs rescued, no-show rate, open reports |
| `GET /admin/restaurants` · `POST /admin/restaurants/{id}/status` | admin + MFA | Approve / reject / suspend (suspending hides its offers) |
| `GET /admin/users` · `POST /admin/users/{id}/status` | admin + MFA | Suspending cancels the user's active reservations |
| `POST /admin/offers/{id}/remove` | admin + MFA | Status → `removed`, with a reason |
| `GET /admin/reports` · `POST /admin/reports/{id}/resolve` | admin + MFA | Should tier |
| `GET /admin/data-quality` · `GET /admin/forecast-runs` | admin + MFA | Should tier (§7.8) |
| `GET /admin/audit-log` | admin + MFA | Read-only (Should) |
| `POST /admin/forecast/run` | admin + MFA | Could tier |

Every admin write also appends to `admin_audit_log`.

### 5.2 Background tasks (django-q2 worker)
| Task | When | Purpose |
|---|---|---|
| `notify_nearby(offer_id)` | queued when an offer becomes `active` | Candidate users + anti-spam (§6.4), FCM send, `notifications` rows |
| `expire_holds_and_offers` | every minute | Expire holds (return quantity, count no-shows inside the window), close offers past `expires_at` |
| `send_reminders` | every 5 min (Should) | "Pickup window opens in 15 min" / "Your hold ends in 10 min" |
| `run_forecast` | nightly 02:00 Asia/Muscat | §7.5 |
| `cleanup` | nightly | Old notifications, stale push tokens |

### 5.3 Atomic reservation (no overselling)
```python
with client.start_session() as s, s.start_transaction():
    offer = offers.find_one_and_update(
        {"_id": offer_id, "status": "active", "quantity_available": {"$gte": qty}},
        {"$inc": {"quantity_available": -qty}},
        return_document=ReturnDocument.AFTER, session=s)
    if offer is None:
        raise SoldOut()
    if offer["quantity_available"] == 0:
        offers.update_one({"_id": offer_id}, {"$set": {"status": "sold_out"}}, session=s)
    reservations.insert_one({..., "status": "reserved", "pickup_code": code,
                             "hold_expires_at": hold_until}, session=s)
```
Checked before the transaction: user active and not blocked, ≤ 2 active reservations, quantity ≤ `max_per_user`. The partial unique index on reservations stops two active reservations of the same offer by one user.

### 5.4 Access rules (DRF permissions + scoped querysets)
| Collection | user | restaurant (owner) | admin |
|---|---|---|---|
| users, user_settings, push_tokens, notifications | own only | own only | read via admin endpoints |
| restaurants | read `approved` | read/update own (not `verification_status`, rating fields); create one | all |
| offers | read `active` / `sold_out` | read all own; writes via service | all |
| reservations | read own | read those on own offers (first name + code status; **no phone, no location**) | all |
| ratings | read public aggregates; create via endpoint | read own restaurant's | all |
| reports | create; read own | same | all |
| daily_logs, csv_imports | — | CRUD own | read |
| forecasts, forecast_runs | — | read own forecasts | read all |
| admin_audit_log | — | — | read (append-only; no update/delete endpoint) |

Permission classes: `IsUserRole`, `IsRestaurantRole`, `IsApprovedRestaurant`, `IsOwner` (object level), `IsAdminWithMFA`.

---

## 6. Maps, geolocation & notifications

### 6.1 Map provider
- **`google_maps_flutter`** on Android and iOS (API keys restricted to the app's package name + SHA-1 / bundle id). The dark map style matches the Figma Home screen (custom JSON map style).
- **One marker per restaurant** with a meals-left badge (Figma "Map pin"). Clustering (`google_maps_cluster_manager`) beyond ~30 markers is Could tier.
- **Restaurant location:** pin-drop on the map during onboarding; `geocoding` fills the address text. No paid geocoding.
- **Directions:** `url_launcher` opens Google Maps / Apple Maps. No in-app routing.

### 6.2 Proximity queries
Offers carry a copy of the restaurant's `location` (GeoJSON `Point`, `[lng, lat]`) with a **2dsphere index**, so the query runs on one collection:
```python
pipeline = [
    {"$geoNear": {
        "near": {"type": "Point", "coordinates": [lng, lat]},
        "distanceField": "distance_m",
        "maxDistance": radius_km * 1000,
        "spherical": True,
        "query": {"status": {"$in": ["active", "sold_out"]}, "expires_at": {"$gt": now}},
    }},
    {"$limit": 50},
]
offers = Offer.objects.raw_aggregate(pipeline)   # or PyMongo aggregate()
```
`$geoNear` must be the first stage. Suspending a restaurant hides its offers (status change), so the query needs no join. Distances are straight-line ("~2.1 km away").

### 6.3 Location capture (privacy-first)
- Ask for **"while using the app"** permission only (`geolocator`). On app open/resume, call `PUT /me/location` (throttled to once per 10 min).
- If permission is denied, the user sets a **home area pin**. Browsing still works from that pin.
- Stored rounded to about 100 m, latest value only. Never shown to restaurants or other users. Deleted with the account.
- A user is eligible for "nearby" notifications if `last_location_at` is within 48 h, otherwise `home_location` is used; with neither, no geo notifications.

### 6.4 Geofenced notifications & anti-spam
Done **server-side** in the `notify_nearby` task (no OS geofencing). **Must tier = rules 1, 2, 4, 5, 7, 8; Should tier adds 3 and 6.** When an offer becomes `active`, select users where:
1. Their point (fresh `last_location`, else `home_location`) is within their `notify_radius_km` of the restaurant (`$geoNear` on `user_settings` with the max radius of 10 km, then filter by each user's radius).
2. `notify_enabled`, account active, at least one FCM token.
3. Not in quiet hours (default 23:30–08:00 Asia/Muscat; editable).
4. Fewer than `daily_notify_cap` (default 3) `new_offer_nearby` notifications today.
5. No notification for **this restaurant** in the last 6 h.
6. Matches preferences (cuisine filter, free-only).
7. Offer still has at least 20 min before `pickup_end` and at least 1 unit available.
8. Not the restaurant owner.

Send with `firebase-admin` (`send_each`, batches of up to 500); delete tokens FCM reports as `UNREGISTERED`. Message: "🍃 {Restaurant} just posted surplus 1.2 km away — {title}, {price|Free}, pickup until {time}". Tapping it deep-links to Meal details. Transactional notifications (reservation confirmed or cancelled, hold ending, restaurant approved, new reservation for restaurants) are **not** capped.

---

## 7. AI forecasting design

### 7.1 Goal & framing
Predict **how many meals a restaurant will have left over each day for the next 7 days**, with a range. This is *decision support*: it helps the restaurant prepare less and plan surplus listings. **A forecast never creates an offer** and never shows availability to users.

### 7.2 Input data
| Source | Fields | Notes |
|---|---|---|
| `daily_logs` (manual / CSV / synthetic) | prepared, sold, surplus, discarded | **Primary label = `meals_surplus`.** |
| Offers & reservations | quantity posted, quantity collected, posting time | Secondary signal. Posted quantity is a *lower bound* on real surplus (restaurants may not post everything), so it is used as a feature and a fallback label only. |
| `calendar_days` | weekday, Fri/Sat weekend, public holidays, Ramadan, Eid, school holidays, payday window (around the 20th–25th) | Ramadan changes Omani eating patterns a lot, so it is a key feature. |
| Restaurant attributes | cuisine, `typical_daily_meals`, `typical_surplus_pct`, age on platform | Used by the cold start and the global model. |
| Weather (later phase, optional) | daily max temperature, rain flag via Open-Meteo (free) | Heat affects dine-in traffic. |

### 7.3 Features
Lags of surplus (t−1, t−7, t−14), same-weekday mean over the last 4 weeks, 7- and 28-day rolling mean/std, surplus rate (surplus/prepared) with EWMA, prepared-volume trend, calendar flags, cuisine one-hot, days since onboarding. Missing days are kept missing (never filled with 0).

### 7.4 Model ladder (start simple, promote only on evidence)
| Level | Model | When used |
|---|---|---|
| M0 | **Seasonal naive**: same weekday last week | Baseline every other model must beat. |
| M1 | **Seasonal moving average**: mean of the last 4 same-weekdays, adjusted by a Ramadan/holiday multiplier learned from data | **MVP production model** for restaurants with ≥14 days of logs. |
| M2 (Should tier) | **Rate model**: forecast prepared (M1 on prepared) × EWMA surplus rate | Compared against M1 in backtests. |
| M3 (later phase) | **Global LightGBM** trained across all restaurants, quantile objectives (P10/P50/P90) | Promoted only if WAPE improves ≥10% over M1 on backtests with real data. Needs ≥8 weeks of history across ≥5 restaurants. |

Prediction intervals for M0–M2 come from empirical residual quantiles per restaurant (P10/P90).

### 7.5 Training, serving & evaluation
- **Batch, not real-time.** Nightly at 02:00 Asia/Muscat the `run_forecast` django-q2 task (worker container) loads data, picks each restaurant's tier/model, fits, predicts D+1..D+7, and writes `forecasts`. Re-runs are idempotent per `run_id`.
- M0–M2 are refit each night and need no stored artifacts. Model artifacts (later, for M3) are versioned `joblib` files in a backed-up Docker volume.
- **Evaluation:** a rolling-origin backtest (train up to day t, predict t+1..t+7, slide).
  - **MAE** (meals/day) is the primary, restaurant-facing metric ("off by ~3 meals").
  - **WAPE** = Σ|err| / Σactual is used for cross-restaurant comparison. MAPE is avoided because days with zero surplus break it.
  - **Bias** (mean error) catches systematic over- or under-prediction.
  - **Interval coverage** checks that the share of actuals inside P10–P90 is about 80%.
- **Live monitoring:** each night, compare yesterday's forecast with the logged actual, store it in `forecast_runs.metrics`, and show it to the admin.
- **Synthetic data rules:** `source='synthetic'` rows train the demo and develop the pipeline, but are **excluded from any metric reported as real-world accuracy**. The report must show synthetic and real results separately.

### 7.6 Cold-start handling
| Tier | Data available | Method | Confidence label |
|---|---|---|---|
| 0 | No logs | Onboarding questions ("meals prepared on a typical day?", "roughly what % is usually left?") × weekday profile from the cuisine prior. If unanswered, use the cuisine-median surplus. | Low: "Rough estimate" |
| 1 | 1–13 days | Shrinkage: `w = n/(n+7)`, forecast = w·own_mean_by_weekday + (1−w)·tier-0 prior | Low/Medium |
| 2 | ≥14 days | M1/M2 per restaurant | Medium, or High if recent MAE is below 20% of mean surplus |
| 3 | ≥8 weeks + global model enabled | M3 | Per interval width |

**CSV import** (Could tier) of past POS exports lets a new restaurant jump straight to tier 2 or 3.

### 7.7 How forecasts are shown to restaurants
- **Header card:** "Tomorrow (Fri): expect **~12** surplus meals (range 8–16)" with a confidence badge.
- **7-day bar chart** with a range band. Weekends and holidays are marked.
- **Explanation chips** from the forecast's `explanations` field: "Fridays are usually 40% higher", "Ramadan pattern applied", "Based on 23 days of your data".
- **Actionable hint:** "Consider preparing ~8 fewer portions, or plan a surplus offer around 21:00." Worded as a suggestion.
- **Data nudge:** "Log yesterday's numbers to improve accuracy" (a one-tap form). Accuracy so far is shown as "Last 2 weeks: off by ~3 meals/day on average."
- **Post surplus now** opens Add Surplus *without* pre-filling the quantity from the forecast. The real quantity must be entered (brief: a forecast ≠ availability).

### 7.8 Data-quality monitoring (admin)
- % of approved restaurants that logged yesterday, and the 7-day logging streak distribution.
- Restaurants with gaps longer than 7 days ("stale").
- Rule violations caught at write time: surplus > prepared, negative values, future dates.
- Outliers: surplus > 3× the restaurant's median, or a jump > 3σ.
- Logged surplus vs posted quantity mismatch (posted > logged on the same day means inconsistent logging).
- Share of synthetic vs CSV vs manual rows.
- Forecast error by restaurant (worst 10) and per tier.

---

## 8. Roles, auth & security

### 8.1 Authentication
- **Custom Django user model** (email login), **Argon2** password hashing, email verification required before reserving or posting.
- **JWT** via `simplejwt`: access 15 min; refresh 30 days, rotated, with a blacklist. Stored in `flutter_secure_storage`; a `dio` interceptor refreshes it.
- **Forgot password:** the email link opens the app (Android App Links / iOS Universal Links, fallback `zad://reset-password`) → `POST /auth/password/reset`.
- **Account type** (`user` / `restaurant`) is chosen at register. Restaurants then onboard and wait in `pending`.
- Phone OTP and social login are deferred (Apple sign-in becomes mandatory on iOS if any social login is added).

### 8.2 Role-based access
- After login the app reads `role` from `GET /me` and routes to the user, restaurant or admin route group. **Routing is UX only; security is DRF permissions + scoped querysets.**
- `role` and `status` are read-only in serializers; only service functions and admin endpoints change them.
- **Admins are created only** with `manage.py create_admin` on the server, or by an existing MFA-verified admin. Every grant is audited.
- The **Django admin site** (`/django-admin/`) is a developer tool only: IP-allowlisted in nginx, superuser with TOTP, not part of the product.

### 8.3 In-app admin: evaluation & trade-offs
| | |
|---|---|
| **Pros** | One codebase and one release. Admins can approve restaurants or remove a dangerous offer from their phone straight away, which matters for food-safety response time. Faster for a student project. |
| **Cons / risks** | (1) **Admin screens ship inside the public app**, so anyone can unpack it and see admin routes and endpoint names. That is acceptable *only if* every admin action is authorised on the server; never rely on hidden UI. (2) Admin sessions live on phones that can be lost. (3) Data-heavy work (tables, bulk moderation, charts) is cramped on a phone. (4) Admin endpoints sit on the public API (they reject non-admins, but they are reachable). |
| **Mitigations (required)** | Admin endpoints need `role = admin` **and** an MFA-verified token (`mfa: true`, issued only after a TOTP check with django-otp). **Biometric/passcode re-confirmation** (`local_auth`) before destructive actions. Shorter admin sessions (re-auth after 12 h). Every admin action goes to `admin_audit_log`. Admin endpoints are throttled. pytest proves non-admins and non-MFA admins get **403** on every admin endpoint. |
| **Recommendation** | Keep it in-app as required. Because all admin logic sits in REST endpoints, a web admin (Next.js or Django templates) can be added later without backend changes. |

### 8.4 Location privacy
Foreground permission only; coarse (~100 m) storage; latest value only; never exposed to restaurants (they see first name + pickup code only); a clear in-app explanation before the OS prompt; account deletion wipes location; privacy policy written with Oman's **Personal Data Protection Law (Royal Decree 6/2022)** in mind (consent, purpose limitation, right to deletion). This is not legal advice; a real launch needs review.

### 8.5 Abuse prevention
| Abuse | Control |
|---|---|
| Hoarding meals | ≤ 2 active reservations per user; `max_per_user` per offer (1 for free offers); hold expiry. |
| No-shows | Counted when a hold expires inside the window. **3 no-shows in 30 days → reservation block for 7 days**, with a warning after the 2nd. |
| Fake "rescued" stats | Collection only counts via `POST /pickups/confirm` with the user's code. |
| Fake restaurants | Admin approval; optional CR number; offers hidden until approved. |
| Fake reviews | Ratings only from collected reservations, one per reservation. |
| Spam reports | 5 reports/day per account; duplicates on the same target merged. |
| Code brute force | 10 wrong pickup codes per offer per 10 min, then lockout. |
| Image abuse | Server-side checks: JPEG/PNG/WebP only, ≤ 2 MB, re-encoded with Pillow (strips metadata); admin can remove. |
| API abuse | DRF throttles per scope; nginx `limit_req` on auth; CAPTCHA (hCaptcha/Turnstile) on register if spam appears. |

### 8.6 Secrets
The app holds only the API base URL, the Maps key (restricted to package + SHA-1 / bundle id) and the Firebase client config (public by design). The server keeps `DJANGO_SECRET_KEY`, `MONGODB_URI`, the Firebase service-account JSON and SMTP credentials in `.env` / Docker secrets, **never in git**. Atlas: IP access list = the VPS IP; a least-privilege database user for the app.

---

## 9. Food safety, legal & trust

> For a graduation project these are documented policies and in-app safeguards. A real launch needs review by an Omani lawyer and alignment with municipality and food-safety authority requirements (e.g. the Food Safety and Quality Center and municipality licensing). Do not claim legal protections, such as Good Samaritan food-donation laws, unless they are verified for Oman.

### 9.1 Restaurant obligations (in ToS + per-offer attestation)
- At signup, accept **Restaurant Terms**: the restaurant is solely responsible for the safety, labelling and allergen accuracy of the food; it holds valid licences; it complies with local food-safety regulations.
- **Per offer, a mandatory checkbox:** "This food was prepared today, has been stored at safe temperatures, has not been served to customers, and is safe to eat." `safety_attested` must be true.
- **Required fields:** `prepared_at`, allergens (multi-select, "none" must be chosen explicitly), and category. **Pickup window ≤ 12 h after posting.**
- **Not allowed** (shown in the Add Surplus screen): leftovers from customers' plates, opened or partially served dishes, food past its use-by date, raw/undercooked meat or seafood dishes held without refrigeration, home-made food.

### 9.2 User-facing disclaimers
- On meal details and at reservation: "Surplus meals are provided by the restaurant, which is responsible for food safety. Eat promptly or refrigerate. Check allergens and ask staff if unsure."
- ZAD is described in the **User Terms** and **Privacy Policy** (shown at signup, links in the profile) as an intermediary platform.

### 9.3 Reporting flow
1. A "Report a problem" button on meal details, on a reservation (after collection), on the restaurant page, and (for restaurants) on a reservation (no-show or abusive user).
2. Pick a reason (food safety / misleading / no-show / abusive / inappropriate / other) + details + optional photo.
3. `food_safety` gets **high priority**: push to all admins, shown at the top of the queue.
4. **Auto-safeguard:** 2 independent `food_safety` reports on the same restaurant within 7 days **auto-hides its active offers** until an admin reviews.
5. The admin reviews the context (offer, reservation, history), then dismisses, warns, removes the offer, or suspends the restaurant or user. The resolution note and action are audited, and the reporter is notified of the outcome.

### 9.4 Trust signals
Verified-restaurant badge (approved), rating average (shown only with ≥5 ratings), "meals rescued here" counter, clear pickup instructions, and the pickup code.

---

## 10. Screen-by-screen breakdown

Designs: see §16 (Figma). API paths are under `/api/v1`.

### Shared
| Screen | Data / API | Notes |
|---|---|---|
| Splash (animated) → welcome | stored token → `GET /me` | Routes to auth or the role's home |
| Login | `POST /auth/login` | Links to forgot password / register |
| Register | `POST /auth/register` (with role) | Name, email, password, terms checkbox |
| Account type selection | role sent with register | Shown before the register fields |
| Forgot password | `POST /auth/password/forgot`, reset via app link | |
| Location permission | `geolocator` → `PUT /me/location`, or home-area pin | Explains why before the OS prompt |

### User
| Screen | Data / API | Tier |
|---|---|---|
| Home (map-first) | `GET /restaurants/nearby`, `GET /offers/nearby` | Must |
| Meal details + Reserve sheet | `GET /offers/{id}`, `POST /offers/{id}/reserve` | Must |
| Search & filter | `GET /offers/nearby` with filters | Must (basic), Should (full) |
| Notifications | `GET /notifications`, mark read, deep links | Must |
| Pickups (my reservations) + pickup code | `GET /reservations`, `POST /reservations/{id}/cancel` | Must |
| Profile & collection history | `GET/PATCH /me`, `PUT /me/settings`, `DELETE /me` | Must (prefs + delete: Should) |
| Rate experience | `POST /ratings` | Could |

### Restaurant
| Screen | Data / API | Tier |
|---|---|---|
| Onboarding / pending approval | `POST /restaurants`, `GET /restaurants/me` | Must |
| Restaurant home + Confirm pickup | `GET /restaurants/me/reservations`, `POST /pickups/confirm`, tomorrow's forecast card | Must |
| Add new surplus | `POST /offers` (photo upload multipart) | Must |
| Manage current offers | `PATCH /offers/{id}`, `POST /offers/{id}/cancel` | Must |
| Past meals history | `GET /offers?status=closed,cancelled` | Must |
| Daily log & CSV upload | `PUT /daily-logs/{date}`, `POST /daily-logs/import` | Must (log), Could (CSV) |
| Insights: AI forecast | `GET /forecasts` | Must |
| Insights: impact / statistics | `GET /restaurants/me/stats` | Should |
| Settings & location | `PATCH /restaurants/me` | Must |

### Admin (in-app route group, MFA required)
| Screen | Data / API | Tier |
|---|---|---|
| Overview | `GET /admin/overview` | Must (basic) |
| Restaurant approvals & management | `GET /admin/restaurants`, `POST /admin/restaurants/{id}/status` | Must |
| Users | `GET /admin/users`, `POST /admin/users/{id}/status` | Must |
| Offer moderation | `POST /admin/offers/{id}/remove` | Must |
| Reports queue | `GET /admin/reports`, resolve | Should |
| Data quality & forecasting | `GET /admin/data-quality`, `GET /admin/forecast-runs` | Should |
| Audit log | `GET /admin/audit-log` | Should |

---

## 11. Phased roadmap

Effort is in **hours (h)** for **one developer at ~10 h/week**. Estimates include tests and checking on a physical phone. Weeks = hours ÷ 10. Plan for a **20% buffer** on top.

Tiers: **Must** proves the core loop plus the AI baseline. **Should** makes it trustworthy and measurable. **Could** is nice-to-have. Build Must first, end to end.

> The switch to Django + MongoDB adds about **20 h** to the Must tier compared with the Supabase plan (auth, permissions, endpoints and a server are now hand-built).

### 11.1 Must tier: demoable MVP (~163 h ≈ 16–17 weeks, ~20 with buffer)

**M0: Foundations (~32 h)**
| Task | h |
|---|---|
| Monorepo; Flutter app with `go_router` + Riverpod + lints; running on a physical Android phone | 5 |
| Django + DRF + `django-mongodb-backend`; local Docker Compose (MongoDB single-node replica set); Atlas project; CI (analyze, tests); **week-1 spike: `$geoNear` + transaction** | 6 |
| Theme: `ZadColors` from the Figma tokens, `google_fonts`, 6–8 core widgets (chips, cards, pills, sheets, tab bar), `gen-l10n` + directional-layout rule | 8 |
| Auth: custom user + role, register / login / JWT refresh / logout, email verification, password-reset app link; Flutter auth screens, secure storage, role routing | 13 |

*Done when:* you can sign up as a user or a restaurant and land in the correct (empty) home on a real phone, against the local backend.

**M1: Core loop (~88 h)**
| Task | h |
|---|---|
| Models + indexes (2dsphere, partial unique), `$jsonSchema` validators, serializers, permission classes + **pytest per endpoint × role** | 14 |
| Restaurant onboarding (pin-drop map, cuisine, cold-start questions) + pending approval | 6 |
| Add / manage offers, photo upload (Pillow), safety attestation, allergens, validation | 10 |
| `GET /offers/nearby` + `/restaurants/nearby` (`$geoNear`) + Home map + floating cards + Meal details + directions | 13 |
| Reserve / cancel / confirm-pickup services (transaction + **concurrency test**) + Pickups screens + Confirm pickup sheet | 11 |
| django-q2 schedules: expire holds and offers, count no-shows | 4 |
| Push: Firebase project, `firebase_messaging`, token registration, `PUT /me/location`, `notify_nearby` with anti-spam, notifications inbox, deep links | 12 |
| Admin v1: approval queue, suspend user/restaurant, remove offer, overview counts, **TOTP MFA + `mfa` claim**, audit log | 10 |
| History screens (user collections, restaurant past offers) | 4 |
| Deploy: Docker Compose on the VPS (nginx + TLS, gunicorn, worker, media volume) + Atlas, backups on | 4 |

*Done when (core loop demo):* on two physical phones against the deployed server, a restaurant posts an offer → a nearby user receives a push → the user reserves → the restaurant confirms the pickup code → the user's history and the admin's "meals rescued" counter update.

**M2: Baseline AI forecasting (~43 h)**
| Task | h |
|---|---|
| `daily_logs` + one-tap "log yesterday" form | 4 |
| Synthetic data generator (weekday seasonality, Ramadan/holiday effects, cuisine profiles, noise, missing days) | 5 |
| `zad_forecast`: loader (PyMongo → pandas), features, **M0 + M1**, rolling backtest, MAE/WAPE/bias/coverage, pytest | 14 |
| Cold-start tiers 0–2 + confidence + explanation chips | 5 |
| Nightly `run_forecast` task, `forecasts` / `forecast_runs` writes, `GET /forecasts` | 4 |
| Insights: AI forecast screen (`fl_chart` 7-day bars + range band, confidence, accuracy, log card) | 8 |
| Food-safety disclaimers + terms/privacy screens | 3 |

*Done when:* every restaurant sees a 7-day forecast with a confidence label, and the backtest table (M0 vs M1 on synthetic data) is ready for the report.

### 11.2 Should tier: trust, measurement, pilot (~53 h ≈ +5 weeks)
| Task | h |
|---|---|
| Insights: impact / statistics screen (aggregation pipeline) | 5 |
| Admin data-quality screen + forecast-runs list (§7.8) | 5 |
| Full search & filter UI | 4 |
| Reports flow + admin queue + food-safety auto-hide + audit-log screen | 8 |
| No-show strikes/blocks + pickup-code lockout | 3 |
| Notification preferences (radius, quiet hours, cuisine/free) + `send_reminders` | 5 |
| M2 rate model added to the backtest | 3 |
| Delete account + biometric re-auth for admin actions (`local_auth`) | 4 |
| Maestro E2E smoke flows (3–4) + bug bash on a low-end Android phone | 8 |
| **Mini pilot:** 2–3 real restaurants + 10–15 users for 1–2 weeks | 8 |

### 11.3 Could tier: extras (~24 h)
| Task | h |
|---|---|
| Ratings (prompt after collection, submit, aggregate, display) | 5 |
| CSV import with preview and error report | 7 |
| Admin "Run forecast now" button | 2 |
| Map marker clustering + evening digest notification | 4 |
| Polish: empty states, animations, first-run tour | 6 |

**Grand total ≈ 240 h** (≈ 24 weeks at 10 h/week, ≈ 29 with buffer).

### 11.4 Choosing scope once the deadline is known
| Time until demo | Hours available (10 h/wk − 20% buffer) | What fits |
|---|---|---|
| ~3 months (13 wk) | ~105 h | **Must does not fit (163 h).** Needs ~16 h/week, or the trim list below. |
| ~4 months (17 wk) | ~135 h | **Must does not fit.** Go to ~12 h/week, or apply the trim list. |
| ~5 months (22 wk) | ~175 h | Must tier + a little Should. |
| ~6 months (26 wk) | ~210 h | Must + most of Should, including the mini pilot. **← recommended target** |

**Trim list (tight deadlines):** admin v1 limited to approvals (MFA documented as a known gap), list-only history, a simple forecast card instead of the chart, cold-start tiers 0 + 2 only, Android only.
**If you fall behind, cut in this order:** Could items → M2 model → notification preferences → full search UI (keep basic filters) → admin data-quality screen → E2E automation (keep a manual checklist).
**Never cut:** the core loop, permission tests, atomic reservations, pickup-code verification, food-safety attestation + disclaimers, and the baseline forecast + backtest (the AI contribution).

### 11.5 Working solo at 10 h/week
- Work in 2–3 h blocks; end each with 3 lines in `docs/devlog.md` (done, next, blockers).
- One milestone at a time, with a phone demo at the end of each. Don't start M2 until the M1 loop works on devices.
- Until the in-app admin exists, use the Django admin site or `mongosh` for admin tasks.
- Keep `manage.py seed_demo` and the synthetic generator current, so you can demo at any moment.
- Do the **week-1 spike** (`$geoNear` + reservation transaction on `django-mongodb-backend`) before building on it.
- **Ask your supervisor early** whether a real-restaurant pilot is required or a seeded demo is acceptable.

### Later phases (post-graduation)
| Phase | Scope | Rough effort |
|---|---|---|
| 4: Arabic | Arabic ARB translations, RTL QA (Flutter mirrors layouts automatically), Arabic numerals/dates option, store listings | 50–70 h (if the directional rules were followed) |
| 5: Payments | In-app prepayment via an Omani gateway, refunds, restaurant payouts, receipts | 100–150 h + merchant onboarding |
| 6: Better AI | Global LightGBM with quantiles, weather features, per-category forecasts, "suggested prep quantity" | 80–120 h |
| 7: Web admin | Web admin on the same REST endpoints (Next.js or Django templates) | ~60–80 h |
| 8: Growth | Favourites, multi-branch restaurants, NGO/charity pickup role, POS integrations, guest browsing | per feature |

---

## 12. Risks & mitigations

| Risk | Likelihood / impact | Mitigation |
|---|---|---|
| Cold-start marketplace (no restaurants → no users) | High / High | Recruit 2–3 pilot restaurants early (university area / Muscat). Seed realistic demo data clearly marked as demo. Focus on one neighbourhood. |
| No real historical data for AI | High / Medium | Synthetic data for development. Daily log + CSV for real data. Report synthetic vs real results separately. |
| Restaurants don't log daily | High / Medium | One-tap log card on Insights and Restaurant home, daily reminder push, show how logging improves accuracy. Fall back to posted quantities. |
| **Missing permission check on an endpoint leaks data** | Medium / High | Default-deny DRF settings, explicit role permission per view, querysets scoped to `request.user`, pytest for every endpoint × role, `manage.py check --deploy`, `bandit` in CI. |
| **`django-mongodb-backend` is young (gaps, bugs)** | Medium / Medium | Pin versions; week-1 spike of `$geoNear` + transactions; isolate raw PyMongo in repository functions as a fallback. |
| **MongoDB for transactional data** (reservations, counts, stats) | Medium / Medium | Conditional single-document updates + multi-document transactions on a replica set; partial unique indexes; `$jsonSchema` validators; aggregation pipelines for stats; concurrency test. |
| **Running your own server** (downtime, TLS expiry, backups) | Medium / Medium | Docker Compose with restart policies, certbot auto-renew, Atlas backups, a free uptime monitor, `docker compose` deploy script. |
| Push setup (Firebase, APNs) | Medium / Medium | Set up Firebase in M0 and test on a physical Android phone early. iOS needs a paid Apple account + APNs key, so Android is the primary demo target. |
| Notification spam → users disable push | Medium / High | Caps, cooldowns, quiet hours, preferences (§6.4). Track opt-out rate. |
| No-shows waste restaurant food | Medium / Medium | Hold expiry returns quantity; strike system; reminders. |
| Food-safety incident / liability | Low / Very high | Attestation, prohibited list, pickup window ≤ 12 h, disclaimers, fast report flow with auto-hide. Restaurant responsibility in the ToS. Legal review before a real launch. |
| Admin compromise (in-app admin) | Low / High | TOTP + `mfa` claim, server-side checks, biometric re-auth, audit log, 403 tests. |
| Overselling the last meal (race condition) | Medium / Medium | Conditional `find_one_and_update` inside a transaction (§5.3) + a concurrency test. |
| English-first app for an Arabic-speaking audience | Medium / Medium | ARB strings and directional layout from day one. Arabic is the first post-MVP phase. |
| Scope creep (payments, POS, web admin) | High / High | §1.4 cut list. Changes to scope must update this file. |
| Location permission denied | Medium / Low | Manual home-area pin. Browsing works without GPS. |
| **Solo developer at 10 h/week: schedule slip** (Must is now ~163 h) | High / High | Tiered scope (§11). Must first, end to end. Cut order agreed in advance. Phone demo at every milestone. |
| **Solo: no code review, so security mistakes go unnoticed** | Medium / High | Permission tests are the reviewer. Use `/security-review` and `/code-review` in Claude Code at each milestone. |
| **Long gaps between sessions → lost context** | High / Medium | `docs/devlog.md`, small commits, this CLAUDE.md kept current. |
| **Over-reliance on AI-generated code you don't fully understand** (risky for viva/defence) | Medium / Medium | Be able to explain every permission class, service function and the reservation transaction. Write or study the model/backtest code line by line. |

---

## 13. Testing strategy

| Layer | Tooling | What |
|---|---|---|
| API security | **pytest-django** + DRF `APIClient` against a real MongoDB (Docker / CI service container) | For every endpoint × role: allowed and denied (401/403/404). Owner scoping (a restaurant can't read another's reservations). Admin endpoints reject non-admins and non-MFA tokens. |
| Concurrency | pytest with threads / parallel requests | 10 users reserving the last 3 meals ends with exactly 3 succeeding and `quantity_available = 0`. |
| Scheduled tasks & lifecycle | pytest with `freezegun` (time travel) | Hold expiry returns quantity, offer closes, no-show counting, strike block, notification cap and cooldown. |
| Geo & notifications | pytest with seeded locations | `$geoNear` radius/filters; `notify_nearby` candidate selection (radius, cap, cooldown, quiet hours); FCM mocked. |
| Forecasting | **pytest** | No future-data leakage in features, each model on fixtures, backtest metric maths, cold-start tier selection, idempotent writes. |
| Flutter units & widgets | `flutter_test` | Formatting (baisa → OMR, distances, Asia/Muscat times), form validation, key widgets (offer card, pickup code, chart) incl. golden tests for the main screens. |
| E2E | **Maestro** (or `integration_test`) on an Android emulator + device | Sign up both roles, post offer, reserve, confirm pickup, cancel, admin approve, report. |
| Manual | Device matrix | Push (foreground / background / killed), location permission flows, low-end device performance, small screens. RTL smoke test (force `TextDirection.rtl`) to catch hard-coded left/right before Arabic. |
| Pilot UAT | Real restaurants + users | Task success rate, feedback survey for the report. |

CI runs `flutter analyze`, `flutter test`, `ruff`, and `pytest` (backend + forecast) on every push.

**Solo priority order** (if testing time is short): 1) permission tests + the reservation concurrency test, 2) forecast pytest, 3) a manual device checklist per milestone, 4) Flutter widget tests, 5) Maestro E2E (Should tier).

---

## 14. Success metrics

Targets assume the Should-tier mini pilot. Without a pilot, report the same metrics on the seeded/simulated demo and say so clearly.

| Metric | Definition | Pilot target (1–2 weeks, 2–3 restaurants, 10–15 users) |
|---|---|---|
| **Meals rescued** | Σ quantity of `collected` reservations | ≥ 30 |
| **Rescue rate** | collected ÷ posted quantity | ≥ 60% |
| **Estimated food waste avoided** | meals rescued × 0.4 kg (assumed average meal weight; state this assumption in the report) | ≥ 12 kg |
| **Forecast accuracy** | WAPE and MAE vs the seasonal-naive baseline (synthetic backtest always; real pilot logs if available) | M1 beats M0 by ≥10% WAPE. Synthetic and real reported separately. |
| **Interval coverage** | % of actuals inside P10–P90 | 70–90% |
| **Active restaurants** | posted ≥1 offer in the week | ≥ 2 / week |
| **Active users** | opened the app in the week / reserved in the week | ≥ 10 WAU, ≥ 5 reserving |
| **No-show rate** | expired reservations ÷ all reservations | ≤ 15% |
| **Time to first reservation** | median minutes from offer posting to the first reservation | ≤ 30 min |
| **Notification health** | open rate of `new_offer_nearby`; % of users who disabled notifications | ≥ 15% open, ≤ 10% disabled |
| **Logging compliance** | % of restaurant-days with a daily log | ≥ 70% |
| **Food-safety reports** | count per 100 collected meals | 0 confirmed |

---

## 15. Conventions for development (for humans and Claude Code)

- **Never** put server secrets in the app (`DJANGO_SECRET_KEY`, `MONGODB_URI`, Firebase service account, SMTP).
- Every state change (offer status, reservation status, roles, moderation) goes through a **service function** in `backend/apps/*/services.py`. Serializers keep `status`, `role`, counters and rating fields read-only.
- Every new endpoint ships with an **explicit permission class + allowed/denied tests** in the same PR.
- **All UI strings live in ARB files** (`AppLocalizations.of(context)!.reserve`). Use `EdgeInsetsDirectional`, `AlignmentDirectional` and `PositionedDirectional`, never left/right. Directional icons must flip in RTL.
- **Colours and fonts come from the `ZadColors` theme extension** (mirrors Figma "ZAD tokens") and `google_fonts`. No hex values in widgets.
- Money is **integer baisa**. Format at display time (`1.500 OMR`).
- Datetimes are stored in **UTC** (`USE_TZ = True`) and displayed in `Asia/Muscat`.
- Locations are GeoJSON `{"type": "Point", "coordinates": [lng, lat]}` (**longitude first**). User locations are rounded to 3 decimals.
- Indexes and `$jsonSchema` validators are defined in code (migrations or `manage.py ensure_indexes`), never by hand in Atlas.
- Synthetic data is always `source='synthetic'` and is excluded from real-world metrics.

**Common commands** (once scaffolded)
```
# app (Flutter)
cd app && flutter pub get && flutter run           # emulator reaches the API at http://10.0.2.2:8000
flutter analyze && flutter test
dart run build_runner build --delete-conflicting-outputs   # freezed / json models
flutter gen-l10n
# backend (local: Django + worker + MongoDB replica set)
docker compose -f infra/docker-compose.dev.yml up -d
cd backend && python manage.py migrate && python manage.py ensure_indexes
python manage.py runserver 0.0.0.0:8000
python manage.py qcluster                          # django-q2 worker: schedules + tasks
python manage.py seed_demo                         # demo restaurants, offers, users
pytest
# forecasting
cd forecast && pytest
python -m zad_forecast.run --backtest
python -m zad_forecast.synthetic --restaurants 8 --days 180
# production (VPS)
docker compose -f infra/docker-compose.prod.yml up -d --build
```

---

## 16. Design status (Figma)

**File:** https://www.figma.com/design/se1LdQXHK9uOIXf0XOFIeI/Untitled (Page 1). Frame size is **402×874 (iPhone 16 Pro)**. Set the prototype device to iPhone 16 Pro, or the preview shows black bars.
**Reference material:** `Zesty/` (92 screenshots of the Zesty iOS app, DoorDash, from Mobbin).
**Design direction (decided):** all screens follow **Zesty's patterns** (dark UI, map-first Home, bottom sheets, floating photo cards, white pill primary buttons, gradient-outlined search, grouped settings rows), styled with **ZAD's own tokens, fonts and leaf**. We borrow structure, not Zesty's branding (no rainbow gradients, no bubbly logo font). The old light "timeline" Home was removed.

### 16.1 Design language
| | Decision | Why |
|---|---|---|
| Colours | Frond `#123D2C` (brand), Rib `#3C7A57`, Sap `#CFE6C0`, Paper `#EEF2E9` (green-tinted, not cream), Card `#FBFCF8`, Ink `#15211B`, Muted `#5B6B61`, Line `#D5DDD0`, **Saffron `#E59A2B` = urgency only** | Dark green + leaf brand; saffron is from Omani kahwa |
| Night colours | Night sheet `#141A16`, raised `#1F2722`, hairline (white 12%), scrim (black 55%) | Map-first and dark screens |
| Type | **Bricolage Grotesque** (display), **Readex Pro** (body; covers Arabic for the later Arabic phase), **DM Mono** (times, prices, quantities) | Readex Pro avoids a font swap when Arabic is added |
| Signature | **Leaf + pickup-window bar**: leaf pins carry a meals-left badge, and every offer card shows a pickup-window bar where saffron marks the time left. Saffron always means "closing soon" (under 30 min) | Brand leaf that also carries real information (urgency). Replaces the earlier palm-frond timeline |
| Copy | Plain, user-side wording. Prices `0.800 OMR` (3 decimals). Restaurant names in mocks are fictional | Matches §15 conventions |

All colours are Figma variables in the **"ZAD tokens"** collection (`color/*`, `color/on-frond/*`, `color/stem`, `color/night/*`, `color/danger`). Never hard-code hex values in new screens.
**In Flutter:** mirror the tokens one-to-one in a `ZadColors` `ThemeExtension` (same names, e.g. `zad.frond`, `zad.nightRaised`), load the three fonts with `google_fonts`, and build the Figma components (Chip, Fact chip, Action tile, Form row, Pickup row, Reservation row, Map pin, Offer photo card) as reusable widgets with the same names. The splash animation maps to Flutter's implicit/explicit animations (or Rive/Lottie later); the timings are in §16.3.

### 16.2 Components (in Figma, column at x≈2240)
| Component | Properties |
|---|---|
| **Chip** (Default / Active) | Label |
| **Offer card** (light, timeline) | *Unused since the light Home was removed. Keep for reference or delete* |
| **Map pin** (Default / Selected) | Meals, Label |
| **Offer photo card** (dark, map) | Restaurant, Details, Pickup until, Window start/end, Price, Was price, Meals left, Rating, Tag text, Closing soon |
| **Icons** (`icon/*`, 24 px, stroke bound to `color/card`) | chevron-down, bookmark, share, directions, call, store, flag, shield, clock, minus, plus, ticket, wallet, check, home, user, leaf, x |
| **Pickup row** (Collected / Missed) | Meal, Detail (one line, ellipsis), Status label |
| **Form row** | Icon (swap), Title, Value (one line), Chevron (on/off) |
| **Reservation row** (Waiting / Collected) | Initial, Name, Detail. Waiting has a white **Confirm** pill |

Icons added for the restaurant side: chevron-right, tag, package, banknote, chef-hat, alert, bell, image-plus, scan, sparkles, chart, grid.
| **Action tile** | Icon (instance swap from `icon/*`), Label |
| **Fact chip** | Label |
| **Button** (Primary / Secondary / Ghost) | Label. Primary = white pill + frond label (one per screen); Secondary = raised dark pill; Ghost = text action under a primary |
| **Text field** (Default / Focused / Error) | Label, Value, Helper, Show helper, Show trailing, Leading icon (swap), Trailing icon (swap). Focused = sap outline, Error = danger outline + helper |
| **Choice card** (Default / Selected) | Title, Description, Icon (swap). Selected = sap outline, rib icon tile, filled radio |

Icons added for auth: chevron-left, mail, lock, eye, map-pin, locate.

### 16.3 Screens done
| Screen | Figma node | Notes |
|---|---|---|
| Splash (animated) → welcome | `11:179` | 4 s: glow fades in and drifts, leaf outline draws, fill springs, midrib draws, "zad" staggers in by letter, "زاد" fades, lockup glides up, tagline staggers in by word (2.6 s), buttons (3.0 s). Responsive constraints set. Text stagger start times are set via `props.delay` (`timelineOffset` did not persist) |
| **User Home: map-first** (Zesty-inspired, dark) | `8:48` | Stylised Muscat map, leaf pins, floating photo card + peek card, pickup-window bar, "23 meals left near you tonight" sheet with filters, gradient search, tab bar. Photos are placeholders |
| ~~User Home: light timeline~~ | ~~`5:2`~~ | **Removed** (replaced by the Zesty direction) |
| **Meal details** | `23:135` | Zesty 23/37 pattern: full-bleed photo (optional), collapse/save/share, title, restaurant + walk time, "Pickup now · until 21:40" + saffron tag, pickup-window bar, fact chips (price, meals left, rating, category), description card, action tiles (Directions · Call · Restaurant · Report), allergens & safety card, floating price + **Reserve** pill |
| **Meal details: Reserve sheet** | `24:170` | Zesty 85 pattern: bottom sheet "Reserve this meal?", quantity stepper (up to 3 per person), hold time + pay-at-counter rows, "Reserve 1 meal" pill, "Not now", food-safety line |
| **Meal details: Reserved** | `24:332` | Zesty 37 toast "Reserved. 1 meal is yours. Show code 482 913…", meals left drops to 3, bar becomes "Reserved · 1 meal / Held until 21:40" + **Show pickup code** |

| **Pickups** (My reservations) | `26:256` | Zesty 53/43 pattern: "Pickups" title + "7 meals rescued · 9.600 OMR saved", underline tabs (Upcoming · History), active reservation card (meal, restaurant, "1 meal · 0.800 OMR at the counter", **held until 21:40 / 28 min left** + saffron hold bar, **Show pickup code** pill + Directions), Recent rows (Collected / Missed) |
| **Pickups: Pickup code sheet** | `27:319` | Zesty 85 sheet: "Show this at the counter", light code panel with QR (decorative stand-in) + **482 913** in DM Mono, hold row + bar, Directions / Call restaurant tiles, red **Cancel reservation** |

| **Restaurant home** | `29:400` | Zesty 69/45 pattern: "Tonight at Khubz & Co. Bakery" + Verified, 3 stat tiles (6 posted · 3 reserved · 1 collected), **Live now** offer card (2 of 6 left, saffron window bar, Edit quantity / End early), "Waiting for pickup · 2" reservation rows with **Confirm**, forecast teaser card ("Tomorrow (Fri): ~12 surplus meals · range 8–16"), floating **Confirm pickup** pill, restaurant tab bar **Today · Offers · (+) · Insights · Profile** |
| **Add new surplus** | `30:458` | Zesty 57–62 composer, shown at full scroll length (402×984): close + "New surplus", dashed photo tile (optional), meal name + note, form rows (Category, Quantity, Price, Pickup window, Prepared at, Allergens), **required food-safety checkbox** + "What can't be posted?", "People within 3 km get one alert", pinned **Post surplus** pill |
| **Restaurant home: Confirm pickup** | `31:535` | Zesty 85 sheet + verify-code boxes: 6 digit boxes (482913), "Code matches · Aisha / 1 × Zaatar manakish box · collect 0.800 OMR", **Confirm pickup**, "Scan QR instead", lockout note |

| **Insights: AI forecast** | `32:601` | Restaurant Insights tab, Forecast · Impact tabs, shown at full scroll length (402×1322). **Tomorrow card:** "~12 surplus meals expected · likely between 8 and 16" + confidence pill (dots + label, not colour alone). **7-day chart:** single series, one bar per day, P10–P90 band behind each bar, tomorrow in sap / other days in rib, value label on every bar, weekend (Fri–Sat) shaded, faint grid 0–20. **Why this forecast** chips, **suggestion** card ("prepare ~8 fewer portions… or plan an offer around 21:00") + "Post surplus now" (no prefill) + "A forecast never posts meals for you", accuracy line ("off by about 3 meals a day"), **Log yesterday** card. Matches §7.7 |

| **Auth: Account type** | `36:643` | Zesty 8/12: rib glow, leaf mark, "How will you use ZAD?", "Step 1 of 2", two **Choice cards** (I want to rescue meals · I run a restaurant), Continue pill + "Already have an account? Log in" |
| **Auth: Register** | `36:706` | "Create your account", "Signing up to rescue meals · Change" (back to account type), Text fields (Full name, Email focused + verify helper, Password + eye + rule helper), Terms/Privacy checkbox, Create account pill |
| **Auth: Location permission** | `36:786` | Zesty 12/90 pre-prompt (shown before the OS dialog): radius-ring illustration with "you" dot, 3 leaf map pins and a "3 km" label, "See meals near you", privacy card (only while using the app · rounded to ~100 m, never shown to restaurants · alerts only within 3 km), **Turn on location** + "Set my area instead" |
| **Auth: Login** | `36:865` | Leaf mark, "Welcome back", Email + Password (eye), end-aligned "Forgot password?", Log in pill, "New to ZAD? Create an account" |
| **Auth: Forgot password** | `36:929` | "Reset your password", email field (focused), spam-folder note, **Send reset link** + "Back to log in". The link opens the app (§8.1) |

**Chart rules for the app build** (from the dataviz check): rib bars are only 3:1 against the card, so keep the value labels; tapping a bar shows a tooltip (day, expected, range); offer a table view ("View as list") for accessibility; never prefill Add surplus from the forecast.

Layout on Page 1. **Row 1 (discover → reserve):** Splash (x −760) · Home (300) · Meal details (760) · Reserve sheet (1220) · Reserved (1680). **Row 2 (y ≈ 882, pickups):** Pickups (300) · Pickup code (760). **Row 3 (y ≈ 1956, restaurant):** Restaurant home (300) · Add new surplus (760) · Confirm pickup (1220) · Insights: AI forecast (1680). **Row 4 (y ≈ 3420, auth):** Account type (300) · Register (760) · Location permission (1220) · Login (1680) · Forgot password (2140). **Components column:** x 2240 (Button, Text field and Choice card sets at y ≈ 1260–2120).
**Auth flow:** Splash "Get started" → Account type → Register → Location permission → role home. Splash "I already have an account" → Login (→ Forgot password).
The tab bar is now **Home · Pickups · Profile** on all screens (the Map tab was removed from Home).
New token: `color/danger` `#F06A5E` (destructive actions only).

**Design decisions:**
- Home **is** the map. The separate "Map" tab is now redundant. When the tab bar is next touched, change it to **Home · Pickups · Profile** (Zesty uses 3 items).
- A list view of offers still exists inside the Home sheet (drag up), sorted by pickup end, so urgency is still easy to scan.
- Restaurant photos stay **optional** (less work at closing time). Without a photo, the card shows a cuisine placeholder.

### 16.4 Screens remaining (~27), with the Zesty screen to borrow from
Numbers refer to `Zesty/Zesty ios Feb 2026 <n>.png`.

| ZAD screen | Zesty reference | What to borrow |
|---|---|---|
| Login · Register · Forgot password | 75–77, 86–89 | Dark native forms (not Zesty's light web sheet): label above a dark rounded input, helper text, white pill primary button |
| Account type selection | 8, 12 | Dark full screen, centred illustration/leaf, big heading, two large choice cards, white pill "Continue" |
| **Location permission** (new) | 12, 90 | "Turn on location to see meals near you", illustration, "Go to settings" pill + "Set my area instead" |
| **Meal details + Reserve** | 23, 37, 24–27 | Full-bleed photo carousel, title + meta + "Pickup now · until 21:40", fact chips, description card, action row (Directions · Call · Share · Report), allergen + safety card, sticky white **Reserve** pill |
| Reserve confirmation | 37 (toast), 85 (sheet) | Bottom sheet "Reserve 1 meal?", quantity stepper, pay-at-pickup note, then a toast "Reserved. Show your code at pickup" |
| **My reservations (Pickups)** | 53 | List rows with thumbnail, name, pickup time and status; tapping one opens a **pickup-code sheet** (6 digits + QR + hold countdown) |
| Notifications | 71–73 | Simple rows with avatar/leaf icon and a trailing action; empty state "You're all caught up" (71) |
| Search & filter | 54, 13 | Search field + results rows; prompt-style chips ("Free tonight", "Bakery under 1 OMR") |
| Profile & history | 69–70, 74, 78 | Profile card with stats (meals rescued · OMR saved · pickups), grid/list tabs, settings button |
| Settings · notification prefs · delete account | 74, 79, 82, 84–85 | Grouped dark rows with chevrons; checkbox list for preferences; radio rows; destructive confirm sheet |
| Rate experience (Could) | 57–67 | Composer with three big reaction buttons (**Not for me · Kinda mid · Loved this!** → map to 1–5 stars), optional note, white "Post" pill |
| Restaurant: Add new surplus | 57–62 | Photo tiles (+), rows with chevrons (Category, Quantity, Price, Pickup window, Allergens), safety checkbox, white "Post surplus" pill |
| Restaurant home + Confirm pickup | 45, 85 | Today card, live reservations list, "Confirm pickup" sheet with a 6-digit code input |
| Restaurant: Manage offers · Past meals | 53, 43 | List rows + 2-column photo grid for history |
| Restaurant: AI forecasts · Statistics | 45 (ranked list) | Dark cards; 7-day bar chart with range band; ranked/stat rows |
| Restaurant onboarding · Settings & location | 75, 74 + map | Form rows + pin-drop map |
| Admin screens | 45, 48, 53, 74 | Segmented tabs (Pending · Approved · Suspended), ranked/queue rows, grouped settings rows |

**By role:**
- **Shared (5):** ~~Login · Register · Forgot password · Account type selection · Location permission~~ (all done). Still open: a "Check your email" state after Send reset link / Create account, and the "Set my area" pin-drop screen
- **User (4):** ~~Meal details + Reserve~~ (done) · ~~My reservations + pickup code~~ (done) · Search & filter (full) · Notifications · Profile & collection history · Rate experience (Could)
- **Restaurant (6):** Onboarding + pending approval · ~~Restaurant home + Confirm pickup~~ (done) · ~~Add new surplus~~ (done) · Manage current offers · Daily log · ~~AI forecasts~~ (done) · Waste-reduction statistics · Past meals history · Settings & location
- **Admin, inside the app (7):** Overview · Restaurant approvals · Users · Offer moderation · Reports queue · Data quality · Audit log
- **Not yet:** prototype links between screens; real food photos (Figma AI image generation needs approval because it uses AI credits)

### 16.5 Suggested design order
1. ~~Meal details + Reserve~~ (done) → 2. ~~My reservations (pickup code)~~ (done) → 3. ~~Add new surplus~~ (done) → 4. ~~Restaurant home + Confirm pickup~~ (done). **The core-loop demo is fully designed.**
5. ~~AI forecasts~~ (done) → 6. ~~Auth screens (Login, Register, Account type, Location permission, Forgot password)~~ (done) → remaining User/Restaurant screens → Admin screens → clickable prototype.
