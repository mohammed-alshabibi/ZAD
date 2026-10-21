# ZAD devlog

Three lines per session: done / next / blockers.

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
