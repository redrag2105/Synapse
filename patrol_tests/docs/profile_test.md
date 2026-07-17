# profile_test.dart

**Test file:** `patrol_tests/profile_test.dart`  
**Requirements:** Test Case 8 – Profile Navigation ([`testing.md`](../../testing.md))

---

## Patrol tests in this file

| Patrol test name | Test case |
|------------------|-----------|
| `Profile tab shows signed-in user profile information` | 8 – Profile Navigation |

---

## Test Case 8 – Profile Navigation

### Scenario

1. Launch the app on Home.
2. Tap the **Profile** tab in the bottom navigation.
3. Sign in with Google if signed out.
4. Verify signed-in profile information is displayed.

### Command

```bash
patrol test -t patrol_tests/profile_test.dart --dart-define-from-file=.env --dart-define=PATROL_GOOGLE_EMAIL=you@gmail.com
```

### Expected result

| Step | Assertion |
|------|-----------|
| Profile tab | `signed_in_profile` visible |
| Identity | **Profile** title and **Active** badge visible |
| Sections | **Notification Center** and **Sign out** visible |

Patrol reports **PASSED**.

### Prerequisites

- Android device/emulator with Google Play Services
- Google account on device; optional `PATROL_GOOGLE_EMAIL`
- Skips native Google flow on **macOS**

### Test keys used

| Key | Purpose |
|-----|---------|
| `bottom_nav_profile` | Open Profile tab |
| `signed_in_profile` | Signed-in Profile screen |
| `google_sign_in_button` | Trigger Google Sign-In when needed |
| `sign_out_button` | Confirm signed-in chrome |
