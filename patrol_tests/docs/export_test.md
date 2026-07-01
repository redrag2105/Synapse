# export_test.dart

**Test file:** `patrol_tests/export_test.dart`  
**Requirements:** Test Case 9 – PDF Export ([`testing.md`](../../testing.md))

---

## Patrol tests in this file

| Patrol test name | Test case |
|------------------|-----------|
| `PDF export uploads report to Firebase Storage` | 9 – PDF Export |

---

## Test Case 9 – PDF Export

### Scenario

1. Launch the app on Home.
2. Open Profile and sign in with Google.
3. Scroll to the **Report Export** section.
4. Tap **Export PDF report**.
5. Wait for PDF generation and Firebase Storage upload.
6. Verify the uploaded file URL and success message are shown.

### Command

```bash
patrol test -t patrol_tests/export_test.dart --dart-define-from-file=.env --dart-define=PATROL_GOOGLE_EMAIL=you@gmail.com
```

### Expected result

| Step | Assertion |
|------|-----------|
| After sign-in | `signed_in_profile` key visible |
| After export | `export_uploaded_url` key visible |
| Success | **Report uploaded successfully.** message visible |

Patrol reports **PASSED**.

### Prerequisites

- **Google account** on the device (pass `PATROL_GOOGLE_EMAIL`)
- **Firebase** configured (`google-services.json`, Storage rules allowing upload)
- **Internet** access
- Export is skipped on **macOS** (no native Google Sign-In in Patrol)

### Test keys used

| Key | Purpose |
|-----|---------|
| `google_sign_in_button` | Start Google Sign-In |
| `signed_in_profile` | Signed-in profile loaded |
| `export_pdf_button` | Trigger PDF export |
| `export_status_message` | Inline export success/failure message |
| `export_uploaded_url` | Upload succeeded (URL shown) |

### Notes

- PDF generation and upload can take up to ~120 seconds.
- The test scrolls to the export button on the profile screen.
- Export status is shown inline in the Report Export section (not only at the top).
- Deploy Storage rules before running: `firebase deploy --only storage` (see `storage.rules`). Only needed if uploads fail with permission errors — default Firebase projects often already allow authenticated writes.

### Common failures

| Symptom | Likely cause |
|---------|----------------|
| `PDF export timed out` | Storage rules not deployed — run `firebase deploy --only storage` |
| `PDF export failed:` in test output | Storage permission, network, or Firebase project misconfiguration |
| Sign-in failure | Missing `PATROL_GOOGLE_EMAIL` or account not on device |
| `Report export failed:` in status banner | Firebase Storage or PDF generation error — check logcat |
