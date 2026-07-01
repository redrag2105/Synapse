# journal_test.dart

**Test file:** `patrol_tests/journal_test.dart`  
**Requirements:** Test Case 4 – Journals Navigation, Test Case 5 – Journal Details ([`testing.md`](../../testing.md))

---

## Patrol tests in this file

| Patrol test name | Test case |
|------------------|-----------|
| `Journals tab shows statistics and journal list` | 4 – Journals Navigation |
| `Journal details screen shows journal information` | 5 – Journal Details |

---

## Test Case 4 – Journals Navigation

### Scenario

1. Launch the app on Home.
2. Tap the **Journals** tab in the bottom navigation.
3. Wait for the leading journals overview to load.
4. Verify journal statistics and the detailed leaderboard list are shown.

### Command

```bash
patrol test -t patrol_tests/journal_test.dart --dart-define-from-file=.env --name "Journals tab"
```

### Expected result

| Step | Assertion |
|------|-----------|
| Journals tab | `journals_screen` key visible |
| Overview | `journals_statistics` key visible (after scroll) |
| Statistics | **Active Journals** metric visible |
| List | **Detailed Leaderboard** heading and `first_journal_tile` visible |

Patrol reports **PASSED**.

### Prerequisites

- **Internet** access (journal data uses the OpenAlex API)
- **`.env` with `API_KEY`** — pass `--dart-define-from-file=.env`
- No sign-in required

### Test keys used

| Key | Purpose |
|-----|---------|
| `bottom_nav_journals` | Open Journals tab |
| `journals_screen` | Journals screen loaded |
| `journals_statistics` | Statistics section loaded (scroll into view) |
| `first_journal_tile` | At least one journal in the list |

### Common failures

| Symptom | Likely cause |
|---------|----------------|
| Timeout on `journals_statistics` | No network, API error, or missing `API_KEY` |
| Empty journal list | API down or dataset returned no journals |

---

## Test Case 5 – Journal Details

### Scenario

1. Launch the app on Home.
2. Open the **Journals** tab and wait for the list.
3. Tap the **first** journal in the leaderboard.
4. Verify the journal detail screen loads.

### Command

```bash
patrol test -t patrol_tests/journal_test.dart --dart-define-from-file=.env --name "Journal details"
```

### Expected result

| Step | Assertion |
|------|-----------|
| After tap on first journal | `journal_detail_screen` key visible |

Patrol reports **PASSED**.

### Prerequisites

- Same as Test Case 4

### Test keys used

| Key | Purpose |
|-----|---------|
| `first_journal_tile` | Open first journal |
| `journal_detail_screen` | Detail screen loaded |

---

## Run both tests in this file

```bash
patrol test -t patrol_tests/journal_test.dart --dart-define-from-file=.env
```
