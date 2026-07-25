# Mingla

A dating app MVP: swipe, match, and chat. FastAPI backend, Flutter client for iOS and Android.

## Backend (`app/`)

FastAPI + SQLAlchemy (SQLite by default). Endpoints:

- `POST /api/auth/register`, `POST /api/auth/login` — JWT auth (18+ enforced on signup)
- `GET/PUT /api/users/me`, `POST/DELETE /api/users/me/photos/{id}` — profile & photos
- `GET /api/discover` — candidates excluding self and already-swiped users, filtered by mutual gender preference
- `POST /api/swipes` — like/pass; creates a `Match` when both sides like each other
- `GET /api/matches`, `GET/POST /api/matches/{id}/messages` — matches and 1:1 chat

### Run it

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
uvicorn app.main:app --reload
```

API docs at `http://localhost:8000/docs`.

### Test it

```bash
pytest
```

### Notes

- Default DB is `sqlite:///./dev.db`; override with `DATABASE_URL`. Set `SECRET_KEY` in production.
- Uploaded photos are stored under `app/static/uploads/` and served from `/static/uploads/...`.
- There's no push-notification or real-time (websocket) chat layer yet — the mobile app polls for new messages.

## Mobile app (`mobile/`)

Flutter (iOS + Android) client: login/register, swipe-to-discover, matches list, chat, and profile/photo management.

This repo ships the Dart source (`mobile/lib/`) and `pubspec.yaml` only — the native `android/` and `ios/` project folders aren't checked in, since generating them requires the Flutter SDK (not available in the environment this was built in). To get it running:

```bash
cd mobile
flutter create --org com.gridheart.mingla --project-name mingla .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

`flutter create .` scaffolds `android/` and `ios/` without touching the existing `lib/` or `pubspec.yaml`. After that:

- **iOS**: add `NSPhotoLibraryUsageDescription` to `ios/Runner/Info.plist` (required by `image_picker` for the profile-photo picker).
- **Android**: on the emulator, `API_BASE_URL` defaults to `http://10.0.2.2:8000` automatically (see `lib/config.dart`) so it can reach a backend running on your host machine.
- This code hasn't been run through `flutter analyze`/`flutter run` in this environment (no Flutter SDK installed here) — do that first after scaffolding, before relying on it.

### Architecture

- `services/api_client.dart` — HTTP wrapper, attaches the JWT bearer token
- `services/auth_service.dart` — session state (`ChangeNotifier`), persists the token via `flutter_secure_storage`
- `services/*_repository.dart` — one repository per backend resource (discovery, matches/chat, profile)
- `screens/` — login, register, discover (swipe), matches, chat, profile
- State is wired up with `provider`; no code generation step required
