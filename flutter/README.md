# Flutter Android/iOS Client

Module A is the shared Flutter MVP client for the Warfarin INR Assistant demo. It targets Android and iOS with one low-coupling codebase and mirrors `packages/api-contract/openapi.yaml` plus the current Go server JSON envelope.

> This app records medication and INR monitoring data only. It does not provide medical advice or dosage decisions.

## Architecture

```text
lib/
  core/
    api/          ApiClient abstraction, HTTP implementation, local mock client
    config/       API base URL and compile-time app configuration
    theme/        Material 3 theme tokens
  domain/models/  Contract-aligned medication, INR, settings, reminder models
  state/          Riverpod providers and action controllers
  features/
    home/         Reminder, latest INR, next test and today medication summary
    medication/   Medication action form and tomorrow-dose mode selection
    inr/          Raw/corrected INR records and lightweight trend chart
    settings/     Read-only MVP settings overview
```

The UI depends on Riverpod providers and domain models, not directly on HTTP. `ApiClient` can be swapped between `MockApiClient` and `HttpApiClient` with Dart defines.

## SDK verification

From this directory, verify the Flutter SDK first:

```sh
flutter --version
flutter doctor -v
flutter pub get
flutter analyze
flutter test
```

If Flutter is unavailable in the current environment, perform lightweight static checks from the repository root:

```sh
find flutter/lib flutter/test -type f | sort
rg "class .*ApiClient|FutureProvider|ConsumerWidget|ConsumerStatefulWidget" flutter/lib
rg "latestInr|targetInrMin|tomorrowDoseMode|correctedValue" flutter/lib flutter/test
```


### Local machine note

On the current development machine, Flutter is installed under `/home/pi/.hermes/tools/flutter` and exposed as `/home/pi/.local/bin/flutter`. If a non-login shell cannot find it, prepend:

```sh
export PATH="$HOME/.hermes/tools/flutter/bin:$HOME/.local/bin:$PATH"
```

## Running with mock data

Mock API mode is enabled by default so the app can render before the backend is running:

```sh
flutter run -d ios
flutter run -d android
```

## Running against the server

Start the Go API server, then disable mock mode and provide the API base URL:

```sh
flutter run \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
```

For Android emulators, use the host loopback alias when the server runs on the development machine:

```sh
flutter run \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```
