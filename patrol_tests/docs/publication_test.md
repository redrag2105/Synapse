# publication_test.dart

**Test file:** `patrol_tests/publication_test.dart`  
**Requirements:** Test Case 2 – Topic Search, Test Case 3 – Publication Details ([`testing.md`](../../testing.md))

---

## Patrol tests in this file

| Patrol test name | Test case |
|------------------|-----------|
| `Topic search shows publication results` | 2 – Topic Search |
| `Publication details screen shows publication information` | 3 – Publication Details |

---

## Test Case 2 – Topic Search

### Scenario

1. Launch the app on Home.
2. Open the **Search** tab (center FAB).
3. Enter topic `machine learning` in the search field.
4. Submit search (keyboard search action).
5. Wait for API results.
6. Verify at least one publication card is shown.

### Command

```bash
patrol test -t patrol_tests/publication_test.dart --dart-define-from-file=.env --name "Topic search"
```

### Expected result

| Step | Assertion |
|------|-----------|
| Search tab | **Search Publications** title visible |
| After submit | `first_publication_card` key visible |
| Results | `first_publication_card` key visible (at least one result) |

Patrol reports **PASSED**.

### Prerequisites

- **Internet** access (publication search uses the OpenAlex API)
- **`.env` with `API_KEY`** — pass `--dart-define-from-file=.env` when running Patrol (same as VS Code debug). Without it, search may return HTTP 503 under test load even though manual debug works.
- No sign-in required

### Test keys used

| Key | Purpose |
|-----|---------|
| `bottom_nav_search` | Open Search tab |
| `publication_search_field` | Enter search keyword |
| `publication_results_list` | Results loaded |
| `first_publication_card` | At least one result present |

### Notes

- Default keyword is `machine learning` (stable, high-result query).
- Loading can take up to ~45 seconds on slow networks.

### Common failures

| Symptom | Likely cause |
|---------|----------------|
| Timeout on `first_publication_card` | No network, API error, empty results, or results off-screen |
| `Lỗi:` with HTTP 503 on screen | Missing `API_KEY` in Patrol build — use `--dart-define-from-file=.env` |
| Search field not found | Search tab not opened |
| Empty results | API down — try another keyword in the test |

---

## Test Case 3 – Publication Details

### Scenario

1. Launch the app on Home.
2. Search for `machine learning` (same flow as Test Case 2).
3. Tap the **first** publication in the results list.
4. Verify the publication detail screen loads with scrollable content.

### Command

```bash
patrol test -t patrol_tests/publication_test.dart --name "Publication details"
```

### Expected result

| Step | Assertion |
|------|-----------|
| After tap on first card | `publication_detail_screen` key visible |
| Content | At least one vertical `Scrollable` on screen |

Patrol reports **PASSED**.

### Prerequisites

- Same as Test Case 2 (network + successful search results)

### Test keys used

| Key | Purpose |
|-----|---------|
| `first_publication_card` | Open first result |
| `publication_detail_screen` | Detail screen loaded |

### Notes

- Reuses `searchPublications` and `openFirstPublication` from `patrol_helpers.dart`.
- Detail fetch may take up to ~20 seconds to settle.

### Common failures

| Symptom | Likely cause |
|---------|----------------|
| Timeout on `publication_detail_screen` | Navigation failed or API error |
| No card to tap | Test Case 2 preconditions failed |
| Scrollable not found | Detail still loading or error state |

---

## Run both tests in this file

```bash
patrol test -t patrol_tests/publication_test.dart
```
