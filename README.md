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

This repo ships the Dart source (`mobile/lib/`, `mobile/test/`) and `pubspec.yaml`/`pubspec.lock` — the native `android/`, `ios/`, `linux/`, `macos/`, and `web/` project folders aren't checked in; `flutter create` regenerates them on demand. To get it running:

```bash
cd mobile
flutter create --org com.gridheart.mingla --project-name mingla .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

`flutter create .` scaffolds the platform folders without touching the existing `lib/`, `test/`, or `pubspec.yaml`. After that:

- **iOS**: add `NSPhotoLibraryUsageDescription` to `ios/Runner/Info.plist` (required by `image_picker` for the profile-photo picker).
- **Android**: on the emulator, `API_BASE_URL` defaults to `http://10.0.2.2:8000` automatically (see `lib/config.dart`) so it can reach a backend running on your host machine.
- `flutter analyze` and `flutter test` are clean, and the app has been run end-to-end (register → discover → swipe → matches → profile) against the live backend on Linux desktop — not just statically checked.

### Architecture

- `services/api_client.dart` — HTTP wrapper, attaches the JWT bearer token
- `services/auth_service.dart` — session state (`ChangeNotifier`), persists the token via `flutter_secure_storage`
- `services/*_repository.dart` — one repository per backend resource (discovery, matches/chat, profile)
- `screens/` — login, register, discover (swipe), matches, chat, profile
- State is wired up with `provider`; no code generation step required
