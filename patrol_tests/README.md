# Patrol E2E Tests

End-to-end tests for Synapse using [Patrol](https://patrol.leancode.co/). Requirements are in [`testing.md`](../testing.md).

## Layout

```text
patrol_tests/
├── README.md                 ← this file (setup & index)
├── docs/                     ← one doc per test file
│   ├── authentication_test.md
│   └── publication_test.md
├── helpers/
│   └── patrol_helpers.dart
├── authentication_test.dart
└── publication_test.dart
```

UI targets use keys from `lib/app/config/test_keys.dart`.

## Prerequisites

| Requirement | Notes |
|-------------|--------|
| Flutter SDK | `flutter doctor` |
| Patrol CLI | `dart pub global activate patrol_cli` |
| Android device or emulator | Recommended — Google Sign-In needs Play Services |
| Network | Publication tests call the OpenAlex API |
| Firebase | `google-services.json` for sign-in tests |
| Android native test | `MainActivityTest.java` under `android/app/src/androidTest/java/com/example/synapse/` |

```bash
patrol doctor
flutter pub get
```

## Environment variables

Create a `.env` file in the project root (same as VS Code debug — see `.vscode/launch.json`). Patrol does **not** load it automatically; pass it when running tests.

| Variable | Purpose |
|----------|---------|
| `API_KEY` | OpenAlex API key (required for reliable search under test load; debug already uses this via `.env`) |
| `PATROL_GOOGLE_EMAIL` | Pick the right account in the Android Google picker (`--dart-define=PATROL_GOOGLE_EMAIL=you@gmail.com`) |

Example `.env`:

```env
API_KEY=your_openalex_api_key
```

## Run commands

```bash
# All implemented tests (pass .env so API_KEY matches debug runs)
patrol test --dart-define-from-file=.env

# Single file
patrol test -t patrol_tests/authentication_test.dart --dart-define-from-file=.env
patrol test -t patrol_tests/publication_test.dart --dart-define-from-file=.env
```

Per-test commands, scenarios, and expected results are in [`docs/`](docs/).

## Test documentation

| Test file | Doc | Test cases | Status |
|-----------|-----|------------|--------|
| `authentication_test.dart` | [docs/authentication_test.md](docs/authentication_test.md) | 1 – Google Sign-In | Implemented |
| `publication_test.dart` | [docs/publication_test.md](docs/publication_test.md) | 2 – Topic Search, 3 – Publication Details | Implemented |
| `journal_test.dart` | — | 4 – Journals Navigation, 5 – Journal Details | Not implemented |
| `keyword_test.dart` | — | 6 – Keywords Navigation, 7 – Keyword Details | Not implemented |
| `profile_test.dart` | — | 8 – Profile Navigation | Not implemented |
| `export_test.dart` | — | 9 – PDF Export | Not implemented |
| `remote_config_test.dart` | — | 10 – Remote Config | Not implemented |
| `authentication_test.dart` (logout) | — | 11 – Logout | Not implemented |

When you add a new test file, create a matching doc under `docs/` (e.g. `journal_test.md`) and add a row to the table above.

## Troubleshooting

| Issue | Fix |
|-------|-----|
| **Total: 0 tests** / **stuck at Executing tests** | Ensure `MainActivityTest.java` exists and `testInstrumentationRunner` is `com.example.synapse.SynapsePatrolJUnitRunner`. On **Android 12+ / MIUI**, instrumentation cannot start the app from the background (`Abort background activity starts`) — `SynapsePatrolJUnitRunner` launches via shell `am start` to bypass this. Both `com.example.synapse` and `com.example.synapse.test` must be installed — check with `adb shell pm list packages \| findstr synapse`. |
| **Install prompts** (Synapse, orchestrator, `com.example.synapse.test`) | On some MIUI builds you may need **Install via USB** in Developer options. Accept install dialogs when they appear. |
| **SpeakEasy Binder Registry** notification | Normal AndroidX Test Orchestrator message during tests. |
| **`MainActivityTest.java` not on classpath** (IDE) | Workspace `.vscode/settings.json` configures Java Gradle import; reload window or run **Java: Clean Java Language Server Workspace** if warnings persist. Gradle still compiles `androidTest` correctly. |
| **API 35 (Android 15)** | Supported with `SynapsePatrolJUnitRunner`. If logcat shows `Abort background activity starts`, rebuild the test APK (`flutter build apk` then `patrol test`). |
| **App opens, closes, then opens again** | Normal. AndroidX Test Orchestrator first launches Synapse to discover Dart tests (`patrol_test_explorer`), then tears down and relaunches for each test with a clean process. |
| **Search shows `Lỗi:` / HTTP 503** | Patrol builds without `.env` by default. Debug uses `--dart-define-from-file=.env` (see `.vscode/launch.json`) which includes `API_KEY`. Run `patrol test --dart-define-from-file=.env` so tests use the same OpenAlex credentials as debug. |
| `patrol: command not found` | Add Pub cache bin to PATH, or `dart pub global run patrol_cli:patrol test ...` |

### Xiaomi / MIUI phones

Patrol installs **two** packages: the app (`com.example.synapse`) and the test runner (`com.example.synapse.test`).

**Background activity launch (main hang cause):** MIUI/Android blocks the default Patrol runner from starting `MainActivity` during instrumentation. This project uses `SynapsePatrolJUnitRunner`, which starts the app with `am start` via UiAutomation shell (same as `adb shell am start -n com.example.synapse/.MainActivity`).

If installs are blocked:

1. **Settings → Additional settings → Developer options**
2. Enable **USB debugging** and **Install via USB** (wording varies by MIUI version)
3. Tap **Install** on any prompts when running `patrol test`

Verify both packages installed:

```bash
adb shell pm list packages | findstr synapse
```

Expected output includes both:

```text
package:com.example.synapse
package:com.example.synapse.test
```
| CI failures on sign-in | Use an emulator image **with Google Play** |
| `test_bundle.dart` changes | Generated by Patrol — in `.gitignore`; do not commit |
| Android build errors | Check Patrol test runner and desugaring in `android/app/build.gradle.kts` |
