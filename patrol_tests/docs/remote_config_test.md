# remote_config_test.dart

**Test file:** `patrol_tests/remote_config_test.dart`  
**Requirements:** Test Case 10 – Remote Config ([`testing.md`](../../testing.md))

---

## Patrol tests in this file

| Patrol test name | Test case |
|------------------|-----------|
| `Remote Config values are retrieved and displayed` | 10 – Remote Config |

---

## Test Case 10 – Remote Config

### Scenario

1. Launch the app and open Profile.
2. Complete Google Sign-In.
3. Scroll to the **Remote Config** section.
4. Verify **Max journals** and **Max keywords** values are displayed.
5. Tap **Refresh values** and verify values remain visible.

### Command

```bash
patrol test -t patrol_tests/remote_config_test.dart --dart-define-from-file=.env --dart-define=PATROL_GOOGLE_EMAIL=you@gmail.com
```

### Expected result

| Step | Assertion |
|------|-----------|
| Section | `remote_config_section` visible |
| Values | `remote_config_max_journals` / `remote_config_max_keywords` show numeric values (not `—`) |
| Refresh | `remote_config_refresh_button` works and values still display |

Patrol reports **PASSED**.

### Prerequisites

- Signed-in user (Firebase Remote Config + Auth)
- Android with Google Play Services
- Firebase project Remote Config parameters configured (or defaults)

### Test keys used

| Key | Purpose |
|-----|---------|
| `signed_in_profile` | Profile after sign-in |
| `remote_config_section` | Remote Config card |
| `remote_config_max_journals` | Max journals metric |
| `remote_config_max_keywords` | Max keywords metric |
| `remote_config_refresh_button` | Refresh values |
