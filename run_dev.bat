@echo off
echo 🚀 Starting Flutter app in DEVELOPMENT mode...
echo    API: https://jsonplaceholder.typicode.com
echo    Env banner: GREEN (top-left)
echo.
flutter run --target lib/main.dart --dart-define=FLUTTER_APP_FLAVOR=development
