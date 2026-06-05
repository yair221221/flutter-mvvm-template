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
