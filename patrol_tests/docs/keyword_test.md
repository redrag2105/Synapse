# keyword_test.dart

**Test file:** `patrol_tests/keyword_test.dart`  
**Requirements:** Test Case 6 – Keywords Navigation, Test Case 7 – Keyword Details ([`testing.md`](../../testing.md))

---

## Patrol tests in this file

| Patrol test name | Test case |
|------------------|-----------|
| `Keywords tab shows statistics and keyword list` | 6 – Keywords Navigation |
| `Keyword details screen shows keyword analysis` | 7 – Keyword Details |

---

## Test Case 6 – Keywords Navigation

### Scenario

1. Launch the app on Home.
2. Tap the **Keywords** tab in the bottom navigation.
3. Wait for keyword overview and frequency list to load.
4. Verify keyword statistics and the keyword list are shown.

### Command

```bash
patrol test -t patrol_tests/keyword_test.dart --dart-define-from-file=.env --name "Keywords tab"
```

### Expected result

| Step | Assertion |
|------|-----------|
| Keywords tab | `keywords_screen` key visible |
| Statistics | `keywords_statistics` and **Top keyword** visible |
| List | **Most Frequent Keywords** with `first_keyword_tile` (signed-in history) **or** `keywords_frequent_empty` |
| Trending | **Trending Keywords** section visible |

Patrol reports **PASSED**.

### Prerequisites

- **Internet** access (OpenAlex API for trending + works counts)
- **`.env` with `API_KEY`** — pass `--dart-define-from-file=.env`
- Personalized “Most Frequent” needs a signed-in user with Home search history; guests see an empty-state card instead

### Test keys used

| Key | Purpose |
|-----|---------|
| `bottom_nav_keywords` | Open Keywords tab |
| `keywords_screen` | Keywords screen loaded |
| `keywords_statistics` | Overview statistics loaded |
| `first_keyword_tile` | First personal keyword (when history exists) |
| `keywords_frequent_empty` | Empty state when no personal history |

---

## Test Case 7 – Keyword Details

### Scenario

1. Launch the app on Home.
2. Open the **Keywords** tab and wait for the list.
3. Tap the **first** keyword in the frequency chart.
4. Verify keyword analysis sections are displayed.

### Command

```bash
patrol test -t patrol_tests/keyword_test.dart --dart-define-from-file=.env --name "Keyword details"
```

### Expected result

| Step | Assertion |
|------|-----------|
| After tap | `keyword_detail_screen` visible |
| Analysis | **Publication trends**, **Top contributing authors**, **Related journals**, **Related publications** |

Patrol reports **PASSED**.

### Prerequisites

- Same as Test Case 6

### Test keys used

| Key | Purpose |
|-----|---------|
| `first_keyword_tile` | Open first keyword |
| `keyword_detail_screen` | Detail screen loaded |

---

## Run both tests in this file

```bash
patrol test -t patrol_tests/keyword_test.dart --dart-define-from-file=.env
```
