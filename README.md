# Flutter MVVM + Clean Architecture Template

A production-ready Flutter template following **MVVM + Clean Architecture** principles.

## Project Structure

```
lib/
├── core/
│   ├── error/           # Failures & Exceptions
│   ├── usecases/        # Base UseCase abstraction
│   └── utils/           # Constants & DI container (GetIt)
├── data/
│   ├── datasources/
│   │   ├── local/       # SharedPreferences / local DB
│   │   └── remote/      # Dio HTTP clients
│   ├── models/          # JSON-serializable data models
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Pure business objects
│   ├── repositories/    # Repository interfaces (contracts)
│   └── usecases/        # Business logic use cases
└── presentation/
    ├── pages/           # Screens / Pages
    ├── viewmodels/      # ChangeNotifier ViewModels
    └── widgets/         # Reusable UI components
```

## Architecture Layers

| Layer        | Responsibility                                  |
|--------------|-------------------------------------------------|
| Presentation | UI, ViewModels, state (Provider + ChangeNotifier)|
| Domain       | Entities, Use Cases, Repository contracts        |
| Data         | API calls, caching, repository implementations   |

## Key Libraries

| Library              | Purpose                        |
|----------------------|--------------------------------|
| `provider`           | State management (MVVM)        |
| `get_it`             | Dependency injection           |
| `dio`                | HTTP networking                |
| `shared_preferences` | Local storage / caching        |
| `dartz`              | Functional error handling (Either) |
| `equatable`          | Value equality for entities    |

## Getting Started

```bash
flutter pub get
flutter run
```

## Running Tests

```bash
flutter test
# Regenerate mocks after changes:
flutter pub run build_runner build --delete-conflicting-outputs
```

## Branch & Deployment Strategy

| Branch | CI | Android Deploy | iOS Deploy |
|--------|----|----------------|------------|
| `feature/*` | ✅ on PR | — | — |
| `develop` | ✅ on push | Internal track (draft) | TestFlight beta |
| `main` | ✅ on push | Production track | App Store submission |

```
feature/* ──PR──▶ develop ──PR──▶ main
                    │                │
               TestFlight       App Store
               Internal track   Production track
```

## CI/CD Workflows

| File | Trigger | Purpose |
|------|---------|---------|
| `.github/workflows/ci.yml` | Push/PR on `main`, `develop` | Lint, test, build validation |
| `.github/workflows/cd-android.yml` | Push to `main`/`develop` | Sign AAB + deploy to Google Play |
| `.github/workflows/cd-ios.yml` | Push to `main`/`develop` | Sign IPA + deploy to TestFlight/App Store |

## Required GitHub Secrets

### Create GitHub Environments
Go to **Settings → Environments** and create two environments: `staging` and `production`.

### Android Secrets

| Secret | How to get it |
|--------|---------------|
| `KEYSTORE_BASE64` | `base64 -i release.keystore` |
| `KEYSTORE_PASSWORD` | Password used when creating the keystore |
| `KEY_PASSWORD` | Key entry password |
| `KEYSTORE_ALIAS` | Key alias used during keystore creation |
| `ANDROID_PACKAGE_NAME` | e.g. `com.example.app` |
| `GOOGLE_PLAY_KEY` | Base64-encoded Google Play service account JSON: `base64 -i key.json` |

**Create the keystore:**
```bash
keytool -genkey -v -keystore release.keystore \
  -alias your-alias -keyalg RSA -keysize 2048 -validity 10000
```

**Create a Google Play service account:**
1. Google Play Console → Setup → API access → Create service account
2. Grant **Release Manager** role
3. Download JSON key → `base64 -i key.json` → paste as `GOOGLE_PLAY_KEY`

### iOS Secrets

| Secret | How to get it |
|--------|---------------|
| `IOS_CERTIFICATE_BASE64` | `base64 -i Certificates.p12` |
| `IOS_CERTIFICATE_PASSWORD` | Password set when exporting the .p12 |
| `IOS_KEYCHAIN_PASSWORD` | Any strong random string (used for temp keychain) |
| `IOS_PROVISIONING_PROFILE_BASE64` | `base64 -i profile.mobileprovision` |
| `IOS_PROVISIONING_PROFILE_NAME` | Name shown in Apple Developer portal |
| `IOS_BUNDLE_ID` | e.g. `com.example.app` |
| `IOS_CODE_SIGN_IDENTITY` | e.g. `iPhone Distribution: Your Name (XXXXXXXXXX)` |
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from App Store Connect → Users → Keys |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from the same page |
| `APP_STORE_CONNECT_API_KEY_BASE64` | `base64 -i AuthKey_XXXXX.p8` |

**Export .p12 certificate:**
1. Keychain Access → My Certificates → right-click Distribution cert → Export
2. Choose `.p12` format and set a password

**Create App Store Connect API key:**
1. App Store Connect → Users and Access → Keys → Generate API Key
2. Role: **Developer** (minimum needed for uploads)
3. Download the `.p8` file (only available once)

## Adding a New Feature

1. **Entity** → `domain/entities/`
2. **Repository contract** → `domain/repositories/`
3. **Use case** → `domain/usecases/`
4. **Model** (JSON) → `data/models/`
5. **Data sources** → `data/datasources/`
6. **Repository impl** → `data/repositories/`
7. **ViewModel** → `presentation/viewmodels/`
8. **Page + Widgets** → `presentation/pages/`
9. **Wire up** in `core/utils/injection_container.dart`
