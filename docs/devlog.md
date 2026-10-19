# ZAD devlog

Three lines per session: done / next / blockers.

## 2026-10-19 · P1 UI, session 1
- **Done:** Figma frozen (Daily log + Admin overview were the last frames). Flutter app created in `app/` (Android + web for previews): `ZadColors` tokens, `ZadType` fonts, l10n (ARB), go_router + Riverpod, `ZadButton`, `LeafMark`, and the animated **Splash** (11:179) matching Figma timings. Analyzer clean, 2 tests pass.
- **Next:** Account type → Register → Login → Location permission screens; then the fake data layer.
- **Blockers:** no Android phone connected yet, so the splash was checked in a web build. Run it on a phone next session.

## 2026-10-19 · Infra
- **Done:** Docker Compose stack (`zad`): `mongo:7.0` + `backend` (Python 3.12, Django 5.2.18, django-mongodb-backend 5.2.4). `GET /api/v1/health` returns ok on localhost and on the laptop's Wi-Fi IP.
- **Next:** back to P1 UI (auth screens). In P2: add DRF + the week-1 spike inside the container.
- **Blockers:** not yet tested from a phone (check Windows Firewall allows port 8000).
