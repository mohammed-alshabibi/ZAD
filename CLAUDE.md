# ZAD (زاد) — Project Plan (simplified)

> Surplus-meal app: restaurants post leftover meals, nearby users reserve and pick them up, and an AI model
> forecasts each restaurant's surplus for the next 7 days. Brand: dark green, leaf motif. Market: Muscat, Oman.
> **University graduation project, one developer, ~10 h/week.** Rule #1: pick the simplest thing that works for a demo.
> This file is the single source of truth. The earlier, fuller plan is archived in `docs/plan-v1-detailed.md`
> (useful for the report's "future work" chapter).

---

## 1. Scope

### 1.1 Key facts
| | Decision |
|---|---|
| Context | University project. Goal = a working demo on Android phones + a report. Not a real launch. |
| Team & time | Solo, ~10 h/week. Deadline not fixed yet (§10). |
| Stack | **Flutter · Django + DRF · MongoDB · Python (AI)** (owner's choice, 2026-10-18). Backend + database run in **Docker Compose** (owner's choice, 2026-10-19). |
| Roles | `user`, `restaurant`, `admin`, all in **one app**. |
| Payment | None in the app. The user **reserves**, then **pays at the counter**. |
| Pickup | Pickup only, no delivery. One location per restaurant. |
| Language | English only, but strings live in ARB files and layouts use start/end, so Arabic can be added later. |
| Money / time | Integer **baisa** (1 OMR = 1000). Store UTC, show `Asia/Muscat`. Weekend = Fri–Sat. |
| Demo device | Android (physical phones). iOS not required. |

### 1.2 What's in (core)
1. Sign up / log in as a user or restaurant. Admin approves restaurants.
2. Restaurant posts surplus (meal, category, allergens, quantity, price or free, pickup window, food-safety checkbox).
3. User sees nearby offers on a map, reserves, gets a **6-digit pickup code**.
4. Restaurant confirms the code at pickup → reservation `collected` → "meals rescued" counter.
5. Push notification to users within **3 km** when a restaurant posts (max 3 per day).
6. Restaurant logs daily numbers; the app shows a **7-day surplus forecast** (baseline model + backtest for the report).
7. Simple in-app admin: approve/reject restaurants, remove an offer, see overview counts.

### 1.3 What's out (future work in the report)
In-app payments · POS/CSV import · ratings · reports/moderation queue · email verification · admin MFA and audit log · no-show strikes · quiet hours and notification preferences · ML models beyond the baseline (LightGBM) · background task queue · own server/VPS, nginx, production Docker images (gunicorn etc.) · Arabic translation · web admin · multi-branch restaurants · delivery.

---

## 2. Tech stack

| Layer | Choice | Kept simple by… |
|---|---|---|
| App | Flutter + Dart, `go_router`, Riverpod, `dio` | One app with three route groups (user / restaurant / admin). Plain Dart model classes (`fromJson`), no code generation. |
| UI | Material 3 + `ZadColors` `ThemeExtension` (mirrors Figma tokens), `google_fonts`, `fl_chart` | Reuse the Figma components as widgets (§14). |
| Maps & location | **Mapbox** `mapbox_maps_flutter` (style `dark-v11`) + Mapbox Geocoding v6 for "address from the pin" (owner's choice, 2026-10-21), `geolocator`, `url_launcher` (directions) | Foreground location only. Directions open Google Maps. Free Mapbox tier without a card: 100 monthly active phones, enough for the demo. Public token in `app/config/mapbox.json` (git-ignored, copy `mapbox.example.json`), passed with `--dart-define-from-file`. |
| Push | Firebase Cloud Messaging (`firebase_messaging` + `firebase-admin` on the server) | One FCM token per user, stored on the user. |
| Backend | Django 5 + DRF, `djangorestframework-simplejwt` | JWT without blacklist (no extra tables). Logout = delete tokens on the phone. |
| Database | **MongoDB 7** via `django-mongodb-backend` 5.2.4 (Django 5.2); raw `aggregate()` for `$geoNear` | Local `mongo:7.0` container by default; switch to **Atlas M0** by changing `MONGODB_URI` in `backend/.env`. |
| Dev infra | **Docker Compose** (`docker-compose.yml`, project `zad`): `mongo` (port 27017 on the laptop only, data in the `mongo-data` volume) + `backend` (Python 3.12, `runserver` on 0.0.0.0:8000, `./backend` mounted for live reload) | The Flutter app is not containerised. `GET /api/v1/health` checks API + database. |
| Background work | **None.** Holds expire lazily on read; the forecast is a management command | No worker, no Redis, no scheduler to run. |
| AI | Python package `zad_forecast` (pandas, numpy) | Two simple models, no ML library needed. |
| Media | Django `MEDIA_ROOT` folder, Pillow resize | Photos are optional. |
| Hosting (demo) | Laptop runs `docker compose up`; phones on the same Wi-Fi use the laptop's IP on port 8000 | Optional: Render free tier for a public URL. |
| Tests | `pytest-django`, `pytest`, `flutter_test` | Focus on permissions, reservations, forecast maths. |

Week-1 spike: confirm `django-mongodb-backend` works for the custom user model, a `$geoNear` query, and an atomic `$inc`. If something doesn't work through the ORM, use PyMongo directly in that service function.

---

## 3. Architecture

```
Flutter app (Android) ──HTTPS/JSON + JWT──► Django + DRF (laptop or Render)
   ▲                                           │  services.py = all business rules
   │ push                                      │  management commands: run_forecast, seed_demo
   └──────────── Firebase Cloud Messaging ◄────┤
                                               ▼
                              MongoDB (Docker container, or Atlas M0)
```

**Main flows**
1. **Post:** `POST /offers` → validate → save → `notify_nearby()` runs in the same request (fine at demo scale).
2. **Browse:** app sends its location → `GET /offers/nearby` → `$geoNear` → map pins (grouped by restaurant in the app) + cards.
3. **Reserve:** `POST /offers/{id}/reserve` → atomic decrement + reservation with pickup code (§5.2).
4. **Collect:** restaurant enters the code → `POST /pickups/confirm` → `collected`.
5. **Expire (lazy):** before reading offers or reservations, `expire_stale()` marks old holds `expired` (quantity returned) and old offers `closed`.
6. **Forecast:** `python manage.py run_forecast` reads `daily_logs`, writes `forecasts`. Run it by hand before a demo (or with Windows Task Scheduler).

**Repo layout**
```
zad/
  app/        Flutter (lib/core: theme, l10n, api, router · lib/features: auth, user, restaurant, admin)
  backend/    Django project + apps: accounts, restaurants, offers, reservations, notifications, forecasting
  forecast/   zad_forecast package (models, backtest, synthetic) + tests
  docs/       report material, devlog, plan-v1-detailed.md
  CLAUDE.md
```

---

## 4. Data model (7 collections)

All documents have `_id`, `created_at`, `updated_at`. Locations are GeoJSON `{"type":"Point","coordinates":[lng,lat]}` with a **2dsphere index**.

| Collection | Fields | Notes |
|---|---|---|
| `users` | email (unique), password, `role` (user/restaurant/admin), full_name, phone?, `status` (active/suspended), `location?`, `location_at?`, `notify_enabled` (default true), `fcm_token?` | Custom Django user. `role` chosen at signup (user/restaurant only); admins via `createsuperuser`. Location rounded to 3 decimals (~100 m). |
| `restaurants` | owner_id (unique), name, cuisine (enum), description, phone, address_text, location, `status` (pending/approved/rejected/suspended), typical_daily_meals?, typical_surplus_pct? | The two "typical" answers feed the forecast cold start. |
| `offers` | restaurant_id, title, description, category (enum), allergens [], photo?, original_price_baisa?, price_baisa (0 = free), quantity_total, quantity_available, prepared_at, pickup_start, pickup_end, `status` (active/sold_out/closed/cancelled/removed), safety_attested, + copied restaurant_name, cuisine, location | Copying the restaurant fields lets `$geoNear` run on `offers` alone. Validation: quantity 1–100, pickup_end > pickup_start, pickup_end ≤ now + 12 h. |
| `reservations` | offer_id, user_id, quantity, pickup_code (6 digits), `status` (reserved/collected/cancelled/expired), hold_expires_at, collected_at? | `hold_expires_at = min(max(now, pickup_start) + 30 min, pickup_end)`. |
| `notifications` | user_id, type, offer_id?, title, body, read_at? | Inbox + the 3-per-day cap. |
| `daily_logs` | restaurant_id, date, meals_prepared, meals_surplus, `source` (manual/synthetic) | Unique (restaurant_id, date). surplus ≤ prepared. |
| `forecasts` | restaurant_id, target_date, predicted, low, high, confidence (low/medium/high), model, explanations [] | Future days are replaced on each run; past days are kept (what the forecast said at the time) so the app can compare them with the logs. `explanations` are codes + numbers (`{"code":"weekday_higher","weekday":5,"pct":40}`, `days_logged`, `weekday_average`, `ramadan`, `holiday`, `cold_start`); the app words them. |

Enums (cuisines, categories, allergens, Oman holidays/Ramadan dates) live in Python code, not in collections.

**Reservation lifecycle:** `reserved` → `collected` (code confirmed) / `cancelled` (user or restaurant; quantity returned) / `expired` (hold passed; quantity returned).
**Offer lifecycle:** `active` ⇄ `sold_out` (quantity 0) → `closed` (after pickup_end) · `cancelled` (restaurant) · `removed` (admin). Only `active`/`sold_out` are visible to users. Status changes only happen in service functions; `status` is read-only in serializers.

---

## 5. API (`/api/v1`, JSON, JWT)

### 5.1 Endpoints
| Who | Endpoints |
|---|---|
| Anyone | `POST /auth/register` (email, password, name, role) · `POST /auth/login` · `POST /auth/refresh` |
| Signed in | `GET/PATCH /me` · `PUT /me/location` · `PUT /me/push-token` · `GET /notifications` · `POST /notifications/{id}/read` |
| User | `GET /offers/nearby?lat&lng&radius_km=5&category&free` · `GET /offers/{id}` · `POST /offers/{id}/reserve` · `GET /reservations` · `POST /reservations/{id}/cancel` |
| Restaurant | `POST /restaurants` · `GET/PATCH /restaurants/me` · `GET /restaurants/me/offers` · `POST /offers` · `PATCH /offers/{id}` · `POST /offers/{id}/cancel` · `GET /restaurants/me/reservations` · `POST /pickups/check` (who a code belongs to, shown before handing food over; counts toward the wrong-code lockout) · `POST /pickups/confirm` · `GET /daily-logs` · `PUT /daily-logs/{date}` · `GET /forecasts` (last 14 days + next 7) |
| Admin | `GET /admin/overview` · `GET /admin/restaurants?status=` · `POST /admin/restaurants/{id}/status` · `GET /admin/offers` · `POST /admin/offers/{id}/remove` |

**Security rules (keep these, they are cheap):** `IsAuthenticated` by default; one role permission per view (`IsUserRole`, `IsRestaurantRole`, `IsApprovedRestaurant`, `IsAdminRole`); querysets always filtered by `request.user`; `role`, `status` and counters are read-only in serializers. Restaurants see only the user's first name and the code status, never their phone or location.

### 5.2 Reserving without overselling
```python
offer = offers.find_one_and_update(
    {"_id": offer_id, "status": "active", "quantity_available": {"$gte": qty}},
    {"$inc": {"quantity_available": -qty}}, return_document=ReturnDocument.AFTER)
if offer is None:
    raise SoldOut()
try:
    reservations.insert_one({... "status": "reserved", "pickup_code": code, "hold_expires_at": hold_until})
except Exception:
    offers.update_one({"_id": offer_id}, {"$inc": {"quantity_available": qty}})   # undo
    raise
if offer["quantity_available"] == 0:
    offers.update_one({"_id": offer_id, "quantity_available": 0}, {"$set": {"status": "sold_out"}})
```
A single-document conditional `$inc` is atomic in MongoDB, so no transaction (and no replica-set setup) is needed. Checked first: quantity ≤ 3 per user, and the user has no other active reservation on this offer.

---

## 6. Location & notifications

- **Location:** ask for "while using the app" permission after the explanation screen (Figma "Location permission"). Send it on app open (`PUT /me/location`), rounded to 3 decimals. If denied, the user drops a pin for their area instead. Never shown to restaurants.
- **Nearby query:** `$geoNear` on `offers` (must be the first pipeline stage), filter `status ∈ {active, sold_out}` and `pickup_end > now`, return `distance_m`, limit 50.
- **`notify_nearby(offer)`** (called right after posting): users with `notify_enabled`, an FCM token and a location within **3 km**, not the owner, and fewer than **3** "new offer" notifications today. Send with `firebase-admin`, save a `notifications` row, clear the token if FCM says it's invalid. Message: "🍃 {Restaurant} posted surplus 1.2 km away: {title}, {price|Free}, pickup until {time}". Tapping it opens Meal details.

---

## 7. AI forecasting

### 7.1 Goal
Predict **how many meals a restaurant will have left over each day for the next 7 days**, with a range. It is advice for the restaurant only. **A forecast never creates an offer.**

### 7.2 Data
- `daily_logs.meals_surplus` is the label (the restaurant logs yesterday's numbers with a one-tap form).
- **Synthetic data** (`python -m zad_forecast.synthetic`): 6–8 fake restaurants × 180 days with weekday patterns, Fri/Sat peaks, Ramadan and Eid effects, noise and some missing days. Always `source='synthetic'`.
- Calendar flags (weekend, public holiday, Ramadan) come from a small Python table of Oman dates for 2024–2027.

### 7.3 Models
| | Model | Use |
|---|---|---|
| M0 | **Seasonal naive**: same weekday last week | The baseline. |
| M1 | **Seasonal average**: mean of the last 4 same weekdays × a Ramadan/holiday multiplier learned from the data | The model shown in the app. |

**Range:** the 10th–90th percentile of M1's past errors for that restaurant, added to the prediction.
**Cold start:** with fewer than 14 days of logs, use the onboarding answers (`typical_daily_meals × typical_surplus_pct`, adjusted by a generic weekday pattern) and label it "Rough estimate" (confidence low). With 14+ days, use M1 (confidence medium, or high if recent MAE < 20% of the average surplus).

### 7.4 Evaluation (for the report)
Rolling backtest on the synthetic data: train up to day t, predict t+1…t+7, slide forward. Report **MAE** (meals/day), **WAPE** (Σ|error| / Σactual) and **interval coverage** (share of actuals inside the range, target ≈ 80%) for M0 vs M1. Synthetic results are labelled as synthetic. `python -m zad_forecast.run --backtest` writes the results table to `docs/`.

### 7.5 Running it
`python manage.py run_forecast` → for each approved restaurant, pick cold-start or M1, predict 7 days, replace its future `forecasts` (past days stay for the accuracy line). The app reads `GET /forecasts`.

### 7.6 How the restaurant sees it
Matches the Figma Insights screen: tomorrow card ("~12 surplus meals, likely 8–16") with a confidence label; 7-day bar chart with range bands and weekend shading; 2–3 explanation chips ("Fridays are usually higher", "Ramadan pattern applied", "Based on 23 days of your data"); a suggestion ("Consider preparing ~8 fewer portions"); "Post surplus now" opens Add Surplus **without** pre-filling the quantity; "Log yesterday" card.

---

## 8. Auth, roles & food safety

### 8.1 Auth & roles
- Email + password (Django's hasher), JWT access 1 day + refresh 30 days, stored with `flutter_secure_storage`.
- The account type is chosen at signup. Restaurants fill in onboarding and wait as `pending` until an admin approves them.
- After login the app calls `GET /me` and routes by `role`. **Hiding screens is UX only; the API permissions are the real security.**
- Admin accounts are created with `python manage.py createsuperuser` (role set to admin). The Django admin site is a dev tool.
- Forgot password (Figma screen exists) is an **extra**: Django's built-in reset tokens + console email backend for the demo.

### 8.2 Food safety (documented policy, not legal advice)
- Per offer: a **required** checkbox "This food was prepared today, stored at safe temperatures, has not been served to customers, and is safe to eat", required allergens (or "none"), `prepared_at`, and a pickup window ending within 12 h.
- "What can't be posted?" list: plate leftovers, opened/partly served dishes, food past its use-by date, home-made food.
- Disclaimer on Meal details and the reserve sheet: the restaurant is responsible for food safety; check allergens; eat promptly or refrigerate.
- Simple Terms + Privacy screens (mention Oman's Personal Data Protection Law, Royal Decree 6/2022). A real launch would need legal review.

---

## 9. Screens

**Core** = needed for the demo. **Extra** = only if time allows. Figma status is in §14.

| Role | Core | Extra |
|---|---|---|
| Shared | Splash, Account type, Register, Login, Location permission (+ "set my area" pin) | Forgot password flow |
| User | Home map, Meal details + Reserve sheet, Pickups + pickup code, Notifications, Profile (name, history, notifications on/off, log out, terms) | Search & filter screen, rating |
| Restaurant | Onboarding + pending, Restaurant home + Confirm pickup, Add surplus, Manage offers (edit quantity / end early), Past offers list, Daily log form, Insights: AI forecast, Settings | Insights: impact stats |
| Admin | Overview (counts + meals rescued), Restaurant approvals (pending / approved / suspended), Offers list with Remove | Users list with suspend |

Figma screens planned for features that are now out of scope (ratings, reports queue, data quality, audit log) are optional.

---

## 10. Roadmap (~120 h core)

Hours for one person, including testing on a phone. Weeks at 10 h/week. Add ~20% buffer.

**Build order (decided 2026-10-19): three phases, UI → backend → AI.** Figma is frozen (§14.4); implementation starts with the app.

| Phase | Tasks | h |
|---|---|---|
| **P1 UI (Flutter, fake data)** · core screens done 2026-10-27 (Forgot password, Terms, Privacy still placeholders) | Project setup: router (user / restaurant / admin route groups), Riverpod, `ZadColors` + fonts + l10n (6) · core widgets from §14.2 (6) · **fake data layer**: one repository interface per feature + `Fake…Repository` returning demo data in the exact §5 JSON shapes, wired through Riverpod providers (3) · auth + onboarding screens + role routing (6) · user screens: Home map, Meal details, Reserve, Pickups + code, Notifications, Profile, Set my area (14) · restaurant screens: home + Confirm pickup, Add surplus, Manage/Past offers, Daily log, Insights chart, Settings (13) · admin screens: Overview, Approvals, Offers (4) · terms/disclaimers + formatting unit tests + phone check (4) | 56 |
| **P2 Backend + database** | ~~Docker Compose + Django + MongoDB skeleton~~ (done 2026-10-19) · DRF + week-1 spike (4) · models, serializers, permission classes + allowed/denied tests (8) · auth/JWT + `/me` (3) · restaurants + admin approval (4) · offers + `$geoNear` nearby (5) · reserve / cancel / confirm pickup + lazy expiry + concurrency test (7) · daily logs + admin overview (2) · Firebase push + `notify_nearby` + inbox (6) · **swap the app to `Api…Repository`** (dio + JWT storage) and fix the screens on a phone (6) | 45 |
| **P3 AI forecast** | synthetic generator (4) · `zad_forecast` M0 + M1 + backtest + tests (9) · cold start + confidence + chips (2) · `run_forecast` + `GET /forecasts`, Insights reads real data (2) | 17 |
| **Demo & report** | `seed_demo` command, two-phone run-through, bug fixes, demo video, report screenshots and backtest table | 10 |
| | **Total core** | **128 h ≈ 13 weeks (≈ 16 with buffer)** |

**Rules that keep the phases joinable:** in P1, screens never build JSON or call `dio` themselves; they only talk to repository providers, so P2 swaps the fake repositories for real ones without touching screens. Fake data uses the same field names, baisa integers and UTC timestamps as §4/§5. Do the Firebase push setup on a physical phone early in P2 (§12).

*Demo script (end of P2):* restaurant posts → nearby user gets a push → user reserves → restaurant confirms the code → "meals rescued" goes up in the admin overview. *End of P3:* the restaurant sees its 7-day forecast, and the report has the M0 vs M1 table.

**Extras (~30 h, pick by value):** forgot password (3) · notification radius setting (2) · search & filter screen (4) · impact stats (4) · report-a-problem button + admin list (4) · ratings (5) · deploy to Render (4) · Arabic translation (≈10).

**If time is short, cut in this order:** offer photos → admin overview counts (keep approvals) → chart (show the tomorrow card + a list) → push (keep the in-app inbox).
**Never cut:** the core loop, the pickup code, the no-oversell reservation, role permissions, the food-safety checkbox, and the forecast + backtest (the AI part of the project).

**Working rhythm:** 2–3 h sessions, 3 lines in `docs/devlog.md` after each (done / next / blockers). Phone demo at the end of each milestone. Ask the supervisor early whether a seeded demo is enough or real restaurants are expected.

---

## 11. Testing

| What | How |
|---|---|
| Permissions | pytest-django: for each endpoint group, one allowed and one denied case (wrong role, other owner → 403/404). |
| No overselling | 10 threads reserving the last 3 meals → exactly 3 succeed, `quantity_available = 0`. |
| Lifecycle | `freezegun`: expired hold returns quantity; offer closes after pickup_end. |
| Notifications | Seeded users: 3 km radius, 3-per-day cap, owner excluded (FCM mocked). |
| Forecast | Models on small fixtures, metric maths, no future data used in a prediction. |
| Flutter | Unit tests for formatting (baisa → `0.800 OMR`, distances, Muscat times) and form validation. |
| Manual | A checklist per milestone on a real phone: push (app open/closed), location allowed/denied, small screen. |

---

## 12. Risks & what to measure

| Risk | Mitigation |
|---|---|
| Running out of time | Core first, end to end; extras only after M2; cut order agreed above. |
| `django-mongodb-backend` gaps | Week-1 spike; fall back to PyMongo inside service functions. |
| No real data for the AI | Synthetic data for development and the backtest; any real logs reported separately. |
| Push setup problems | Set up Firebase early in M1 on a physical Android phone. |
| Phones can't reach the laptop | Same Wi-Fi + laptop IP + firewall rule; fallback: Render free tier. |
| Not being able to explain the code in the viva | Write or study the reservation function, permission classes and forecast models line by line. |

**Report metrics:** meals rescued and rescue rate in the demo/user test · forecast MAE and WAPE, M1 vs M0 (synthetic) · interval coverage · a small usability test with 5–8 people (task success + SUS questionnaire). The food-waste estimate (meals × 0.4 kg) is an assumption and must be stated as one.

---

## 13. Conventions & commands

- Business rules live in `backend/apps/*/services.py`. `status`, `role` and counters are read-only in serializers.
- Every new endpoint gets an explicit permission class + an allowed/denied test.
- UI strings in ARB files (`AppLocalizations.of(context)!.reserve`); `EdgeInsetsDirectional` / `AlignmentDirectional`, never left/right.
- Colours and fonts only from `ZadColors` + `google_fonts`. No hex values in widgets.
- Money = integer baisa, formatted as `1.500 OMR`. Datetimes UTC in the DB, `Asia/Muscat` on screen.
- GeoJSON is **longitude first**. User locations rounded to 3 decimals.
- Indexes are created in code (`python manage.py ensure_indexes`).
- Synthetic data is always `source='synthetic'` and never reported as real accuracy.
- Secrets (`DJANGO_SECRET_KEY`, `MONGODB_URI`, Firebase service account) live in `backend/.env`, never in git or in the app. The Mapbox public token lives in `app/config/mapbox.json` (git-ignored).
- **Git:** repo https://github.com/mohammed-alshabibi/ZAD. `main` holds working code. Every new feature or bug fix gets its own branch from `main` (`feature/<short-name>` or `fix/<short-name>`), merged back when it works. `Zesty/` (Mobbin screenshots) stays out of git.

```
# app
cd app && flutter pub get && flutter run --dart-define-from-file=config/mapbox.json   # API base URL = http://<laptop-ip>:8000
flutter analyze && flutter test
flutter gen-l10n
# backend (Docker Compose, from the repo root; first time: copy backend/.env.example to backend/.env)
docker compose up --build -d                      # API on http://<laptop-ip>:8000, health: /api/v1/health
docker compose logs -f backend
docker compose exec backend python manage.py migrate
docker compose exec backend python manage.py ensure_indexes
docker compose exec backend python manage.py seed_demo      # demo restaurants, offers, users
docker compose exec backend python manage.py run_forecast
docker compose exec backend pytest
docker compose down                               # stop (add -v to wipe the local database)
# forecasting
cd forecast && pytest
python -m zad_forecast.synthetic --restaurants 8 --days 180
python -m zad_forecast.run --backtest
```

---

## 14. Design status (Figma)

**File:** https://www.figma.com/design/se1LdQXHK9uOIXf0XOFIeI/ZAD-Project (Page 1). Link to a screen = `…/ZAD-Project?node-id=<node with ":" → "-">` (e.g. Splash `11:179` → `?node-id=11-179`); the node IDs are in §14.3. Frame size is **402×874 (iPhone 16 Pro)**. Set the prototype device to iPhone 16 Pro, or the preview shows black bars.
**Reference material:** `Zesty/` (92 screenshots of the Zesty iOS app, DoorDash, from Mobbin).
**Design direction (decided):** all screens follow **Zesty's patterns** (dark UI, map-first Home, bottom sheets, floating photo cards, white pill primary buttons, gradient-outlined search, grouped settings rows), styled with **ZAD's own tokens, fonts and leaf**. We borrow structure, not Zesty's branding (no rainbow gradients, no bubbly logo font). The old light "timeline" Home was removed.

### 14.1 Design language
| | Decision | Why |
|---|---|---|
| Colours | Frond `#123D2C` (brand), Rib `#3C7A57`, Sap `#CFE6C0`, Paper `#EEF2E9` (green-tinted, not cream), Card `#FBFCF8`, Ink `#15211B`, Muted `#5B6B61`, Line `#D5DDD0`, **Saffron `#E59A2B` = urgency only** | Dark green + leaf brand; saffron is from Omani kahwa |
| Night colours | Night sheet `#141A16`, raised `#1F2722`, hairline (white 12%), scrim (black 55%) | Map-first and dark screens |
| Type | **Bricolage Grotesque** (display), **Readex Pro** (body; covers Arabic for the later Arabic phase), **DM Mono** (times, prices, quantities) | Readex Pro avoids a font swap when Arabic is added |
| Signature | **Leaf + pickup-window bar**: leaf pins carry a meals-left badge, and every offer card shows a pickup-window bar where saffron marks the time left. Saffron always means "closing soon" (under 30 min) | Brand leaf that also carries real information (urgency). Replaces the earlier palm-frond timeline |
| Copy | Plain, user-side wording. Prices `0.800 OMR` (3 decimals). Restaurant names in mocks are fictional | Matches §13 conventions |

All colours are Figma variables in the **"ZAD tokens"** collection (`color/*`, `color/on-frond/*`, `color/stem`, `color/night/*`, `color/danger`). Never hard-code hex values in new screens.
**In Flutter:** mirror the tokens one-to-one in a `ZadColors` `ThemeExtension` (same names, e.g. `zad.frond`, `zad.nightRaised`), load the three fonts with `google_fonts`, and build the Figma components (Chip, Fact chip, Action tile, Form row, Pickup row, Reservation row, Map pin, Offer photo card) as reusable widgets with the same names. The splash animation maps to Flutter's implicit/explicit animations (or Rive/Lottie later); the timings are in §14.3.

### 14.2 Components (in Figma, column at x≈2240)
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
| **Approval row** (`43:857`, x 2240 y 2160) | Initial, Name, Detail (cuisine · area), Waiting (DM Mono). Avatar + chevron; used in admin lists |
| **Stat tile** (`47:952`, x 2240 y 2260) | Label, Value (DM Mono 28), Detail. Night-raised card, r20; used on Admin overview (two per row, FILL) |

Icons added for auth: chevron-left, mail, lock, eye, map-pin, locate.

### 14.3 Screens done
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

| **Insights: AI forecast** | `32:601` | Restaurant Insights tab, Forecast · Impact tabs, shown at full scroll length (402×1322). **Tomorrow card:** "~12 surplus meals expected · likely between 8 and 16" + confidence pill (dots + label, not colour alone). **7-day chart:** single series, one bar per day, P10–P90 band behind each bar, tomorrow in sap / other days in rib, value label on every bar, weekend (Fri–Sat) shaded, faint grid 0–20. **Why this forecast** chips, **suggestion** card ("prepare ~8 fewer portions… or plan an offer around 21:00") + "Post surplus now" (no prefill) + "A forecast never posts meals for you", accuracy line ("off by about 3 meals a day"), **Log yesterday** card. Matches §7.6 |

| **Auth: Account type** | `36:643` | Zesty 8/12: rib glow, leaf mark, "How will you use ZAD?", "Step 1 of 2", two **Choice cards** (I want to rescue meals · I run a restaurant), Continue pill + "Already have an account? Log in" |
| **Auth: Register** | `36:706` | "Create your account", "Signing up to rescue meals · Change" (back to account type), Text fields (Full name, Email focused + verify helper, Password + eye + rule helper), Terms/Privacy checkbox, Create account pill |
| **Auth: Location permission** | `36:786` | Zesty 12/90 pre-prompt (shown before the OS dialog): radius-ring illustration with "you" dot, 3 leaf map pins and a "3 km" label, "See meals near you", privacy card (only while using the app · rounded to ~100 m, never shown to restaurants · alerts only within 3 km), **Turn on location** + "Set my area instead" |
| **Auth: Login** | `36:865` | Leaf mark, "Welcome back", Email + Password (eye), end-aligned "Forgot password?", Log in pill, "New to ZAD? Create an account" |
| **Auth: Forgot password** | `36:929` | "Reset your password", email field (focused), spam-folder note, **Send reset link** + "Back to log in". The link opens the app (§8.1) |
| **Onboarding: Restaurant details** | `38:768` | "Restaurant setup · 1 of 3": optional logo tile, Restaurant name, **Cuisine chips** (wrap, one active), Phone (+ "shown on your meals" helper), Short description (optional), Continue |
| **Onboarding: Pickup location** | `38:873` | "2 of 3" pill over the stylised map, fixed centre **Selected map pin** (no meals badge) + "Move the map to put the pin on your entrance" hint, Locate-me button, bottom sheet "Where do people pick up?" + address Form row (filled in from the pin), **Confirm location** |
| **Onboarding: Your typical day** | `38:1033` | "3 of 3": cold-start questions for the forecast (§7.3): meals per day stepper (DM Mono **60**), "How much is usually left?" chips (Under 5% · 5–10% · **10–20%** · Over 20%), frond preview card "First forecast: ~6–12 meals a day · rough estimate until 14 days logged", required **Restaurant Terms** checkbox (§8.2), **Submit for review** |
| **Onboarding: Pending approval** | `38:1100` | Rib glow, leaf disc + clock badge, "Thanks! We're checking your restaurant", status card (Account created ✓ · Details sent ✓ · Review by the ZAD team ◉ in progress · Post your first surplus ○), Secondary **Edit restaurant details** + Log out |
| **Admin: Restaurant approvals** | `43:867` | "ZAD ADMIN" tag, "Restaurants" + "3 waiting for review · reply within a day", underline tabs (**Pending · 3** · Approved · 18 · Suspended · 1), review card for the oldest request (logo placeholder, "NEW · WAITING 7 H", Khubz & Co. Bakery · Bakery & sweets · Al Khuwair, Form rows Owner + phone / Pickup point (chevron → map pin) / Typical day, "Restaurant Terms accepted", Secondary **Reject** (danger label) + Primary **Approve**, "The owner is notified either way"), "Also waiting · 2 / Oldest first" list of **Approval row**s, admin tab bar **Overview · Restaurants · Offers · Profile** |
| **Restaurant: Daily log** | `46:931` | Opened from the Insights "Log yesterday" card. Back + "Daily log", "Log yesterday" + "Sunday 18 Oct · about 10 seconds…", two stepper cards (**Meals prepared yesterday 64** · **Left over at closing 9**, with "include meals you posted on ZAD" helper + DM Mono "9 of 64 left · 14%"), frond feedback card ("The forecast guessed ~11 for yesterday · off by 2 meals · 23 days logged"), **Earlier days** Form row (fix a missed/wrong day → `PUT /daily-logs/{date}`), **Save log**. App validation: left over ≤ prepared |
| **Admin: Overview** | `47:956` | Admin home (Overview tab active). "Overview" + "Muscat · today · updated 21:05", frond **Meals rescued** hero (**1,284** + "+46 today", "212 this week · 82% of reservations collected", "≈ 514 kg of food saved (estimate: 0.4 kg per meal)", the §12 assumption), 2×2 **Stat tile**s (Restaurants 18 · Live offers 12 · Pickups today 38 · Users 312), **Needs attention** card with Form rows → Restaurant approvals / Live offers. This is the end point of the M1 demo script |

**Chart rules for the app build** (from the dataviz check): rib bars are only 3:1 against the card, so keep the value labels; tapping a bar shows a tooltip (day, expected, range); offer a table view ("View as list") for accessibility; never prefill Add surplus from the forecast.

Layout on Page 1. **Row 1 (discover → reserve):** Splash (x −760) · Home (300) · Meal details (760) · Reserve sheet (1220) · Reserved (1680). **Row 2 (y ≈ 882, pickups):** Pickups (300) · Pickup code (760). **Row 3 (y ≈ 1956, restaurant):** Restaurant home (300) · Add new surplus (760) · Confirm pickup (1220) · Insights: AI forecast (1680). **Row 4 (y ≈ 3420, auth):** Account type (300) · Register (760) · Location permission (1220) · Login (1680) · Forgot password (2140). **Row 5 (y ≈ 4420, restaurant onboarding):** Restaurant details (300) · Pickup location (760) · Your typical day (1220) · Pending approval (1680) · Daily log (2140). **Row 6 (y ≈ 5420, admin):** Restaurant approvals (300) · Overview (760). **Components column:** x 2240 (Button, Text field and Choice card sets at y ≈ 1260–2120).
**Auth flow:** Splash "Get started" → Account type → Register → Location permission → role home. Splash "I already have an account" → Login (→ Forgot password).
The tab bar is now **Home · Pickups · Profile** on all screens (the Map tab was removed from Home).
New token: `color/danger` `#F06A5E` (destructive actions only).

**Design decisions:**
- Home **is** the map. The separate "Map" tab is now redundant. When the tab bar is next touched, change it to **Home · Pickups · Profile** (Zesty uses 3 items).
- A list view of offers still exists inside the Home sheet (drag up), sorted by pickup end, so urgency is still easy to scan.
- Restaurant photos stay **optional** (less work at closing time). Without a photo, the card shows a cuisine placeholder.

### 14.4 Screens remaining (~27), with the Zesty screen to borrow from
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
- **Restaurant (6):** ~~Onboarding + pending approval~~ (done) · ~~Restaurant home + Confirm pickup~~ (done) · ~~Add new surplus~~ (done) · Manage current offers · ~~Daily log~~ (done) · ~~AI forecasts~~ (done) · Waste-reduction statistics · Past meals history · Settings & location
- **Admin, inside the app (7):** ~~Overview~~ (done) · ~~Restaurant approvals~~ (done; a "Reject with reason" sheet is still open) · Users · Offer moderation · Reports queue · Data quality · Audit log
- **Not yet:** prototype links between screens; real food photos (Figma AI image generation needs approval because it uses AI credits)

**Design freeze (2026-10-19):** after Daily log and Admin overview, Figma work stops and the build starts (M0). The remaining core screens (Notifications, Profile, Set my area, Manage/Past offers, Admin offers, Restaurant settings) are built straight in Flutter from the existing components (Form row, Pickup row, Approval row, Stat tile, Button, Chip). Everything else in this section is optional.

### 14.5 Suggested design order
1. ~~Meal details + Reserve~~ (done) → 2. ~~My reservations (pickup code)~~ (done) → 3. ~~Add new surplus~~ (done) → 4. ~~Restaurant home + Confirm pickup~~ (done). **The core-loop demo is fully designed.**
5. ~~AI forecasts~~ (done) → 6. ~~Auth screens (Login, Register, Account type, Location permission, Forgot password)~~ (done) → 7. ~~Restaurant onboarding + pending~~ (done) → 8. ~~Admin: Restaurant approvals~~ (done) → Notifications → Set my area → Profile → Daily log → Manage/Past offers → Admin overview + offers → Restaurant settings → remaining screens → Admin screens → clickable prototype.
