# authentication_test.dart

**Test file:** `patrol_tests/authentication_test.dart`  
**Requirement:** Test Case 1 – Google Sign-In ([`testing.md`](../../testing.md))

---

## Patrol tests in this file

| Patrol test name | Test case |
|------------------|-----------|
| `Google Sign-In navigates to Home with signed-in profile` | 1 – Google Sign-In |

---

## Test Case 1 – Google Sign-In

### Scenario

1. Launch the app (Home / Discover tab).
2. Open Profile from the Discover header.
3. Sign in with Google (native account picker on Android).
4. Confirm signed-in Profile (Notification Center visible).
5. Navigate back to Home.
6. Confirm signed-in state on Home (profile avatar in header).

### Command

```bash
patrol test -t patrol_tests/authentication_test.dart \
  --dart-define-from-file=.env \
  --dart-define=PATROL_GOOGLE_EMAIL=you@gmail.com
```

Run only this test by name:

```bash
patrol test -t patrol_tests/authentication_test.dart \
  --dart-define-from-file=.env \
  --name "Google Sign-In" \
  --dart-define=PATROL_GOOGLE_EMAIL=you@gmail.com
```

### Expected result

| Step | Assertion |
|------|-----------|
| App starts | `discover_screen` key visible; text **Keywords** on screen |
| Profile (signed out) | **Sign in to continue** visible |
| After Google Sign-In | `signed_in_profile` key visible; **Notification Center** visible |
| Back on Home | `discover_screen` visible; scroll to collapse header; `discover_signed_in_profile` avatar visible |

Patrol reports **PASSED** when all assertions succeed.

### Prerequisites

- Android device or emulator **with Google Play Services**
- Google account added on the device (Settings → Accounts)
- Firebase / `google-services.json` configured
- Optional: `PATROL_GOOGLE_EMAIL` when multiple accounts appear in the picker

### Test keys used

| Key | Purpose |
|-----|---------|
| `discover_screen` | Home / Discover tab loaded |
| `discover_profile_button` | Open Profile from header |
| `google_sign_in_button` | Trigger Google Sign-In |
| `signed_in_profile` | Signed-in Profile screen |
| `bottom_nav_home` | Leave Profile via Home tab |
| `discover_signed_in_profile` | Signed-in avatar on Home |

### Notes

- Skips native Google flow on **macOS** (Patrol native automation limitation).
- First run may show a permission dialog; the test grants it when possible.

### Common failures

| Symptom | Likely cause |
|---------|----------------|
| Timeout on `google_sign_in_button` | Profile screen not reached |
| `pumpAndSettle timed out` after Sign-In tap | Fixed in helper — native picker blocks Flutter settle; test now waits for native UI instead |
| Timeout on native account tap | No Google account on device / wrong `PATROL_GOOGLE_EMAIL` / watch phone during test |
| `signed_in_profile` not found | Sign-in cancelled or Firebase Auth misconfigured |
| `discover_signed_in_profile` not found / not visible | Avatar only shows when the discover header is **collapsed** — scroll down on Home first (test helper does this automatically) |
