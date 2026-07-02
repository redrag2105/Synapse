# logout_test.dart

**Test file:** `patrol_tests/logout_test.dart`  
**Requirement:** Test Case 11 – Logout ([`testing.md`](../../testing.md))

---

## Patrol tests in this file

| Patrol test name | Test case |
|------------------|-----------|
| `Logout returns to sign-in screen` | 11 – Logout |

---

## Test Case 11 – Logout

### Scenario

1. Launch the app on Home.
2. Open Profile and sign in with Google.
3. Tap **Sign out** in the profile header.
4. Verify the signed-out Profile gate is shown (login prompt + Google Sign-In button).

### Command

```bash
patrol test -t patrol_tests/logout_test.dart --dart-define-from-file=.env --dart-define=PATROL_GOOGLE_EMAIL=you@gmail.com
```

### Expected result

| Step | Assertion |
|------|-----------|
| After sign-in | `signed_in_profile` key visible |
| After sign-out | `signed_out_profile` key visible |
| Login screen | `google_sign_in_button` key visible |

Patrol reports **PASSED**.

### Prerequisites

- **Google account** on the device (pass `PATROL_GOOGLE_EMAIL`)
- **Firebase** configured (`google-services.json`)
- Skipped on **macOS** (no native Google Sign-In in Patrol)

### Test keys used

| Key | Purpose |
|-----|---------|
| `discover_profile_button` | Open Profile |
| `google_sign_in_button` | Sign in before logout |
| `signed_in_profile` | Signed-in state before logout |
| `sign_out_button` | Trigger logout |
| `signed_out_profile` | Signed-out Profile gate |
| `google_sign_in_button` | Login screen after logout |

### Notes

- Synapse does not navigate to a separate login route; logout switches Profile to the signed-out gate (**Sign in to continue**).
- Reuses `signInAndOpenProfile` from `patrol_helpers.dart`.

### Common failures

| Symptom | Likely cause |
|---------|----------------|
| Timeout on `sign_out_button` | Profile not signed in |
| Timeout on `signed_out_profile` | Sign-out failed or Firebase Auth error |
| Sign-in step fails | Missing `PATROL_GOOGLE_EMAIL` or account not on device |
