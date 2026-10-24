# ZAD devlog

Three lines per session: done / next / blockers.

## 2026-10-21 · P1 UI, session 4 (`feature/restaurant-home`, branched from `feature/restaurant-onboarding`)
- **Done:** Restaurant home (29:400) + Confirm pickup sheet (31:535). Tab bar shell (Today · Offers · + · Insights · Profile; the other tabs are placeholders, Profile has Log out). Today tab: tonight's stats, live offer card with pickup-window bar (saffron under 30 min), Edit quantity and End early sheets, waiting/collected pickups, tomorrow's forecast card, floating Confirm pickup. Confirm pickup: 6-digit boxes → `POST /pickups/check` shows "Code matches · Aisha" → `POST /pickups/confirm`; 5 wrong codes lock entry for 10 min. Fakes for `GET /restaurants/me/offers`, `PATCH /offers/{id}`, `POST /offers/{id}/cancel`, `GET /restaurants/me/reservations`, `GET /forecasts`, with lazy expiry; the restaurant only ever sees the last 3 code digits. New widgets: `ZadReservationRow`, `PickupWindowBar`, `ZadSheet`; `formatOmr`; icons pre-load at startup (late-loading SVGs stayed blank in the web build). Demo: log in as khubz@example.com, codes 482913 (Aisha) and 610271 (Salim). 37 tests pass, analyzer clean.
- **Next:** merge onboarding + this branch after a phone check, then the user Home map (Mapbox) → Meal details → Reserve, so the code a user gets can be confirmed here.
- **Blockers:** "Scan QR instead" from the Figma sheet is left out (needs a camera/QR package; the user-side QR is decorative). Emulator was too slow to run the app today; screens checked in a 402×874 web render.

## 2026-10-21 · P1 UI, session 3 (`feature/restaurant-onboarding`)
- **Done:** auth work merged into `main`. **Mapbox replaces Google Maps** (no billing setup; free tier = 100 monthly active phones): `mapbox_maps_flutter` with the `dark-v11` style, token in git-ignored `app/config/mapbox.json`, run with `--dart-define-from-file=config/mapbox.json` (VS Code "ZAD app" launch config does this). Restaurant onboarding built from Figma: Restaurant details (38:768), Pickup location (38:873, real map + fixed centre pin + Mapbox reverse geocoding, address editable), Your typical day (38:1033, stepper + surplus chips + forecast preview + Restaurant Terms), Pending approval (38:1100, pull down to re-check). `RestaurantRepository` + `FakeRestaurantRepository` (`POST /restaurants`, `GET`/`PATCH /restaurants/me`); after login a restaurant goes to onboarding / pending / home by status. New widgets: `ZadChip`, `ZadFormRow`, `ZadStepper`, `ZadSelectedMapPin`. New demo login karak@example.com (restaurant waiting for review). 27 tests pass, analyzer clean.
- **Next:** Restaurant home (29:400) so approved restaurants land somewhere real, then the user Home map (reuse the Mapbox setup).
- **Blockers:** the logo upload tile is not wired yet (needs `image_picker`; photos are first in the cut order).

## 2026-10-19 · P1 UI, session 2 (`feature/auth-screens`)
- **Done:** Account type (36:643), Register (36:706), Login (36:865) and Location permission (36:786) built from Figma, plus widgets `ZadIcon`, `ZadTextField`, `ZadChoiceCard`, `ZadCheckbox`, `ZadMapPin`, and a loading state on `ZadButton`. First fake data layer: `AuthRepository` + `FakeAuthRepository` (§5 JSON shapes) behind `sessionProvider`; role routing after login/signup; real OS location prompt via `geolocator`, rounded to 3 decimals. Demo logins (password `zad12345`): aisha@example.com (user), khubz@example.com (restaurant), admin@zad.om (admin). 13 tests pass, analyzer clean, screens checked against Figma in a 402×874 web render.
- **Next:** Restaurant onboarding (3 steps + pending), then the user Home map. Later: route guards by role, and the "Set my area" pin screen.
- **Blockers:** still no Android phone, so the location prompt and keyboard behaviour are untested on a device.
- **Update (2026-10-21):** the auth flow (splash → account type → register/login → location prompt → role routing) was run on the Android emulator and works. This clears the "no Android phone" blocker for now; a physical phone is still needed for push (P2).

## 2026-10-19 · P1 UI, session 1
- **Done:** Figma frozen (Daily log + Admin overview were the last frames). Flutter app created in `app/` (Android + web for previews): `ZadColors` tokens, `ZadType` fonts, l10n (ARB), go_router + Riverpod, `ZadButton`, `LeafMark`, and the animated **Splash** (11:179) matching Figma timings. Analyzer clean, 2 tests pass.
- **Next:** Account type → Register → Login → Location permission screens; then the fake data layer.
- **Blockers:** no Android phone connected yet, so the splash was checked in a web build. Run it on a phone next session.

## 2026-10-19 · Infra
- **Done:** Docker Compose stack (`zad`): `mongo:7.0` + `backend` (Python 3.12, Django 5.2.18, django-mongodb-backend 5.2.4). `GET /api/v1/health` returns ok on localhost and on the laptop's Wi-Fi IP.
- **Next:** back to P1 UI (auth screens). In P2: add DRF + the week-1 spike inside the container.
- **Blockers:** not yet tested from a phone (check Windows Firewall allows port 8000).
